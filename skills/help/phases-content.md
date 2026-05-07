# Phases — content for sweetclaude:help Option 1

## Option 1 — Project Phases (top-level)

SweetClaude structures every project through seven phases:

**Discover** — understand the problem before committing to a solution. Who are the users, what do they actually need, and what's explicitly out of scope?

**Define** — write down what you're building and how you'll know it worked. This produces a product brief and, for larger work, a PRD with functional requirements and success criteria.

**Design** — decide the technical approach before writing code. Architecture, data model, API contracts, UX flows. The goal is to resolve ambiguity on paper, not in the middle of implementation.

**Plan** — break the work into stories and tests. Gherkin specs or acceptance criteria get written here, before any implementation begins.

**Implement** — write the code. Tests go red first, then green. SweetClaude runs the TDD pipeline here, with subagent isolation between test writers and implementers at higher rigor levels.

**Verify** — code review, security review, all tests passing in CI, documentation updated. No skipping.

**Ship** — merge, deploy, smoke test in production, changelog updated.

Not every project uses all seven. A hotfix might go straight Diagnose → Implement → Ship. An experiment might stay in Discover for a while. The phases adapt to the work type.

## Option 1a — Skill workflows per phase

What SweetClaude typically uses at each phase depends on how much structure you're running with — lighter modes use a subset, fuller modes use more.

**Discover** — `product-discovery`, `user-personas`, `product-user-focus-group`, `product-competition`

**Define** — `product-brief`, `product-prd`, `product-terminology`, `product-user-stories`

**Design** — `design-architecture`, `design-data-model`, `design-api-design`, `design-ux`, `design-user-flows`, `design-wireframes`, `design-tech-spec`, `design-solutioning-gate`, `design-manage-decisions`

**Plan** — `project-backlog`, `project-sprints`, `project-themes`, `epic-design`, `product-milestone-planning`

**Implement** — `code-feature`, `code-issue`, `code-debt`, `code-tdd`

**Verify** — `code-review`, `code-verify`, `testing-plan`, `testing-security`, `testing-accessibility`, `testing-performance`, `testing-compliance`, `testing-session`

**Ship** — `deploy-ship`

I can explain any of these skills individually, or I can show you what's used at various levels of structure. Just tell me where you want to go.

## Option 1b — Project structure and deliverables

SweetClaude keeps all of its own artifacts in a `.sweetclaude/` directory at the root of your repo — separate from your codebase so its work never mingles with your distributable code.

**State** (`.sweetclaude/state/`)
- `sweetclaude.yaml` — active project state, operating mode, session flags
- `personas.yaml` — defined user personas
- `decision-log.md` — architecture and product decisions
- `improvement-register.md` — learnings captured across sessions

**Product** (`.sweetclaude/product/`)
- Product brief, PRD, roadmap, competitive research

**Design** (`.sweetclaude/design/`)
- Architecture doc, tech spec, data model, API contracts, UX flows

**Plans** (`.sweetclaude/plans/`)
- Implementation plans, sprint plans, task breakdowns

**Tests** — live alongside your source code; SweetClaude follows your existing conventions.

Nothing gets created until you work through the phase that produces it. A vibe-coding project might only ever have `sweetclaude.yaml`. A fully structured project accumulates the full tree.

SweetClaude can also set up a local RAG system using LanceDB — indexing all your design documents so both you and SweetClaude can ask questions about the architecture, data model, or product decisions and get fast, canonical answers without digging through files manually. It runs fully offline with no external services or API keys required.

I can explain any of the above, walk you through how the RAG system works, or take you somewhere else. Just tell me where you want to go.

## Option 1c — Hello-world project

The best way to see SweetClaude in action is to walk a small project through the full lifecycle. Here's what that looks like end-to-end with a toy example — a simple task list API.

**Discover** — SweetClaude asks: who uses this, what problem does it solve, what's out of scope? We establish: it's a personal productivity tool, single user, no auth needed, just CRUD for tasks.

**Define** — A one-page product brief gets written: problem statement, success criteria, three explicit out-of-scope items. For a hello-world we skip the full PRD.

**Design** — Architecture decision: SQLite, single REST service, three endpoints. Data model defined. No UX flows needed — it's an API.

**Plan** — Two user stories with acceptance criteria. Gherkin specs written for each.

**Implement** — Test writer agent produces failing tests from the Gherkin. Implementer agent makes them green. No test files were touched during implementation.

**Verify** — Code review runs. All tests pass. No security surface to review for a local-only API.

**Ship** — Committed, tagged, changelog entry written.

Total conversation turns to get here: roughly 15–20. Most of the work happens in subagents you don't see.

We can do a simple hello-world project, brainstorm something a little more substantial as a pilot, or you can grab one of those ideas you've never had time to build. Want to take it for a spin?

## Option 1d — Approaching an existing project

SweetClaude can drop into a codebase that's already in progress. Here's how it typically gets oriented.

First, it does a read-only survey — structure, stack, test coverage, README, recent git history, any existing docs. No changes, just observation.

From there it builds a picture of where the project is in its lifecycle and what's missing. A mature codebase with no tests gets a different recommendation than a greenfield project mid-build. It'll flag things like: no architecture doc, no defined personas, gaps in test coverage, security surface that hasn't been reviewed.

Then it proposes a starting point — usually one of three:
- **Catch up on artifacts** — write the docs and decisions that should exist but don't, so SweetClaude has solid ground to work from
- **Jump straight to active work** — pick up the next logical task and start building, letting artifacts accumulate naturally as you go
- **Run a health check** — get a structured assessment of the project's shape before deciding anything

Before doing any of this, SweetClaude will recommend creating a safety branch — a snapshot of exactly where things are now, so you always have a clean rollback point.

Want to try this on a current project (safety branch first), or keep exploring?
