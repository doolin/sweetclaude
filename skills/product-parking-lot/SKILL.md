---
spdx-license: AGPL-3.0-or-later
name: sweetclaude:product-parking-lot
user-invocable: true
disable-model-invocation: true
description: "Manage deferred work. Add, review, prioritize, or groom backlog items. Each item gets its own file with substantive initial thinking, not just a title. Tracks what's been parked and why, surfaces items when they become relevant."
category: product
---

!`cat .sweetclaude/state/session-state.yaml 2>/dev/null || echo "STATE_NOT_FOUND"`

<preflight-guard>
STOP. Before executing this skill, check: does .sweetclaude/state/phase.yaml exist in the project directory? If NO, do not proceed. Instead say: "This project is not configured for SweetClaude. Let me run the pre-flight check." Then invoke the sweetclaude master skill (Skill tool, skill: "sweetclaude:master") and run its pre-flight. Return here only after the pre-flight passes.
</preflight-guard>

# Backlog Management

Manage backlog: $ARGUMENTS

## State Check

Read `.sweetclaude/state/skills.yaml`.

**Schema migration:** If `skills.yaml` exists with `schema_version: 1`, migrate this skill's entry before proceeding:
- `enabled: true` → `status: active`, `last_changed_at: {onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at` set → `status: paused`, `last_changed_at: {offboarded_at or onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at: ~` → `status: uninitialized`, `last_changed_at: ~`, `last_changed_by: ~`
Drop `onboarded_at`/`offboarded_at`. Set `schema_version: 2`. Write atomically (see write protocol below).

**Dependency check:**
Read `~/.claude/config/sweetclaude/skills-registry.yaml`. Find `skills.product-parking-lot.dependencies`. This skill has no dependencies — skip.

**If `skills.yaml` does not exist, OR exists but has no entry for `skills.product-parking-lot`:**
- Check whether `{base_path}/backlog/BACKLOG-INDEX.md` exists
- If yes: write entry with `status: active`, `last_changed_at: {today}`, `last_changed_by: migrated`
- If no: write entry with `status: uninitialized`, `last_changed_at: ~`, `last_changed_by: ~`
- Use write protocol below.

**If `skills.yaml` exists and has an entry for `skills.product-parking-lot`:**
- `status: active` → proceed normally
- `status: paused` AND `$ARGUMENTS` not in `[onboard, offboard, pause]`:
  > "Backlog is currently paused. Resume? [yes/no]"
  If yes: write `status: active`, `last_changed_at: {today}`, `last_changed_by: resume` (using write protocol). Proceed normally.
  If no: stop.
- `status: uninitialized` AND `$ARGUMENTS` not in `[onboard, offboard, pause]`:
  → Run lightweight first-invocation flow (see below)
- `$ARGUMENTS` is `pause` → run pause operation
- `$ARGUMENTS` is `offboard` and `status: uninitialized`: "Backlog isn't set up yet. Nothing to offboard." Stop.
- `$ARGUMENTS` is `pause` and `status: paused`: "Already paused." Stop.
- `$ARGUMENTS` is `pause` and `status: uninitialized`: "Not set up yet. Nothing to pause." Stop.

**Write protocol — all skills.yaml writes must follow this:**
1. Read and parse current `.sweetclaude/state/skills.yaml` (or start from default v2 structure if absent)
2. Merge your entry — do NOT remove or overwrite other skills' entries
3. Write merged content to `.sweetclaude/state/.skills.yaml.tmp`
4. Run: `mv .sweetclaude/state/.skills.yaml.tmp .sweetclaude/state/skills.yaml`

**State writes (use write protocol for all):**
- End of lightweight first-invocation (success): `status: active`, `last_changed_at: {today}`, `last_changed_by: first-invocation`
- End of onboard (success): `status: active`, `last_changed_at: {today}`, `last_changed_by: onboard`
- Pause operation: `status: paused`, `last_changed_at: {today}`, `last_changed_by: pause`
- Resume: `status: active`, `last_changed_at: {today}`, `last_changed_by: resume`
- End of offboard: `status: uninitialized`, `last_changed_at: {today}`, `last_changed_by: offboard`

---

## Artifact Path Resolution

Before writing any artifact file:

1. Read `.sweetclaude/artifact-privacy.yaml`. If it does not exist, stop and say:
   > "No artifact privacy manifest found. Run `/sweetclaude:setup` to configure artifact privacy, then return here."
   Do not guess a path. Do not fall back to a default.

2. Read `categories.product.base_path`. This is the base directory for all product artifacts.

3. Construct full paths as `{base_path}/{subfolder}/{filename}`, preserving existing subdirectory structure (e.g. if base is `.sweetclaude/product`, milestones go to `.sweetclaude/product/milestones/MS-001.md`).

4. Write artifacts to those paths.

## Routing

If `$ARGUMENTS` is `offboard`, run the offboard flow below.

Classify before adding:
- **Technical items** (bugs, feature requests, tech debt, test gaps) go to `{base_path}/backlog/`.
- **Strategic items** (product ideas, feature concepts, strategic initiatives, market opportunities) go to `strategy/`. Tell the user: "That is a strategic item. Capturing it in strategy/ instead of {base_path}/backlog/."

Never silently put a non-technical item in docs/backlog/.

## Structure

```
{base_path}/backlog/
  BACKLOG-INDEX.md          # Master index with priority, summary, links
  BL-001-short-name.md      # Detail file per item
  BL-002-short-name.md
  ...
```

## Pause — Temporarily stop using this skill

Invoked with argument `pause`.

Sets backlog to `paused` status. Your data is untouched and you can resume at any time by invoking this skill normally.

Write atomically (using write protocol):
- `skills.product-parking-lot.status: paused`
- `skills.product-parking-lot.last_changed_at: {today ISO date}`
- `skills.product-parking-lot.last_changed_by: pause`

Say: "Paused. Your backlog files are safe — nothing was deleted. Resume anytime by running `/sweetclaude:product-parking-lot`."

---

## Offboarding — Export data and stop using this skill

Invoked with argument `offboard`.

1. **Inventory what exists:**

```bash
ls {base_path}/backlog/BL-*.md 2>/dev/null | wc -l
ls {base_path}/backlog/ 2>/dev/null
```

Present: "This project has {N} backlog items in `{base_path}/backlog/`."

If nothing exists, say: "No backlog data found. Nothing to export." Stop.

2. **Ask export format:**

> "Where do you want to export your backlog?
>   github     — create GitHub Issues via `gh issue create`
>   markdown   — copy files to a directory you specify
>   csv        — write a summary CSV to a path you specify
>   none       — skip export, go straight to cleanup options"

3. **Export:**

- **github:** For each BL-*.md, run `gh issue create --title "{title}" --body "{summary + initial thinking}"`. Report what was created.
- **markdown:** Ask "Which directory?" Copy all `BL-*.md` files and `BACKLOG-INDEX.md` there. Report files copied.
- **csv:** Ask "Which path?" Write one row per item: ID, title, priority, depends on, one-line summary. Report path written.
- **none:** Skip.

4. **Verify export (mandatory before deletion is unlocked):**

- **github verification:**
  ```bash
  gh issue list --state all --limit 500 2>/dev/null | wc -l
  ```
  If result ≥ exported_count: "Export verified — {N} items confirmed in GitHub Issues."
  If result < exported_count: "⚠ Export may be incomplete — only {actual} issues found but expected at least {exported_count}. Check GitHub Issues before proceeding."
  If `gh` unavailable: "Could not verify GitHub export automatically. Confirm you see all {N} items in GitHub Issues."
  On any failure or mismatch: ask "Continue anyway despite unverified export? [yes/cancel]". If cancel: stop, do not proceed to deletion.

- **markdown verification:**
  ```bash
  source_count=$(ls {base_path}/backlog/BL-*.md 2>/dev/null | wc -l)
  dest_count=$(ls {dest_dir}/BL-*.md 2>/dev/null | wc -l)
  ```
  If dest_count ≥ source_count: "Export verified — {source_count} files at `{dest_dir}`."
  If dest_count < source_count: "⚠ File count mismatch — {source_count} source files, {dest_count} at destination."
  On mismatch: ask "Continue anyway? [yes/cancel]". If cancel: stop.

- **csv verification:**
  Read the CSV written. Count data rows (excluding header). If row_count ≥ source_count: "Export verified — {N} rows."
  If less: "⚠ Row count mismatch." Ask "Continue anyway? [yes/cancel]". If cancel: stop.

- **none (no export chosen):**
  Require explicit acknowledgment before proceeding:
  > "You've chosen to skip export. Your data will be permanently deleted with no backup.
  > Type exactly: NO BACKUP — to confirm you understand, or anything else to cancel."
  If user types anything other than `NO BACKUP` exactly: "Cancelled. Your data is safe." Stop.

5. **⚠ IRREVERSIBLE DATA LOSS WARNING ⚠**

> "⚠ IRREVERSIBLE DATA LOSS WARNING ⚠
>
> The next step will permanently delete {N} files from `{base_path}/backlog/`.
> This cannot be undone.
>
> To confirm deletion, type exactly: DELETE MY BACKLOG
> To cancel, type anything else."

If the user types anything other than `DELETE MY BACKLOG` exactly, say "Cancelled. Your files are safe." and stop.

6. **Delete only after exact confirmation:**

```bash
rm -rf {base_path}/backlog/
```

Report: "Backlog files deleted."

---

## Lightweight first-invocation — Quick setup on first use

Runs when the skill is invoked normally but `status` is `uninitialized`. Does NOT run when `$ARGUMENTS` is `onboard`.

1. Read `artifact-privacy.yaml` → `{base_path}`. If absent: "No artifact privacy manifest found. Run `/sweetclaude:setup` to configure artifact privacy, then return here." Stop.

2. Present inline:
   > "No backlog set up yet. I'll create the backlog directory at `{base_path}/backlog/`.
   > Import from GitHub Issues? [yes/no/skip]"

3. If **yes**:
   ```bash
   gh issue list --state open --limit 30 2>/dev/null
   ```
   Create `BACKLOG-INDEX.md` with the standard header. For each issue found, create a `BL-XXX` file with title, issue number, and body summary. Report how many were imported.

4. If **no** or **skip**: Create `{base_path}/backlog/BACKLOG-INDEX.md` with the standard header only.

5. Write state (using write protocol): `status: active`, `last_changed_at: {today}`, `last_changed_by: first-invocation`.

6. Proceed to the user's originally requested operation (do not re-route to the full onboard flow).

---

## Onboarding — First-time setup

Invoked with argument `onboard` (by the update skill when this skill is newly installed, or by the user directly).

1. **Scan for existing backlog and task data:**

```bash
# GitHub Issues
gh issue list --state open --limit 30 2>/dev/null | head -30 || true

# Linear, Jira, Notion
grep -ri "linear.app\|jira\|atlassian\|notion.so" README* docs/ .sweetclaude/ 2>/dev/null | head -5

# Existing markdown backlog/todo files
find . -maxdepth 4 -name "*.md" | xargs grep -li "backlog\|todo\|to-do\|tasks" 2>/dev/null | grep -v ".sweetclaude" | head -10
```

2. **Present findings and ask:**

If existing data found:
> "I found existing backlog/task data:
>   {list what was found}
>
> What do you want to do?
>   import    — create SweetClaude BL-XXX files from this data
>   fresh     — start clean, ignore existing data
>   cancel    — set up later with `/sweetclaude:product-parking-lot onboard`"

If nothing found:
> "No existing backlog found. I'll create the backlog directory at `{base_path}/backlog/`. Proceed? (yes/cancel)"

3. **If import:** For each item found, create a `BL-XXX` file using the backlog template. Populate from source data. Present a summary. Tell the user: "Use `/sweetclaude:product-parking-lot` to review your backlog."

4. **If fresh / yes:** Create `{base_path}/backlog/BACKLOG-INDEX.md` with the standard header. Tell the user: "Ready. Describe a backlog item and I'll add it."

5. **If cancel:** "OK. Run `/sweetclaude:product-parking-lot onboard` when ready."

---

## Adding a Backlog Item

### Step 1: Assign the next BL number
Read `{base_path}/backlog/BACKLOG-INDEX.md`, find the highest BL-XXX number, increment by 1.

### Step 2: Determine priority
If not obvious from context, use AskUserQuestion with these options:
- "P1" — next after current milestone ships
- "P2" — important but not urgent
- "P3" — nice to have / exploratory
- "SPIKE" — research needed before sizing

### Step 3: Write the detail file
Create `{base_path}/backlog/BL-XXX-short-descriptive-name.md`:

```markdown
# BL-XXX: Title

**Priority:** P1/P2/P3/SPIKE
**Depends on:** (other backlog items or user stories, if any)

## Summary
One paragraph describing what this is and why it matters.

## Initial Thinking
- What the implementation might look like
- Key technical decisions
- Dependencies and prerequisites
- Risks or open questions
- Architecture implications — does this affect the data model, API, or infrastructure?
- Connection to other backlog items

## Open Questions
- Unresolved questions that need answers before this can be sized
```

Always include substantive initial thinking, not just a title. Capture context while it is fresh. Initial thinking written during the conversation is far more valuable than reconstructing it later.

### Step 4: Update the index
Add a row to `{base_path}/backlog/BACKLOG-INDEX.md`, grouped by category:
```
| BL-XXX | Short description | Priority | [BL-XXX](BL-XXX-short-name.md) |
```

### Step 5: Confirm
Tell the user: "Added BL-XXX to the backlog: [title]. [one-sentence summary]."

## Reviewing the Backlog

When the user asks to review:
1. Read `{base_path}/backlog/BACKLOG-INDEX.md`.
2. Summarize: total items, count by priority, stale items.
3. Identify items now unblocked (dependencies completed).
4. Suggest re-prioritization if project context changed.
5. Flag items that overlap or could be combined.

## Updating a Backlog Item

1. Read the existing detail file
2. Update the relevant sections
3. Update the index if priority or title changed
4. Note what changed and why at the bottom of the detail file

## Promoting to Active Work

When a backlog item is ready to be built:
1. Move it to the project plan as an active task
2. Mark it in the index (strikethrough or status column)
3. The detail file becomes the starting brief for design/planning

## Rules

- Every item gets a file. The index is just an index.
- BL numbers are permanent. Never renumber. Gaps are fine.
- Group by category in the index, not by date or priority alone.
- Link dependencies. If BL-013 depends on BL-010, say so in both files.
- Spikes produce a recommendation, not deliverables.
