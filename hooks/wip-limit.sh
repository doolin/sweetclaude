#!/usr/bin/env bash
# wip-limit.sh — PreToolUse hook on Bash
# Blocks IMPLEMENT entry in Kanban mode when WIP limit is reached.
# Returns {"ok": true} to allow or {"ok": false, "reason": "..."} to block.

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
EFFECTIVE_GATES="$PROJECT_DIR/.sweetclaude/state/effective-gates.yaml"
PHASE_YAML="$PROJECT_DIR/.sweetclaude/state/phase.yaml"

allow()  { echo '{"ok": true}'; exit 0; }
block()  { printf '{"ok": false, "reason": "%s"}' "$1"; exit 0; }

[ -f "$EFFECTIVE_GATES" ] || allow

mode=$(python3 -c "
import yaml
with open('$EFFECTIVE_GATES') as f: d=yaml.safe_load(f)
print(d.get('mode','flow'))
" 2>/dev/null) || allow

[ "$mode" = "kanban" ] || allow

[ -f "$PHASE_YAML" ] || allow

phase=$(python3 -c "
import yaml
with open('$PHASE_YAML') as f: d=yaml.safe_load(f)
print(d.get('phase',''))
" 2>/dev/null) || allow

[ "$phase" = "IMPLEMENT" ] || allow

wip_limit=$(python3 -c "
import yaml
with open('$EFFECTIVE_GATES') as f: d=yaml.safe_load(f)
print(d.get('wip_limit', 3))
" 2>/dev/null) || allow

in_progress=$(python3 -c "
import yaml, os, glob
d = '$PROJECT_DIR/.sweetclaude/artifacts/issues'
if not os.path.exists(d):
    print(0); exit()
count = sum(
    1 for f in glob.glob(os.path.join(d,'*.yaml'))
    if (yaml.safe_load(open(f)) or {}).get('status') == 'in_progress'
)
print(count)
" 2>/dev/null) || allow

if [ "$in_progress" -ge "$wip_limit" ]; then
    block "WIP limit reached ($in_progress/$wip_limit items in_progress). Complete or move an item before starting new work."
fi

allow
