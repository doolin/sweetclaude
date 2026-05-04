---
spdx-license: AGPL-3.0-or-later
name: sweetclaude:project-sprints
description: "Sprint planning, activation, board view, and close. Tracks velocity and retrospectives."
---

!`cat .sweetclaude/state/session-state.yaml 2>/dev/null || echo "STATE_NOT_FOUND"`

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"

# Load active sprint if one exists
ACTIVE_SPRINT=$(python3 "${_sc_hooks}/sc-artifact-impl.py" \
  query "$SC_PROJECT_ROOT" "$SC_PRODUCT_BASE" "$SC_STATE_BASE" \
  sprint status=active 2>/dev/null | python3 -c "
import json,sys
items=json.load(sys.stdin)
print(items[0]['id'] if items else 'NONE')
" 2>/dev/null || echo "NONE")

echo "ACTIVE_SPRINT=$ACTIVE_SPRINT"
```

# Project Sprints

Manage sprints: plan, activate, track, and close. Arguments: `$ARGUMENTS`

---

## MODE CHECK

Read `mode` from pre-loaded session state (or `cat .sweetclaude/state/effective-gates.yaml 2>/dev/null | grep "^mode:"`)

If `mode` is `flow`, `kanban`, or `shape_up`, output and stop:

> "This skill is not active in **{mode}** mode.
>
> - **Flow and Kanban** use continuous delivery without sprint cadence. Track work with `/sweetclaude:project-issues`.
> - **Level Up** uses fixed-time cycles with pitches, not sprints. Create issues from a pitch with `/sweetclaude:project-issues`.
>
> To use sprint tracking, shift to Agile mode: `/sweetclaude:project-mode shift agile`"

Proceed only if `mode` is `agile` (or unset).

---

## Routing

| Arguments | Operation |
|---|---|
| (empty) | → **Status** — active sprint board or summary |
| `list` | → **List** all sprints |
| `new` | → **Plan** a new sprint |
| `start <SP-NNN>` | → **Activate** a planned sprint |
| `board` | → **Board** view of active sprint |
| `update <ID>` | → **Update** an issue on the active sprint |
| `close` | → **Close** the active sprint |
| `retro` | → **Retrospective** for the most recently closed sprint |

---

## Status (default)

If `ACTIVE_SPRINT` is `NONE`:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query sprint status=planned
```

If planned sprints exist: "No active sprint. Next planned: {SP-NNN} — {title}. Run `project-sprints start {SP-NNN}` to begin."
If no planned sprints either: "No sprints. Run `project-sprints new` to plan one."

If `ACTIVE_SPRINT` is set, run the **Board** operation (below).

---

## List

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_list sprint
```

Present as table, newest first:

```
ID      Title         Status    Start       End         Velocity
──────────────────────────────────────────────────────────────────
SP-003  Sprint 3      active    2026-05-06  2026-05-20  —
SP-002  Sprint 2      complete  2026-04-22  2026-05-06  8
SP-001  Sprint 1      complete  2026-04-08  2026-04-22  5
```

---

## New (Plan a sprint)

Check for existing active sprint first:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query sprint status=active
```

If one exists: "Sprint {ID} is already active. Close it before planning a new one, or plan ahead — the new sprint won't start until you explicitly activate it."

Ask, one question at a time:

1. **Title** — "What's this sprint called? (e.g. 'Sprint 4' or 'Sprint 2026-05-20')"
2. **Start date** — "Start date? (YYYY-MM-DD)"
3. **End date** — "End date? (YYYY-MM-DD)"
4. **Goal** — "What's the sprint goal — the one sentence that describes what's true when this sprint succeeds?"
5. **Capacity notes** — "Any known interruptions or reduced availability? (or press enter to skip)"

Then load the backlog to suggest issues:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query issue sprint_id= status=backlog
```

Present the top 10 by priority. Ask: "Which of these should go into the sprint? List the IDs, or say 'none' to plan the sprint empty."

Once confirmed, create the sprint:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_create sprint '{
  "title": "<title>",
  "status": "planned",
  "start_date": "<start>",
  "end_date": "<end>",
  "goal": "<goal>",
  "capacity_notes": "<notes or null>"
}'
```

For each issue the user selected, promote via:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_write <issue_id> '{"sprint_id": "<new_sprint_id>", "status": "ready"}'
```

Confirm: `Sprint {SP-NNN} planned with {N} issues`

---

## Start (Activate)

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_read <SP-NNN>
```

Verify status is `planned`. If already `active`: "Already active." If `complete` or `cancelled`: "Can't activate a {status} sprint."

Check no other sprint is active:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query sprint status=active
```

If another sprint is active: "Sprint {ID} is already running. Close it before starting a new one."

Load the sprint's issues:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query issue sprint_id=<SP-NNN>
```

Present issue count and goal. Confirm: "Start {SP-NNN} — {title}? Goal: {goal} ({N} issues)"

On confirmation:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_write <SP-NNN> '{"status": "active"}'
```

Confirm: `Sprint {SP-NNN} is now active — {goal}`

---

## Board

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_read $ACTIVE_SPRINT
sc_artifact_query issue sprint_id=$ACTIVE_SPRINT
```

Present the sprint board, grouped by status:

```
SP-NNN — Sprint title                          {start} → {end}
Goal: {goal}
────────────────────────────────────────────────────────────────

READY ({n})
  I-NNN  story   m  Title of issue
  I-NNN  bug     s  Title of issue

IN PROGRESS ({n})
  I-NNN  story   l  Title of issue

IN REVIEW ({n})
  I-NNN  chore   s  Title of issue

DONE ({n})
  I-NNN  story   m  Title of issue
  I-NNN  bug     xs Title of issue
```

After board:
- Progress: `{done} / {total} issues complete`
- Adrift check: any issue with 2+ `carried_over` entries in sprint_history → "⚠ Adrift: I-NNN carried over {N} times"
- Days remaining: compute from end_date → today

---

## Update

Move or update an issue on the active sprint. Accepts natural language.

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_read <ID>
```

Map the user's intent to a `sc_artifact_write` call. Common updates:
- "start I-NNN" / "in progress" → `status: in_progress`
- "review I-NNN" / "in review" → `status: in_review`
- "done I-NNN" / "close" → `status: done` (also append sprint_history outcome=completed)
- "blocked I-NNN" → add `blocked: true` note in the description
- "descope I-NNN" → `sprint_id: null`, `status: backlog` (also append sprint_history outcome=descoped)

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_write <ID> '<json>'
```

Confirm the change in one line.

---

## Close

Closes the active sprint. Requires `ACTIVE_SPRINT` to be set.

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_read $ACTIVE_SPRINT
sc_artifact_query issue sprint_id=$ACTIVE_SPRINT
```

**Step 1: Handle incomplete issues.**

For each issue not in `done` status, ask:
```
{N} issues are not done: {list of IDs and titles}

For each one, choose:
  carry → move to next sprint (sprint_history outcome: carried_over)
  descope → return to backlog (sprint_history outcome: descoped)
  close → mark done now (sprint_history outcome: completed)

Reply with: <ID> carry|descope|close [, <ID> carry|descope|close, ...]
Or say "carry all" / "descope all".
```

Process each according to the user's choice:
- `carry`: update sprint_history with `outcome: carried_over`, `removed_date: today`. Leave sprint_id for now (will be updated when next sprint starts).
- `descope`: update sprint_history with `outcome: descoped`, `removed_date: today`. Set `sprint_id: null`, `status: backlog`.
- `close`: set `status: done`. Update sprint_history with `outcome: completed`, `removed_date: today`.

**Step 2: Calculate velocity.**

Count issues with `status: done` in this sprint. That is the velocity.

**Step 3: Retrospective prompt.**

Ask: "Quick retro — what went well, what didn't, and one thing to change next sprint? (Or say skip.)"

**Step 4: Close the sprint.**

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_write $ACTIVE_SPRINT '{
  "status": "complete",
  "velocity": <N>,
  "retrospective": "<retro text or skipped>"
}'
```

**Step 5: Summary.**

```
Sprint {SP-NNN} closed.
Velocity:   {N} issues completed
Carried:    {N} issues → next sprint
Descoped:   {N} issues → backlog

Run project-sprints new to plan the next sprint.
```

---

## Retro

Load the most recently completed sprint:

```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_query sprint status=complete
```

Select the one with the latest `end_date`. Read its `retrospective` field and `velocity`.

Present a structured retro summary:

```
Retro — {SP-NNN} ({start} → {end})
Velocity: {N}

What was recorded:
  {retrospective text}

Learnings to carry forward:
  (derive 2-3 actionable points from the retrospective text)
```

If the retrospective field is empty or "skipped": "No retro was recorded for {SP-NNN}. What went well, what didn't, and one thing to change?"

Save the user's answer via:
```bash
_sc_hooks="${CLAUDE_PLUGIN_ROOT:+${CLAUDE_PLUGIN_ROOT}/hooks}"; _sc_hooks="${_sc_hooks:-$HOME/.claude/hooks/sweetclaude}"; source "${_sc_hooks}/sc-artifact.sh"
sc_artifact_write $SPRINT_ID '{"retrospective": "<text>"}'
```

---

## Rules

- Only one sprint can be `active` at a time. Enforce this on `start`.
- A sprint cannot be closed while another sprint is being planned — sprint state is linear.
- Velocity = count of `done` issues at close time, not story points or effort.
- Sprint history on issues is append-only. Never overwrite existing entries.
- If an issue is carried over 3+ times across sprints, surface a pointed warning: "I-NNN has been carried over {N} times. Consider breaking it down or descoping it."
