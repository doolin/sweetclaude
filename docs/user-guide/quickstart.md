# Quick Start

You have SweetClaude installed. Here is how to use it.

---

## Your First Session

**Everything starts here:**

```
/sweetclaude
```

Detects where you are and routes automatically. Empty folder → setup. Active project → picks up where you left off. No project state yet → walks through setup, product discovery, and hands off to the pipeline. Pass plain-English arguments to skip the prompt: `/sweetclaude I need to fix a bug in auth`.

**Suspend or remove SweetClaude:**

```
/sweetclaude:off    # suspend — preserves all artifacts, reactivate with /sweetclaude
/sweetclaude:purge  # delete all artifacts — warns and requires typed confirmation first
```

**Get help:**

```
/sweetclaude:help
```

Conversational assistant. Describe what you want to do and it shows you how.

---

## Common Starting Points

### "I have an idea for a product but have not started building anything"

Run `/sweetclaude` in an empty folder. SweetClaude will:
1. Set up the project (git, directory structure, CLAUDE.md)
2. Run a short mode-assessment interview (5 questions) to configure enforcement — Flow, Kanban, Level Up, or Agile
3. Ask what you want to build
4. Run product discovery — problem framing, personas, optional competitive landscape
5. Hand off to the product definition pipeline (brief, PRD, architecture, implementation)

### "I have a codebase and want to start using SweetClaude"

Run `/sweetclaude` in your project folder. SweetClaude will:
1. Detect the existing project
2. Create a safety snapshot branch before touching anything
3. Scan your code, tests, docs, and issues
4. Run a short mode-assessment interview to configure enforcement for your workflow
5. Interview you about current state and biggest concerns
6. Determine where the project sits in its lifecycle
7. Offer to address your immediate concerns first

### "I need to build a specific feature"

Run `/sweetclaude` and describe what you need. SweetClaude classifies the work and routes to the right starting point.

### "I have a GitHub issue to implement"

Run `/sweetclaude` and mention the issue number or paste the title. SweetClaude reads the issue, proposes a plan, implements with TDD, verifies, updates docs, and opens a PR.

### "Production is broken"

```
/sweetclaude:something-broke
```

Classifies severity, decides fix vs. rollback, and routes to the hotfix workflow: DIAGNOSE → IMPLEMENT → SHIP → POST-MORTEM. Skips ceremony, keeps discipline.

### "I have a pile of messy strategy files"

Tell SweetClaude "I have a pile of documents I need to organize." Four-step corpus pipeline: consolidate → triage → reconcile → promote. Originals are never deleted.

---

## What to Read Next

- End-to-end scenario walkthroughs → [Walkthroughs](walkthroughs.md)
- Full command reference → [Skills Reference](skills-reference.md)
- How SweetClaude's architecture works → [How It Works](how-it-works.md)
- Honest answers to common questions → [FAQ](faq.md)
