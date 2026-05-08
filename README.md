<img src="sweetclaude.png" alt="SweetClaude" width="180" style="display:block;margin-left:0;">

# SweetClaude

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

A software development partner for the full project lifecycle — from the first idea through design, implementation, testing, and ship. **SweetClaude is the only Claude Code plugin that teaches itself through conversation** — run `/sweetclaude:help` and it walks you through what it is, how it works, and whether it's right for your project before touching a single file. You're always in control.

SweetClaude adapts to your working style. Start with vibe-coding in Flow Mode — no ceremony, no gates, SweetClaude quietly collects artifacts as you go. When you're ready for more structure, switch to Kanban, Shape Up, or Agile — the artifacts you've accumulated are already there, so you're not starting from zero. Or apply full enterprise-class discipline from day one: phase gates, TDD pipelines with subagent isolation, QA caucuses, architecture reviews, and security gates. The framework adjusts to the project, not the other way around.

SweetClaude right if quality and traceability matter. Wrong tool if you just want to go faster — we suggest [GStack](https://github.com/garry-tan/gstack) if speed is your primary goal.

SweetClaude has over 100 skills built natively on Claude Code's Skills framework and Anthropic's multi-agent architecture. These skills compose into dynamic, situation-driven workflows across four operating modes:

* **Flow Mode** — No ceremony. SweetClaude observes quietly, builds what you ask, and collects thin artifacts in the background.
* **Kanban** — WIP-limited continuous flow. Hard block at 3 in-progress items. No sprints.
* **Shape Up** — 6-week cycles with pitches and a betting table. Fixed appetite, variable scope.
* **Agile** — Sprint-based. Active sprint required to implement.

There's also **John Wick mode** *(experimental and dangerous)* — a fully autonomous SDLC pipeline from discovery to merged PR. TDD Level 3, subagent isolation, QA caucus, hard gates at key decisions. Not for everyday use — but nothing else comes close for maximum automation. Fast, quiet, admittedly dangerous - but disciplined. No loose ends.  `/sweetclaude:john-wick`

SweetClaude was built for software development, but has also been used successfully for academic research, product marketing strategy, and other knowledge-intensive work.

Requires [Claude Code](https://claude.ai/code) and an Anthropic subscription.

## Quick Start

Inside Claude Code:

```
/plugin marketplace add https://github.com/carson-sweet/sweetclaude
/plugin install sweetclaude@sweetclaude
```

Then go to your project and run:

```
/sweetclaude:go introduce me to sweetclaude
```

**Manual install:**

```bash
git clone https://github.com/carson-sweet/sweetclaude.git
cd sweetclaude && ./install.sh
```



## Basic Usage

Inside Claude Code, the primary command is `/sweetclaude:go`.

Use `/sweetclaude:go` followed by what you want to do, in plain English — "show me milestones and sprints", "let's see the backlog", I want to start building X", "what should I work on next".  Or use `/sweetclaude:go` with no arguments to just pick up where you left off. SweetClaude will ask questions if needed and the orchestrator detects your project state, routes to the right skill, and collaborates with you — it handles the red tape, you do the creating.

You can use SweetClaude to start a new effort from scratch, or have it adopt an existing project. Just point to any documents you might have — backlog, roadmaps, design, etc. — it will assess and migrate what you have and then help you fill in the gaps.

→ [Full install options, updating, uninstalling](docs/user-guide/install.md)

→ [First session walkthrough](docs/user-guide/quickstart.md)

→ [All skills by category](docs/user-guide/skills-reference.md)



## First Steps

Once SweetClaude is installed, here are some things to try. You'll quickly get oriented.

* `/sweetclaude:help` (this is the single most important first step, you'll get a guided tour)
* `/sweetclaude:go give me a quick overview of what you can do`
* `/sweetclaude:go tell me about the product development lifecycle phases you use`
* `/sweetclaude:go tell me about the differences in flow mode, kanban mode, shape up mode, and agile mode`
* `/sweetclaude:go help me choose the best mode for my project`
* `/sweetclaude:go give me a breakdown of all skills by product lifecycle phase`
* `/sweetclaude:go explain how you would onboard my existing project`
* `/sweetclaude:go tell me about your RAG enabled design and doc management`



## Major Features

- **Discovery-first pipeline** — Compliance requirements (GDPR, HIPAA, PCI DSS) flow from user and data discovery into architecture and code review automatically — not a checkbox at the end.
- **Compliance-ready from day one** — SOC 2, GDPR, HIPAA, and PCI DSS requirements surface automatically during discovery, not as an afterthought. For regulated industries, SweetClaude produces the artifacts your auditor needs: decision logs, gate records, and traceability maps.
- **Enforced TDD at four levels** — At the highest level, test writer and implementer are separate AI agents. Test files are physically blocked from modification during implementation by hooks. Tests run after every source edit.
- **Persistent phase state** — `.sweetclaude/` tracks phase, decisions, and scope changes in git. Return after weeks and `/sweetclaude:go` re-orients without re-explaining.
- **Mockup pipeline** — Design UI components in an isolated Vite + React sandbox before touching production code. Graduate approved mockups with acceptance criteria extracted automatically.
- **Local semantic search over your design documents** — LanceDB-powered RAG, fully offline, no API keys, no external services. Index your architecture docs, data model, and product decisions so both you and SweetClaude can ask questions and get canonical answers instantly. Setup takes one command.
- **Corpus management** — Four-step pipeline (consolidate → triage → reconcile → promote) for messy document collections. Pairs with local RAG for full document lifecycle management.
- **Behavioral contracts** — 15 behavioral properties tested against each Claude model version. Hook-enforced properties are deterministic; instruction-guided properties are validated by a regression suite.



## How It Works

SweetClaude is a Claude Code plugin. After install, all skills are available as slash commands in every session. Load for a single session with `--plugin-dir` without a global install.

TDD hooks physically block test file modification during implementation and run tests automatically after every source edit. At higher TDD levels, test writer and implementer are separate AI agents — the implementer never sees the spec, only failing tests.

→ [Full architecture and design decisions](docs/user-guide/how-it-works.md)



## Common Commands

You can invoke skills directly if you know what you want. These are the most common. You can also refer to the [complete skills reference](docs/user-guide/skills-reference.md).

### Primary Commands
| Command | What it does |
|---|---|
| `/sweetclaude:go` | Pick up where you left off. Reads state, checks phase exit criteria, routes to the right skill. Pass plain-English arguments to describe what you want. |
| `/sweetclaude:status` | Project status dashboard — active work item, phase, roadmap, backlog. |
| `/sweetclaude:help` | Conversational help — describe what you want to do, browse features, or ask questions |

### Housekeeping
| Command | What it does |
|---|---|
| `/sweetclaude:off` | Suspend SweetClaude — preserves all artifacts, reactivate with `/sweetclaude:go` |
| `/sweetclaude:purge` | Delete all SweetClaude artifacts — recommends a backup branch, shows all files, requires "I understand". **Taking a branch snapshot before is highly recommended.** |
| `/sweetclaude:update` | Fetch latest SweetClaude from GitHub and sync to all projects |
| `/sweetclaude:fix-sweetclaude` | Audit and repair SweetClaude configuration |

### Advanced
| Command | What it does |
|---|---|
| `/sweetclaude:behavioral-regression` | Run the 15-contract behavioral test suite — validates that the current model version honors SweetClaude's behavioral contracts. Run after any Claude model upgrade. **15/15 passing on claude-sonnet-4-6 (2026-05-01).** [Contract status by model version →](docs/user-guide/behavioral-contracts.md) · [Full contract list →](skills/behavioral-regression/SKILL.md) |
| `/sweetclaude:guardian-on` | Enable Protocol Guardian — enforces skill invocations and protocol steps for the session |
| `/sweetclaude:guardian-off` | Disable Protocol Guardian |
| `/sweetclaude:session-export` | Export a Claude.ai session as a structured document |
| `/sweetclaude:usage` | View, enable, or disable local usage tracking |

Individual workflow skills (product, design, code, testing, corpus) are accessible directly if you know what you want, but `/sweetclaude:go` routes to all of them automatically.

→ [All skills by category](docs/user-guide/skills-reference.md)



## Dependencies

| Dependency | License | Required | Role |
|---|---|---|---|
| [mcp-local-rag](https://www.npmjs.com/package/mcp-local-rag) | MIT | Optional | Local semantic search — per-project vector index, no external services |

For dependency risk, failure modes, and contingency plans → [Platform Dependencies](docs/user-guide/platform-dependencies.md)



## License

[GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0-or-later) — free to use, modify, and distribute. No restrictions for personal or commercial tools you build. AGPL obligations activate only if you deploy SweetClaude as a network service offered to others — full terms in [LICENSE](LICENSE).

Contact the project owner with questions about licensing.



## Contribute

Contributions welcome. SweetClaude is built by solo developers, for solo developers.

**Looking for a technical co-maintainer.** SweetClaude is currently maintained by one person. The areas that need a second reviewer — the hook system, migration registry, and orchestration layer — require someone who understands how the phase pipeline works end to end. If you have read through the codebase and want meaningful ownership of a growing open-source project, open an issue introducing yourself. See [what requires full framework knowledge](CONTRIBUTING.md#what-requires-full-framework-knowledge) for the scope.

For skill improvements, documentation, walkthroughs, and examples — read [CONTRIBUTING.md](CONTRIBUTING.md) for where to start. Questions and ideas belong in [GitHub Discussions](https://github.com/carson-sweet/sweetclaude/discussions). Bugs and PRs go to Issues.

<img src="sweetclaude-workshop.png" alt="SweetClaude Workshop" width="600" style="display:block;margin-left:0;">



## Support

If you're getting value from SweetClaude, consider [buying me a coffee](https://ko-fi.com/carsonsweet). 

Which in reality means you're moving dollars from my coffee budget to [my dog Smushford's](http://instagram.com/smushford) treat budget. 

Smushford thanks you.

<img src="smushford.png" alt="Smushford Wellington DuBois III" width="400" style="display:block;margin-left:0;">



