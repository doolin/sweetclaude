---
spdx-license: AGPL-3.0-or-later
name: sweetclaude:help
user-invocable: true
description: "SweetClaude help and skill discovery. Use when the user asks what SweetClaude can do, needs to find the right skill, or is new to the framework. Skill families available: Navigation — status (where are we?), go (what to work on), recap, something-broke (production incidents), bootstrap (session start). Code — code-feature (build a feature), code-issue (implement a GitHub issue), code-review, code-tdd, code-verify. Product planning — product-milestones, product-roadmap, product-backlog, product-brief, product-prd, product-user-stories. Design — design-ux, design-architecture, design-tech-spec, design-api-design, design-wireframes, design-data-model. Testing — testing-plan, testing-session, testing-security, testing-performance, testing-accessibility. Project management — project-goals, project-backlog, project-epics, project-sprints, project-issues. Documents — documents-update-docs, documents-academic-research. Misc — retro, session-export, user-personas, epic-design, ultraplan. For any described task, Claude should suggest the matching skill by name."
---

# SweetClaude Help

## Step 1: Check the skip flag

Read `.sweetclaude/state/sweetclaude.yaml`. If `skip_help_welcome: true`, skip directly to Step 3.

## Step 2: Show the welcome message and menu

Tell the user:

> Welcome to SweetClaude's help skill. It's designed to provide support through natural conversation instead of dumping a wall of text at you. If you want a more typical user guide, there's one in the repo: https://github.com/carson-sweet/sweetclaude/blob/main/docs/user-guide/index.md
>
> **SweetClaude** is a software development partner built for the full project lifecycle — from the first idea through design, implementation, testing, and ship.
>
> It adapts to your working style. You can move fast with minimal structure (vibe-coding), or apply enterprise-class discipline with phase gates, formal specs, TDD pipelines, and QA caucuses — or land anywhere in between. The framework adjusts to the project, not the other way around.
>
> SweetClaude has also been used successfully for academic research, product marketing strategy, and other knowledge-intensive work, but software development is where it lives.

Then use AskUserQuestion with these four options:

1. **Project Phases** — how SweetClaude structures product development, from conceptual idea to go-live
2. **Operating Modes** — how SweetClaude supports incremental structure and discipline, from vibe-coding to enterprise-grade
3. **Workflows and Skills** — an inventory of the individual skills and how they compose into orchestrated workflows
4. **Tell me about your project** — start a conversation about how SweetClaude would approach your specific situation

The AskUserQuestion tool automatically provides an "Other" option — freeform questions from the user are handled there (see Option 5 below).

After the menu, add this line as plain text:
> "To skip this intro in future sessions, just say `skip the welcome`."

## Step 3: Follow the user's choice

**Option 1 — Project Phases:**
Present the following content verbatim, then show the follow-up menu below.

---

SweetClaude structures every project through seven phases:

**Discover** — understand the problem before committing to a solution. Who are the users, what do they actually need, and what's explicitly out of scope?

**Define** — write down what you're building and how you'll know it worked. This produces a product brief and, for larger work, a PRD with functional requirements and success criteria.

**Design** — decide the technical approach before writing code. Architecture, data model, API contracts, UX flows. The goal is to resolve ambiguity on paper, not in the middle of implementation.

**Plan** — break the work into stories and tests. Gherkin specs or acceptance criteria get written here, before any implementation begins.

**Implement** — write the code. Tests go red first, then green. SweetClaude runs the TDD pipeline here, with subagent isolation between test writers and implementers at higher rigor levels.

**Verify** — code review, security review, all tests passing in CI, documentation updated. No skipping.

**Ship** — merge, deploy, smoke test in production, changelog updated.

Not every project uses all seven. A hotfix might go straight Diagnose → Implement → Ship. An experiment might stay in Discover for a while. The phases adapt to the work type.

---

Then use AskUserQuestion with these four options:

- **Skill workflows per phase** — the skills SweetClaude typically uses at each phase, and how they vary by operating mode
- **Project structure and deliverables** — what files and artifacts SweetClaude produces, and where they live
- **Hello-world project** — walk a toy project end-to-end so you can see the whole thing in motion, or take it for a real spin
- **Approaching an existing project** — how SweetClaude gets oriented and starts contributing to a codebase that's already in progress

**Option 1c — Hello-world project:**
Present the following content verbatim:

---

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

---

**Option 1b — Project structure and deliverables:**
Present the following content verbatim:

---

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

---

I can explain any of the above, walk you through how the RAG system works, or take you somewhere else. Just tell me where you want to go.

---

**Option 1a — Skill workflows per phase:**
Present the following content verbatim:

---

What SweetClaude typically uses at each phase depends on how much structure you're running with — lighter modes use a subset, fuller modes use more.

**Discover** — `product-discovery`, `user-personas`, `product-user-focus-group`, `product-competition`

**Define** — `product-brief`, `product-prd`, `product-terminology`, `product-user-stories`

**Design** — `design-architecture`, `design-data-model`, `design-api-design`, `design-ux`, `design-user-flows`, `design-wireframes`, `design-tech-spec`, `design-solutioning-gate`, `design-manage-decisions`

**Plan** — `project-backlog`, `project-sprints`, `project-themes`, `epic-design`, `product-milestone-planning`

**Implement** — `code-feature`, `code-issue`, `code-debt`, `code-tdd`

**Verify** — `code-review`, `code-verify`, `testing-plan`, `testing-security`, `testing-accessibility`, `testing-performance`, `testing-compliance`, `testing-session`

**Ship** — `deploy-ship`

I can explain any of these skills individually, or I can show you what's used at various levels of structure. Just tell me where you want to go.

---

**Option 1d — Approaching an existing project:**
Present the following content verbatim:

---

SweetClaude can drop into a codebase that's already in progress. Here's how it typically gets oriented.

First, it does a read-only survey — structure, stack, test coverage, README, recent git history, any existing docs. No changes, just observation.

From there it builds a picture of where the project is in its lifecycle and what's missing. A mature codebase with no tests gets a different recommendation than a greenfield project mid-build. It'll flag things like: no architecture doc, no defined personas, gaps in test coverage, security surface that hasn't been reviewed.

Then it proposes a starting point — usually one of three:
- **Catch up on artifacts** — write the docs and decisions that should exist but don't, so SweetClaude has solid ground to work from
- **Jump straight to active work** — pick up the next logical task and start building, letting artifacts accumulate naturally as you go
- **Run a health check** — get a structured assessment of the project's shape before deciding anything

Before doing any of this, SweetClaude will recommend creating a safety branch — a snapshot of exactly where things are now, so you always have a clean rollback point.

Want to try this on a current project (safety branch first), or keep exploring?

---

**Option 2 — Operating Modes:**
Present the following content verbatim, then show the follow-up menu below.

---

SweetClaude doesn't lock you into a single methodology. Think of it as a dial, not a switch. There are four named modes on that dial — each one enforcing a different level of structure:

**Flow Mode** — the lightweight end. No phase gates, no required artifacts, no ceremony. SweetClaude observes quietly and builds what you ask. Right for exploration, prototypes, and personal projects where speed matters more than auditability.

**Kanban** — adds a WIP limit (3 in-progress items, hard enforced). Keeps work flowing without piling up. Right for continuous delivery without sprints.

**Shape Up** — 6-week cycles with pitches and a betting table. No backlog — all work enters through approved pitches. A hard gate prevents implementation until the betting table approves the pitch. Right for product teams that want fixed appetite and variable scope.

**Agile** — sprint-based execution. You must have an active sprint to implement. Right for teams running structured iteration cycles.

Most solo developers start in Flow Mode and dial up as the project matures. You can change mode at any time — even mid-project.

There's also **John Wick mode** — an experimental, fully autonomous SDLC pipeline that runs discovery through PR with minimal human intervention. It uses TDD Level 3, subagent isolation, QA caucus review, and a full phase sequence. Not for everyday use — but powerful for teams that want maximum automation and discipline. Invoke with `/sweetclaude:john-wick`.

---

Then use AskUserQuestion with these four options:

- **Help me choose a level** — answer four quick questions and get a recommended starting level
- **What actually changes at each level** — what's on and off at each level, and how they differ
**Option 2b — What actually changes at each level:**
Present the following content verbatim:

---

Here's what each mode actually enforces:

**Flow Mode**
- Conversational routing — describe what you want, SweetClaude figures out what to run
- TDD Level 1 — tests written before implementation, single context
- No phase gates, no required artifacts
- Quietly accumulates thin versions of key artifacts in the background (mini brief, architecture sketch, decision log entries) — so if you decide to switch modes later, there's something to build from
- Right for: exploration, prototypes, personal projects

**Kanban**
- TDD Level 1
- WIP limit of 3 enforced as a hard block — can't start new work until something finishes
- Sprint skills disabled — continuous flow only
- Right for: solo or small teams doing continuous delivery without sprint ceremonies

**Shape Up**
- TDD Level 2 — subagent isolation between test writer and implementer
- Betting table required before any implementation begins (hard gate)
- 6-week cycles, no backlog — all work enters through approved pitches
- Ship/no-ship decision required at end of each cycle
- Right for: product teams who want fixed appetite and real scope control

**Agile**
- TDD Level 2
- Active sprint required to implement (hard gate)
- Sprint close required before ship
- Right for: teams running structured iteration with sprint ceremonies

**John Wick** *(experimental)*
- TDD Level 3 — full subagent isolation, QA caucus, mutation testing available
- Fully autonomous — runs discovery through PR with minimal human intervention
- Hard gates at key decisions (PRD approval, design review, final PR)
- Right for: when you want maximum automation and discipline end-to-end

You can switch modes at any time — even mid-feature.

---

- **How to change levels mid-project** — the mechanics of dialing up or down without losing work
- **Start a conversation about something else** — ask anything or describe your situation

**Option 2c — How to change levels mid-project:**
Present the following content verbatim:

---

Changing modes is a conversation, not a config file. Just tell SweetClaude what you want:

> "Let's dial this up — I want full TDD from here on."
> "We're just exploring right now, let's switch to Flow Mode."
> "We're getting close to production — switch to Agile."

SweetClaude updates your project state and applies the new mode from that point forward. Work already done stays as-is — nothing gets undone or invalidated.

**When switching to a more structured mode**, you may have gaps. If you've been in Flow Mode and want to move to Shape Up or Agile, you won't have a product brief, architecture doc, or decision log yet. SweetClaude will flag what's missing and offer to catch up — either in a dedicated session or as you go. You don't have to fill everything in at once.

**When switching to a lighter mode**, nothing gets removed. Your existing artifacts stay and SweetClaude keeps referencing them. You're just turning off the guardrails for new work — useful when you want to move fast on a known problem without ceremony.

You can also set mode per-task rather than globally: "just do this one thing in Flow Mode" works fine even if your project is otherwise running Agile.

---

Use AskUserQuestion with these four options:
- **Help me choose a mode** — answer four quick questions and get a recommendation
- **What actually changes at each mode** — side-by-side breakdown of what's on and off
- **Tell me about your project** — start a conversation about how SweetClaude would approach your specific situation
- **Something else** — ask anything

For "Help me choose a mode": route to Option 2a content.
For "What actually changes at each mode": route to Option 2b content.
For "Tell me about your project": route to Option 4 content.

**Option 2a — Help me choose a level:**

Open with: "I'm going to ask you four quick questions, then I'll give you a recommendation."

Ask each question one at a time using AskUserQuestion:

**Q1** — plain text prompt: "What are you building?"

**Q2** — AskUserQuestion: *Where is it now?*
- Just an idea
- Exploring / early prototyping
- Prototype built
- Actively shipping

**Q3** — AskUserQuestion: *What kind of project?*
- Hobby / side project
- Internal company tool
- B2C product
- B2B product

**Q4** — AskUserQuestion: *Does the data or user base create compliance requirements?*
- No
- Possibly — not sure
- Yes (HIPAA, GDPR, SOC 2, PCI, etc.)

Synthesize all four answers into one of these modes:
- **Flow Mode** — conversational, minimal process, no gates
- **Kanban** — WIP-limited continuous flow, light TDD
- **Shape Up** — pitch-driven 6-week cycles, TDD Level 2, betting table gate
- **Agile** — sprint-based, TDD Level 2, structured iteration

Present the recommended level with a one-sentence rationale explaining why it fits their situation.

Then ask using AskUserQuestion: "Want to explore this further or give it a try?"
- Explore further
- Give it a try

**If "Give it a try":**
> "Great. Start a Claude Code session in your project folder. When Claude starts up, just run `/sweetclaude:go` — it'll detect where you are and route to the right starting point. If SweetClaude isn't set up yet, it'll walk you through init and mode selection. If it's already running, just describe what you want to work on and it takes it from there.
>
> You can always come back to `/sweetclaude:help` if you have questions along the way."

**If "Explore further":**
Use AskUserQuestion with these four options:
- **Tell me more about [recommended mode]** — what a typical session looks like in that mode day-to-day
- **Compare it to the other modes** — side-by-side of what's on and off across all four
- **How do I switch modes later if I change my mind?** — the mechanics of changing modes mid-project
- **Something else** — ask anything

For "Tell me more about [recommended mode]": describe a concrete day-in-the-life session in that mode — what the user says, what SweetClaude does, what artifacts get produced, what gates (if any) they encounter. Keep it specific to the recommended mode, not generic.

For "Compare it to the other modes": route to Option 2b content (What actually changes at each level).

For "How do I switch modes later": route to Option 2c content (How to change modes mid-project).

**Option 3 — Workflows and Skills:**
Present the following content verbatim, then show the follow-up menu below.

---

SweetClaude has deep coverage across the full project lifecycle — from discovery and product definition through design, implementation, testing, and ship. Built natively on Claude Code's Skills framework and Anthropic's multi-agent architecture. You don't need to learn any of it. The single entry point is `/sweetclaude:go` — it reads your project state, figures out what to work on next, and drives the right workflow. Skills and workflows run automatically based on what you're doing.

For those who want to go deeper, skills compose into dynamic, situation-driven workflows — a feature build, for example, chains spec generation, isolated test writing, a multi-angle QA review, and implementation into a single pipeline. Workflows adapt to the project rather than following a fixed script.

The full inventory is in the skills reference: https://github.com/carson-sweet/sweetclaude/blob/main/docs/user-guide/skills-reference.md

---

Then use AskUserQuestion with these four options:

- **View all skills by phase** — see the full skill set organized by project phase
- **Explore workflow examples** — walk through what a real workflow looks like end-to-end
- **How does testing work?** — understand SweetClaude's approach to test-driven development and enforcement
- **Ask something else** — ask anything or describe your situation

**Option 3a — View all skills by phase:**
Present the following content verbatim:

---

Here's the full skill set organized by the phase where they're most commonly used:

**Discover** — `product-discovery`, `user-personas`, `product-user-focus-group`, `product-competition`, `product-parking-lot`

**Define** — `product-brief`, `product-prd`, `product-terminology`, `product-user-stories`, `product-manage-scope`

**Design** — `design-architecture`, `design-data-model`, `design-api-design`, `design-ux`, `design-user-flows`, `design-wireframes`, `design-tech-spec`, `design-solutioning-gate`, `design-manage-decisions`, `design-change-impact-analysis`, `design-ux-review`

**Plan** — `project-backlog`, `project-sprints`, `project-themes`, `project-goals`, `project-scope`, `project-epics`, `epic-design`, `product-milestone-planning`, `product-milestones`, `product-roadmap`, `product-sprint-plan`

**Implement** — `code-feature`, `code-issue`, `code-debt`, `code-tdd`

**Verify** — `code-review`, `code-verify`, `testing-plan`, `testing-security`, `testing-accessibility`, `testing-performance`, `testing-compliance`, `testing-session`, `behavioral-regression`

**Ship** — `deploy-ship`

**Ongoing** — `status`, `go`, `recap`, `session-export`, `misc-meeting-prep`, `retro`, `next-steps`

---

I can explain any of these, or give you some examples of how these are dynamically combined into workflows, or anything else — tell me where you want to go next.
- **Ask something else** — ask anything or describe your situation

**Option 3b — Explore workflow examples:**
Present the following content verbatim:

---

Here are three examples of how SweetClaude composes skills into workflows:

**Building a new feature (Structured mode)**
`code-feature` kicks off the pipeline: it generates Gherkin acceptance specs from the story, dispatches a test writer agent that produces failing tests, convenes a QA caucus that reviews the test plan from three angles, then dispatches an implementer agent to make them green. `code-review` and `code-verify` run before ship. The test writer and implementer never share context — each works in isolation.

**Responding to a production bug**
`something-broke` triages the incident, establishes a reproduction case, and identifies the root cause. `code-issue` runs the fix through a lightweight TDD cycle. `deploy-ship` handles the release. A post-mortem work item gets created automatically.

**Kicking off a new product**
`product-discovery` establishes personas and scenarios. `product-brief` produces the one-pager. `design-architecture` and `design-data-model` define the technical shape. `project-backlog` turns it into prioritized work. `sweetclaude:go` takes it from there.

In all cases, `/sweetclaude:go` is the entry point — it reads your project state and decides which workflow to run next.

---

Use AskUserQuestion with these four options:
- **Go deeper on one of these** — pick a workflow and walk through it step by step
- **Show me more workflow examples** — see examples from testing, design, or other domains
- **I want to try one of these on my project** — start a conversation about applying a workflow to your situation
- **Something else** — ask anything

For "Go deeper on one of these": ask which workflow they want (feature build / production bug / new product kickoff), then walk through it in detail — what each skill does, what the user sees at each step, what artifacts come out.

For "Show me more workflow examples": offer two or three from adjacent areas — a security review workflow, a corpus/RAG setup workflow, and a Shape Up pitch-to-implementation cycle.

For "I want to try one of these on my project": route to Option 4 content (Tell me about your project).

**Option 3c — How does testing work?:**
Present the following content verbatim:

---

SweetClaude doesn't ask you to do TDD — it enforces it. There's a difference.

Most AI coding tools will write tests if you ask. SweetClaude uses Claude Code hooks to make test discipline physically unavoidable:

- **Test-guardian hook** — blocks any edit to test files during the implementation phase. The implementer cannot modify tests to make them pass. Tests are written once, then locked.
- **Auto-test-runner hook** — runs the test suite automatically after every source file edit. You see RED or GREEN after every change, not at the end.

There are four TDD levels — you don't choose them manually, SweetClaude selects based on the operating mode and work type:

**Level 0 (Hotfix)** — Fix the immediate problem, write a regression test in the same session. No ceremony.

**Level 1 (Light)** — Tests written before implementation, all in one context. Right for simple additions and config changes.

**Level 2 (Standard)** — Test writer and implementer are separate subagents. The implementer never sees the spec — only failing tests. Test files are committed to git before implementation begins. Active in Kanban, Shape Up, and Agile modes.

**Level 3 (Full)** — Maximum isolation. Gherkin acceptance specs → test writer agent → QA caucus reviews the test plan from three independent angles → implementer agent makes tests go green. Active in John Wick mode and available on demand.

The rule underneath all of this: **never modify test files to make them pass. Fix the implementation.**

---

Ask: "Want to go deeper on any of this, or tell me what you're building and I'll show you what TDD looks like in practice?"

**Option 4 — Tell me about your project:**

Open with: "Tell me about your project. I will probably have questions, then I'll share how I'd approach it with you."

The goal of this conversation is to arrive at three things:
1. The right operating mode — how much structure and discipline fits this project
2. Whether security or compliance work is needed — ask briefly about what data the app handles and who the users are (consumers, employees, regulated industries)
3. A concrete recommendation for how to start

Keep it conversational. Ask one question at a time. Cover:
- What are they building and where are they in the process
- Who are the users and what data does the app handle
- Are they working alone or with a team
- Is this exploratory or going to production

After a few exchanges, offer to look directly at the project to give a more grounded recommendation:

> "If you'd like, I can take a look at your project directly — read the codebase, git history, and any existing docs — and give you a more specific picture of how I'd approach it. I won't make any changes. No files touched, no commits, nothing written. Read-only, full stop."

If they agree, do a read-only survey (structure, stack, existing tests, README, recent commits) and return a concrete recommendation covering:

- **First: create a safety branch.** Before doing anything else, strongly recommend they create a snapshot branch (`git checkout -b pre-sweetclaude-snapshot`) so they have a clean rollback point if they ever want to undo everything SweetClaude has touched. Frame it as a seatbelt — takes 5 seconds, costs nothing, and means they can always get back to exactly where they are right now.
- **Suggested operating mode** — based on the conversation and what was observed in the project
- **First steps** — concrete next actions to get started with SweetClaude on this project
- **Security/compliance flags** — anything worth knowing based on the data and user types described

**Option 5 — Other (freeform):**
The user typed their own question or request. Answer directly and conversationally.

**"skip the welcome" (any time the user says this):**
Set `skip_help_welcome: true` in `.sweetclaude/state/sweetclaude.yaml`:

```bash
python3 - << 'PY'
import yaml, tempfile, os
path = '.sweetclaude/state/sweetclaude.yaml'
try:
    with open(path) as f:
        d = yaml.safe_load(f) or {}
except FileNotFoundError:
    d = {}
d['skip_help_welcome'] = True
with tempfile.NamedTemporaryFile('w', dir=os.path.dirname(path), suffix='.tmp', delete=False) as tmp:
    yaml.dump(d, tmp, default_flow_style=False, allow_unicode=True, sort_keys=False)
    tmp_name = tmp.name
os.replace(tmp_name, path)
print("Done.")
PY
```

Confirm it's set, then say: "Done — I'll skip the intro next time. Tell me what you need and let's see how I can help."

## Step 3 (skip path): Conversation-only entry

If `skip_help_welcome` was true, say:

> "Tell me what you need and let's see how I can help."

Then answer directly and conversationally.

## After any answer

Continue the conversation naturally. Don't ask "anything else?" — just stay available. The user will redirect if they want to explore something different.

## Learnings visibility

If the user asks "what have you learned about me?" or "show my preferences":

```bash
python3 - << 'PY'
import yaml
try:
    d = yaml.safe_load(open('.sweetclaude/state/sweetclaude.yaml'))
    learnings = d.get('learnings', [])
    if learnings:
        print("Here's what I've learned from our sessions:\n")
        for i, l in enumerate(learnings, 1):
            print(f"{i}. {l}")
    else:
        print("No learnings recorded yet.")
except:
    print("Can't read learnings right now.")
PY
```

Offer: "Want to remove any of these? Just tell me which number."

If they specify one, remove it:

```bash
python3 - .sweetclaude/state/sweetclaude.yaml INDEX << 'PY'
import sys, yaml, tempfile, os
path, idx = sys.argv[1], int(sys.argv[2]) - 1
with open(path) as f: d = yaml.safe_load(f)
learnings = d.get('learnings', [])
if 0 <= idx < len(learnings):
    removed = learnings.pop(idx)
    with tempfile.NamedTemporaryFile('w', dir=os.path.dirname(path), suffix='.tmp', delete=False) as tmp:
        yaml.dump(d, tmp, default_flow_style=False, allow_unicode=True, sort_keys=False)
        tmp_name = tmp.name
    os.replace(tmp_name, path)
    print(f"Removed: {removed}")
else:
    print("Index out of range.")
PY
```
