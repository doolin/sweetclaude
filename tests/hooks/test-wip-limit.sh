#!/usr/bin/env bash
set -euo pipefail

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/hooks/wip-limit.sh"
PASS=0; FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/.sweetclaude/state" "$tmpdir/.sweetclaude/artifacts/issues"

write_gates() {
    cat > "$tmpdir/.sweetclaude/state/effective-gates.yaml" << YAML
schema_version: 1
mode: $1
default_tdd_level: 1
wip_limit: ${2:-3}
blocked_skills: []
gates:
  - phase: IMPLEMENT
    condition: wip_limit_reached
    action: block
    message: "WIP limit reached ({current}/{limit} items in_progress)."
YAML
}

write_phase() {
    cat > "$tmpdir/.sweetclaude/state/phase.yaml" << YAML
phase: $1
work_type: net-new-feature
YAML
}

write_issues() {
    rm -f "$tmpdir/.sweetclaude/artifacts/issues/"*.yaml
    for i in $(seq 1 "$1"); do
        printf "id: I-%03d\nstatus: in_progress\ntitle: Issue %d\n" "$i" "$i" \
            > "$tmpdir/.sweetclaude/artifacts/issues/I-$(printf '%03d' $i).yaml"
    done
}

run_hook() { PROJECT_DIR="$tmpdir" bash "$HOOK" 2>&1; }

is_ok()     { python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if d.get('ok') else 1)"; }
is_blocked(){ python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if not d.get('ok') else 1)"; }

# Test 1: flow mode — always allow
write_gates "flow" 3; write_phase IMPLEMENT; write_issues 5
run_hook | is_ok && pass "flow mode: always allow" || fail "flow mode: should allow"

# Test 2: kanban, 2/3 in_progress — allow
write_gates "kanban" 3; write_phase IMPLEMENT; write_issues 2
run_hook | is_ok && pass "kanban 2/3: allow" || fail "kanban 2/3: should allow"

# Test 3: kanban, 3/3 in_progress — block
write_gates "kanban" 3; write_phase IMPLEMENT; write_issues 3
run_hook | is_blocked && pass "kanban 3/3: block" || fail "kanban 3/3: should block"

# Test 4: block message contains count info
write_gates "kanban" 3; write_phase IMPLEMENT; write_issues 3
msg=$(run_hook | python3 -c "import json,sys; print(json.load(sys.stdin).get('reason',''))")
echo "$msg" | grep -q "3" && pass "block message includes count" || fail "block message missing count"

# Test 5: kanban, not in IMPLEMENT — always allow
write_gates "kanban" 3; write_phase DEFINE; write_issues 10
run_hook | is_ok && pass "kanban DEFINE phase: always allow" || fail "kanban DEFINE: should allow"

# Test 6: kanban, 0/3 in_progress — allow
write_gates "kanban" 3; write_phase IMPLEMENT; write_issues 0
run_hook | is_ok && pass "kanban 0/3: allow" || fail "kanban 0/3: should allow"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
