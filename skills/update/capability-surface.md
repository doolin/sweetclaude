# Step 7: Surface capabilities (capability-surface.md)

**IMPORTANT: This step has two parts. Both parts must execute. Do not stop after 7a.**

## 7a: What's new in this update

Compare the installed hooks and config files (before sync) against the new version. Identify:

1. **New hooks** — files in `$SOURCE_DIR/hooks/` that did not exist in the previously installed hooks directory (`${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/hooks/sweetclaude}/`)
2. **New skills** — skill directories in `$SOURCE_DIR/skills/` that did not exist in the previously installed `{installPath}/skills/`
3. **New config templates** — files in `$SOURCE_DIR/config/templates/` that are new

For each new item, check whether it requires per-project opt-in. Read the hook or skill to determine what config is needed.

If new items exist, present:
```
New in this update:
  → {skill-name}: {one-line description}
    Available as: /sweetclaude:{skill-name}
    Enable: {opt-in steps if required, else omit}
```

If nothing is new, show: "No new skills or hooks in this update."

**Skill state check and bootstrap:**

This runs unconditionally — regardless of whether any new skills were found.

Only run if `.sweetclaude/` exists in the current project directory.

Read `.sweetclaude/state/skills.yaml` if it exists.

**Step 1 — schema migration:** If `skills.yaml` exists with `schema_version: 1`, migrate to v2 now:
- `enabled: true` → `status: active`, `last_changed_at: {onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at` set → `status: paused`, `last_changed_at: {offboarded_at or onboarded_at or today}`, `last_changed_by: migrated`
- `enabled: false` with `onboarded_at: ~` → `status: uninitialized`, `last_changed_at: ~`, `last_changed_by: ~`
- Drop `onboarded_at` and `offboarded_at` fields; update `schema_version: 2`
- Write atomically: write to `.sweetclaude/state/.skills.yaml.tmp`, then `mv .sweetclaude/state/.skills.yaml.tmp .sweetclaude/state/skills.yaml`
- Report: "Migrated skills.yaml to schema v2."

**Step 2 — fill missing entries:** For `base_path`: read `.sweetclaude/artifact-privacy.yaml` → `categories.product.base_path`. If absent, use `.sweetclaude/artifacts/product`.

For each of the six data-owning skills not already in `skills.yaml`, infer state from data files:

| Skill | Data file that indicates it was in use |
|---|---|
| `product-milestones` | `{base_path}/milestones/MILESTONES-INDEX.md` |
| `product-parking-lot` | `{base_path}/backlog/BACKLOG-INDEX.md` |
| `product-sprint-plan` | *(no inference — always `uninitialized` if absent)* |
| `user-personas` | `.sweetclaude/state/personas.yaml` |
| `product-user-stories` | any `US-*.md` under `{base_path}/stories/` |
| `document-corpus` | `.sweetclaude/state/corpus-pipeline.yaml` |

For each missing entry: data file exists → `status: active`, `last_changed_by: migrated`. Does not exist → `status: uninitialized`. Write atomically (temp file → rename). Do not remove existing entries.

**Skill onboarding prompt:**

After bootstrap, read `skills.yaml`. Build a list of all six data-owning skills where `status: uninitialized`. This list drives the onboarding prompt.

If the list is empty, skip the prompt and continue to 7b.

If non-empty, ask:

> "These skills aren't set up for this project yet. Which would you like to set up now?
>
>   {list only the skills with status: uninitialized, one per line with keyword and description}
>
> Enter keywords (e.g. "milestones backlog"), or "none" to skip."

| Keyword | Skill | What it does |
|---------|-------|--------------|
| `milestones` | `product-milestones` | Roadmap targets like "Exit Stealth" or "MVP Shipped" |
| `backlog` | `product-parking-lot` | Deferred work items with context |
| `sprint` | `product-sprint-plan` | Select stories from backlog into a sprint |
| `personas` | `user-personas` | Define who your users are and what they need |
| `stories` | `product-user-stories` | Write user stories for defined personas |
| `corpus` | `document-corpus` | Import and index your project documents |

For each skill the user enables, invoke it with argument `onboard`. Complete each onboard flow before starting the next. If the user says "none", continue.

**Then immediately continue to 7b. Do not stop here.**

## 7b: Full skill catalog

**This section always runs regardless of what 7a found.**

Read all skill directories from `$SOURCE_DIR/skills/`. For each, extract the `description` and `category` fields from `SKILL.md` frontmatter. Group by category. Infer category from directory name prefix if `category` is absent (`code-*` → Code, `design-*` → Design, `product-*` → Product, `documents-*` → Documents, `corpus-*` → Documents, everything else → Framework).

Present immediately after the 7a output:

```
All installed skills (v{new_version}):
═══════════════════════════════════════

PRODUCT
  /sweetclaude:product-parking-lot     — {description, truncated to ~80 chars}
  /sweetclaude:product-milestones      — ...
  ...

CODE
  /sweetclaude:code-feature            — ...
  ...

DESIGN
  /sweetclaude:design-architecture     — ...
  ...

DOCUMENTS
  /sweetclaude:document-corpus         — ...
  /sweetclaude:corpus-status           — ...
  ...

FRAMEWORK
  /sweetclaude:go                      — ...
  /sweetclaude:status                  — ...
  ...
```
