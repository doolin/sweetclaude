# Step 8: Migrate existing project state (project-migration.md)

After syncing the framework, check whether the **current project** (the working directory where this skill was run) has `.sweetclaude/` state that needs migration.

## 8a: Pre-migration backup

Before running any migration, create a backup of the current state directory. Read `config/migration-registry.yaml` to determine which state files require backup (`backup_required: true`).

If any migration will run (detected in 8c/8d/8e), create the backup first:

```bash
BACKUP_DIR=".sweetclaude/state/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_DATE=$(date +%Y%m%d)
BACKUP_SHA=$(git -C . rev-parse --short HEAD 2>/dev/null || echo "nosha")
BACKUP_FILE="$BACKUP_DIR/pre-migration-${BACKUP_DATE}-${BACKUP_SHA}.tar.gz"

tar -czf "$BACKUP_FILE" -C .sweetclaude/state \
  $(ls .sweetclaude/state/*.yaml .sweetclaude/state/*.md 2>/dev/null | xargs -I{} basename {})

echo "Pre-migration backup: $BACKUP_FILE"
```

Retain only the last 5 backups — remove older ones:

```bash
ls -t .sweetclaude/state/backups/pre-migration-*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
```

If the backup fails (disk space, permission), warn and ask: "Could not create pre-migration backup. Proceed without backup? [yes/no]"

**Rollback instructions** (display at the end of migration if backup was created):

> "If migration produced unexpected results, restore with:
> `tar -xzf {BACKUP_FILE} -C .sweetclaude/state/`"

## 8b: Detect project state

Check for `.sweetclaude/state/phase.yaml`.

If `.sweetclaude/` does not exist:
> "This project has no SweetClaude state. Run `/sweetclaude:setup` to set it up."
Stop.

If `phase.yaml` exists, read `schema_version`.

## 8c: Patch CLAUDE.md auto-fire instruction

Check if `CLAUDE.md` exists in the current project directory. If it has a `## SweetClaude` section, check whether it contains the text `invoke \`sweetclaude:status\` automatically at session start`.

If missing, find the line that reads `Read .sweetclaude/state/phase.yaml` (or similar) and replace it with:
```
- Read `.sweetclaude/state/phase.yaml` and `.sweetclaude/state/improvement-register.md` at session start if they exist. If `.sweetclaude/state/phase.yaml` exists and `.sweetclaude/disabled` does not exist, invoke `sweetclaude:status` automatically at session start.
```

Report whether the patch was applied or already up to date.

## 8d: Already on v2

If `schema_version: 2`: "Project state is current (schema v2). No migration needed." Stop.

## 8e: Migrate v1 → v2

If `schema_version: 1`, map the old fields:

| v1 field | v2 destination | Notes |
|---|---|---|
| `phase` | `active_work_item.phase` | Carry forward unless value is `SHIP` or `DONE` → set to `~` |
| `work_type` | `active_work_item.type` | See mapping table below |
| `deference_level` | `deference_level` | Carry forward |
| `project_type` | `project_type` | Carry forward |
| `safety_snapshot` | `safety_snapshot` | Carry forward |
| `init_step` | *(drop)* | No v2 equivalent |

**`work_type` mapping:**

| v1 value | v2 value |
|---|---|
| `net-new` | `net-new-feature` |
| `bug-fix` | `bug-fix` |
| `enhancement` | `enhancement` |
| `refactor` | `tech-debt` |
| `security` | `security-patch` |
| `hotfix` | `hotfix` |
| `performance` | `performance-optimization` |
| anything else | `~` (find-skill will set it when work resumes) |

Show the user a preview before writing:

```
Schema migration: v1 → v2
═════════════════════════
Current (v1):
  phase:           {phase}
  work_type:       {work_type}
  deference_level: {deference_level}
  project_type:    {project_type}
  safety_snapshot: {safety_snapshot}

After migration (v2):
  version_stage:   (you'll set this below)
  deference_level: {deference_level}    [carried forward]
  project_type:    {project_type}       [carried forward]
  safety_snapshot: {safety_snapshot}    [carried forward]
  active_work_item:
    type:  {mapped_type or ~}
    phase: {phase or ~}
    (remaining fields: null — set by find-skill when work resumes)
```

Ask:
> "What version stage is this project at?
> PROTOTYPE | ALPHA | BETA | GA | SCALED | MAINTAINED
>
> PROTOTYPE = early exploration · ALPHA = working but rough · BETA = feature complete · GA = production-ready"

Wait for the user's answer. Then confirm:
> "Ready to write the migrated phase.yaml. Proceed?"

Write `.sweetclaude/state/phase.yaml`:

```yaml
# .sweetclaude/state/phase.yaml
# SweetClaude phase state — schema version 2
schema_version: 2

version_stage: {user_answer}
deference_level: {carried}
project_type: {carried}
safety_snapshot: {carried}
last_work_item_id: ~

active_work_item:
  id: ~
  type: {mapped_type or ~}
  workflow: []
  phase: {v1_phase or ~}
  title: ~
  started: ~
  entry_category: ~
```

Report: "phase.yaml migrated to schema v2. Tell me what you'd like to work on to resume."

## 8f: Migrate skills.yaml v1 → v2

After the phase.yaml migration (or if phase.yaml is already v2), check `.sweetclaude/state/skills.yaml`.

If `skills.yaml` does not exist: nothing to migrate. Continue.

If `skills.yaml` exists with `schema_version: 1`:

Map each entry:
- `enabled: true` → `status: active`, `last_changed_at: {onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at` set → `status: paused`, `last_changed_at: {offboarded_at or onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at: ~` → `status: uninitialized`, `last_changed_at: ~`, `last_changed_by: ~`
- Drop `onboarded_at` and `offboarded_at` fields
- Set `schema_version: 2`

Write atomically: write to `.sweetclaude/state/.skills.yaml.tmp`, then `mv .sweetclaude/state/.skills.yaml.tmp .sweetclaude/state/skills.yaml`.

Report: "skills.yaml migrated to schema v2."

If `skills.yaml` exists with `schema_version: 2`: "skills.yaml already on v2. No migration needed."
