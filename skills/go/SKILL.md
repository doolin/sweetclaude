---
spdx-license: AGPL-3.0-or-later
name: sweetclaude:go
user-invocable: true
description: Assess what to work on next and propose it. Stops at the first obvious item found — unfinished work, hot bugs, roadmap, or debt — and waits for user approval before doing anything.
---

!`cat .sweetclaude/state/session-state.yaml 2>/dev/null || echo "STATE_NOT_FOUND"`

# SweetClaude Go

Assess. Propose. Wait. Do not act until the user says proceed.

---

## Step 1: Read state directly

Session state is pre-loaded above. Use `active_work_item`, `deference`, `active_milestone`, `improvement_register_count`, `checkpoint_next`, and `paths.product_base` from there directly.

Run inline — do NOT spawn a background agent:

```bash
git log --oneline -5
git status --short
tail -25 .sweetclaude/state/checkpoint.md 2>/dev/null || echo "NO_CHECKPOINT"
ls scratch/ 2>/dev/null | grep -iE "checkpoint|continue|resume|handoff" | head -3
product_base=$(cat .sweetclaude/state/session-state.yaml 2>/dev/null | python3 -c "import yaml,sys; d=yaml.safe_load(sys.stdin); print(d.get('paths',{}).get('product_base','.sweetclaude/product'))" 2>/dev/null || echo "MANIFEST_MISSING")
if [ "$product_base" != "MANIFEST_MISSING" ]; then
  ls ${product_base}/milestones/MS-*.md 2>/dev/null | head -10
  grep -rh "\*\*Status:\*\*" ${product_base}/milestones/ 2>/dev/null | head -10
  ls ${product_base}/backlog/*.md 2>/dev/null | head -20
else
  echo "ARTIFACT_PRIVACY_NOT_CONFIGURED — milestone and backlog paths unknown"
fi
```

Do not call `gh`. Do not read backlog file contents — filenames are enough for routing. If state is `STATE_NOT_FOUND`, note it but continue.

## Step 2: Apply improvement register

If `improvement_register_count` in pre-loaded state is > 0, silently apply learnings from previous sessions to this session's behavior before acting. Do not announce this.

## Step 3: Find the most pressing thing

Work through the priority tiers below. Stop at the first tier that has something actionable. Note which tier triggered and why — you'll use this in the proposal.

**Priority 1 — Unfinished work in progress:**
`active_work_item.id` in pre-loaded state is set (non-null, non-`~`). Or `checkpoint_next` is set. This is the highest priority — unfinished work trumps everything.

**Priority 2 — Hot bugs / security / hotfixes:**
Any backlog filename containing `bug`, `hotfix`, `security`, `p0`, `p1`, `critical`, `urgent`.

**Priority 3 — Active roadmap:**
Milestones exist in `${product_base}/milestones/`. Any milestone has `Status: active`. Read its Contributing work items and find the first open one.

**Priority 4 — Other backlog items:**
Non-bug backlog items. Use the first filename found.

**Priority 5 — Nothing queued:**
None of the above tiers have anything actionable.

## Step 4: Produce the proposal

**Do not invoke any skill. Do not start any work. Output the proposal and stop.**

---

### If Priority 1–4 found something:

Output exactly this format — bold header, one-paragraph explanation, three options. Use markdown **bold** for `PROPOSED NEXT WORK`:

```
**PROPOSED NEXT WORK**

{One clear paragraph: what you're proposing to work on, why this item ranks first, and what specifically would happen if the user says proceed. Name the work item or backlog filename. Reference the priority tier reason: "You have unfinished work in progress" / "There's an open bug" / "Your active milestone has a pending work item" / "Top of your backlog is..." Be direct, not hedging.}

Proceed · Review other items · Something else
```

Then wait. Do not take any action until the user responds.

---

### If Priority 5 — nothing queued:

Output:

```
**PROPOSED NEXT WORK**

There's nothing obviously queued. No active work item, no open bugs, no active milestone, no backlog items.

I can help you plan what comes next: create milestones and epics, write user stories, or start a backlog. Want to do that now?
```

Then wait. If the user says yes to planning, invoke `sweetclaude:product-milestones` and explain you'll start there.

---

## Step 5: Handle the user's response

**"proceed" (or "yes", "go", "do it", "let's go", any affirmative):**
Invoke the appropriate skill from the routing table below. Before invoking, one sentence explaining what you're doing.

**"review other items" (or "what else", "show me more", "other options"):**
List the next 2–3 candidates from the priority tiers, in order. For each: name it, say which tier it came from, and say which skill would handle it. Ask which one they want.

**"something else" (or any other input):**
Follow the user's direction immediately per Adaptive Flow. Track the current proposal internally so you can offer to return to it when the detour completes.

---

## Routing table

| Work type | Phase | Open criterion | Skill |
|---|---|---|---|
| any | DISCOVER | No persona or scenario defined | `sweetclaude:product-discovery` |
| any | DEFINE | Product brief incomplete | `sweetclaude:product-brief` |
| net-new-feature | DEFINE | PRD not written | `sweetclaude:product-prd` |
| any | DESIGN | Architecture not written | `sweetclaude:design-architecture` |
| any | DESIGN | Tech spec not written | `sweetclaude:design-tech-spec` |
| any | DESIGN | UX flows not documented | `sweetclaude:design-user-flows` |
| any | DESIGN | Wireframes not generated | `sweetclaude:design-wireframes` |
| any | DESIGN | UX review not run | `sweetclaude:design-ux-review` |
| any | DESIGN | Solutioning gate not passed | `sweetclaude:design-solutioning-gate` |
| any | DESIGN | Data model not designed | `sweetclaude:design-data-model` |
| any | DESIGN | API contracts not defined | `sweetclaude:design-api-design` |
| any | PLAN | User stories not written | `sweetclaude:product-user-stories` |
| any | PLAN | Gherkin specs not generated | `sweetclaude:code-tdd` |
| any | IMPLEMENT | Tests not written or failing | `sweetclaude:code-tdd` |
| any | IMPLEMENT | Code not making tests pass | `sweetclaude:code-feature` |
| tech-debt | SCOPE | Behavior not locked with tests | `sweetclaude:code-tdd` |
| any | VERIFY | Code review not done | `sweetclaude:code-review` |
| any | VERIFY | Tests not passing in CI | `sweetclaude:code-testing` |
| any | VERIFY | Docs not updated | `sweetclaude:documents-update-docs` |
| any | SHIP | Security review not run and not skipped | `sweetclaude:code-review` (security mode) |
| bug-fix | DIAGNOSE | Root cause not identified | `sweetclaude:code-issue` |
| bug-fix | IMPLEMENT | Regression test not written | `sweetclaude:code-tdd` |
| security-patch | DIAGNOSE | Blast radius not assessed | `sweetclaude:code-review` |
| performance-optimization | DIAGNOSE | Baseline benchmark not established | `sweetclaude:code-issue` |
| hotfix | DIAGNOSE | Reproduction case not documented | `sweetclaude:code-issue` |
| backlog bug/hotfix | any | Open bug or hotfix in backlog | `sweetclaude:code-issue` |

### Mode-filtered routing

Read `blocked_skills` from `effective-gates.yaml` if it exists. Remove blocked skills from all suggestion lists.

Apply per mode:
- **flow:** surface project-issues, product-roadmap, product-milestones. Omit project-sprints.
- **kanban:** surface project-issues, product-roadmap, product-milestones, project-backlog. Omit project-sprints.
- **shape_up:** surface project-issues (pitch-source note), product-roadmap, product-milestones. Omit project-sprints, project-backlog.
- **agile:** surface all skills including project-sprints, project-epics.
- **unset:** apply flow filtering.

---

## Rules

- **Propose, do not act.** Never invoke a skill in Step 4. Proposals only.
- **Stop at the first thing.** Don't enumerate all issues — find the top item and propose it.
- **One paragraph, not a list.** The proposal explanation is prose, not bullet points.
- **Never ask "what do you want to do?"** when you have a proposal ready. Present it and offer the three options.
- **Wait after proposing.** Do not continue until the user responds.
- **If the user passes arguments** (e.g., `/sweetclaude:go I need to fix the auth bug`): skip Steps 1–3. Use the user's direction as the proposal, confirm it in the PROPOSED NEXT WORK format, and wait for proceed.
