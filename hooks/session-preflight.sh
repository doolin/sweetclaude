#!/bin/bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# SweetClaude Session Pre-Flight
# SessionStart hook — health checks first, then status or self-heal instruction.
# Per-project opt-out: create .sweetclaude-skip in the project root.

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$PROJECT_DIR" ]; then exit 0; fi
if [ -f "$PROJECT_DIR/.sweetclaude-skip" ]; then exit 0; fi

SC_YAML="$PROJECT_DIR/.sweetclaude/state/sweetclaude.yaml"
PHASE_YAML="$PROJECT_DIR/.sweetclaude/state/phase.yaml"
HOOK_DIR="$(dirname "$0")"
SETTINGS="$HOME/.claude/settings.json"
HOOKS_MANIFEST="$HOOK_DIR/hooks-manifest.json"

# ── JSON emit helpers ────────────────────────────────────────────────────────

_esc() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

emit_heal() {
  local reason="$1"
  local msg="I need to check on the SweetClaude system before beginning — ${reason}."
  local ctx="SweetClaude health check detected: ${reason}. Say exactly: \"${msg}\" Then immediately invoke sweetclaude:fix-sweetclaude."
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
    "$(_esc "$msg")" "$(_esc "$ctx")"
}

emit_ctx() {
  local sysmsg="$1"
  local ctx="$2"
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
    "$(_esc "$sysmsg")" "$(_esc "$ctx")"
}

# ── Not a SweetClaude project — exit silently ────────────────────────────────

if [ ! -f "$SC_YAML" ] && [ ! -f "$PHASE_YAML" ]; then
  LEGACY_REPO="${PROJECT_DIR}-sweetclaude"
  [ -f "$LEGACY_REPO/state/phase.yaml" ] && exit 0
  exit 0
fi

if [ -f "$PROJECT_DIR/.sweetclaude/disabled" ]; then exit 0; fi

# ── HEALTH CHECKS ────────────────────────────────────────────────────────────

# 1. sweetclaude.yaml: schema version and setup complete
if [ -f "$SC_YAML" ]; then
  SC_HEALTH=$(python3 -c "
import yaml, sys
try:
    d = yaml.safe_load(open('$SC_YAML')) or {}
except Exception as e:
    print('sweetclaude.yaml is malformed (' + str(e) + ')'); sys.exit()
v = d.get('schema_version', 0)
if v != 1:
    print('unsupported schema version (' + str(v) + ')'); sys.exit()
if not d.get('framework', {}).get('setup_complete'):
    print('setup not complete — run sweetclaude setup'); sys.exit()
print('ok')
" 2>/dev/null || echo "sweetclaude.yaml unreadable")
  if [ "$SC_HEALTH" != "ok" ]; then
    emit_heal "$SC_HEALTH"
    exit 0
  fi
fi

# 2. Required hooks registered in ~/.claude/settings.json
if [ -f "$HOOKS_MANIFEST" ] && [ -f "$SETTINGS" ]; then
  MISSING_HOOKS=$(python3 -c "
import json, sys
manifest = json.load(open('$HOOKS_MANIFEST'))
try:
    settings = json.load(open('$SETTINGS'))
except:
    settings = {}
all_cmds = ' '.join(
    h.get('command', '')
    for event_hooks in settings.get('hooks', {}).values()
    for entry in event_hooks
    for h in entry.get('hooks', [])
)
missing = [h['file'] for h in manifest['hooks']
           if h.get('required') and h.get('event') and h['file'] not in all_cmds]
print(', '.join(missing) if missing else '')
" 2>/dev/null || echo "")
  if [ -n "$MISSING_HOOKS" ]; then
    emit_heal "required hooks not registered: $MISSING_HOOKS"
    exit 0
  fi
fi

# 3. Hook scripts exist and are executable
if [ -f "$HOOKS_MANIFEST" ]; then
  MISSING_SCRIPTS=$(python3 -c "
import json, os
manifest = json.load(open('$HOOKS_MANIFEST'))
hook_dir = '$HOOK_DIR'
missing = [h['file'] for h in manifest['hooks']
           if h.get('required') and h.get('event')
           and not os.access(os.path.join(hook_dir, h['file']), os.X_OK)]
print(', '.join(missing) if missing else '')
" 2>/dev/null || echo "")
  if [ -n "$MISSING_SCRIPTS" ]; then
    emit_heal "hook scripts missing or not executable: $MISSING_SCRIPTS"
    exit 0
  fi
fi

# ── ALL CHECKS PASS — generate and show status ───────────────────────────────

"$HOOK_DIR/generate-session-state.sh" 2>/dev/null
PROJECT_DIR="$PROJECT_DIR" "$HOOK_DIR/sweetclaude-health-check.sh" 2>/dev/null || true

STATE_FILE="$SC_YAML"
[ -f "$STATE_FILE" ] || STATE_FILE="$PROJECT_DIR/.sweetclaude/state/session-state.yaml"

if [ -f "$STATE_FILE" ]; then
  STATE_CONTENT=$(cat "$STATE_FILE")
  CTX="SweetClaude is active. Pre-loaded session state:"$'\n\n'"${STATE_CONTENT}"

  OS_TYPE=$(uname -s 2>/dev/null || echo "unknown")
  if [ "$OS_TYPE" = "Linux" ] && grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
    CTX="${CTX}"$'\n\n'"PLATFORM: Linux/WSL2 — isolation: \"worktree\" in agent frontmatter is silently ignored (Claude Code #33045). Use explicit EnterWorktree/ExitWorktree calls."
  fi

  STATUS_FILE="$PROJECT_DIR/.sweetclaude/state/session-status.txt"
  if [ -f "$STATUS_FILE" ]; then
    STATUS_BLOCK=$(cat "$STATUS_FILE")
    CTX="${CTX}"$'\n\n'"<sweetclaude-status>"$'\n'"${STATUS_BLOCK}"$'\n'"</sweetclaude-status>"$'\n\n'"Present the content between the <sweetclaude-status> tags verbatim as your first response. Do not invoke any skills. Do not run any tools."
    emit_ctx "$STATUS_BLOCK" "$CTX"
  else
    emit_ctx "SweetClaude is active." "${CTX}"$'\n\n'"Invoke sweetclaude:status now before responding to the user."
  fi
else
  emit_ctx "SweetClaude is active." "SweetClaude is active. Invoke sweetclaude:status now before responding to the user."
fi
