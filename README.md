<p><img src="sweetclaude.png" alt="SweetClaude" width="180"></p>

# SweetClaude

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

A discipline layer for Claude Code — phase gates, TDD enforcement, and multi-agent review that make AI-assisted development reproducible and auditable.

SweetClaude adds structure to Claude Code: phase gates that enforce exit criteria before advancing, TDD hooks that physically prevent test/implementation drift, and a QA caucus that isolates reviewers so findings stay honest. It is the right tool when quality and traceability matter more than raw velocity. It was originally built as my own personal Claude Code toolchain and quickly evolved to support early-stage founders, technical solopreneurs, and senior independent consultants who want structure — from strategy to deployment, with variable discipline levels depending on your project needs.

SweetClaude has 70+ skills under the hood, all purpose-developed and refined. These skills are combined into workflows that operate in one of four modes:

- **Flow** — Solo dev in early exploration. No ceremony. SweetClaude observes quietly and stays out of the way.
- **Kanban** — Continuous delivery, no fixed sprints. Issues flow through a status board at whatever pace fits.
- **Level Up** — 6-week cycles with pitches. Fixed appetite, variable scope. Structure without standups.
- **Agile** — Sprint-based. Velocity tracking, backlog grooming, retrospectives. Full rhythm.

You can start with one mode and migrate later. So start with vibe-coding in flow mode, which will passively and quietly collect artifacts as you go. When you're ready for Kanban or higher-level structures, those artifacts will be there, so you're not starting from zero.

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

> **Note:** TDD enforcement hooks require a one-time setup after marketplace install. Run `/sweetclaude:on` in your first project to wire them, or use the manual install path below if you prefer.

**Manual install** (full hook wiring, no extra step):

```bash
git clone https://github.com/carson-sweet/sweetclaude.git ~/dev/sweetclaude
cd ~/dev/sweetclaude && ./install.sh
```



## Basic Usage

Inside Claude Code, the primary command is `/sweetclaude:go`.

Install SweetClaude and run `/sweetclaude:go` with what you want to do — or with no arguments to pick up where you left off. Describe what you want in plain English — "I want to start building X", "pick up where I left off", "what should I work on next". SweetClaude will ask questions if needed and the orchestrator detects your project state, routes to the right skill, and collaborates with you — it handles the red tape, you do the thinking.

You can use SweetClaude to start a new effort from scratch, or have it adopt an existing project. Just point to any documents you might have — backlog, roadmaps, design, etc. — it will assess and migrate what you have and then help you fill in the gaps.

→ [Full install options, updating, uninstalling](docs/user-guide/install.md)

→ [First session walkthrough](docs/user-guide/quickstart.md)

→ [All skills by category](docs/user-guide/skills-reference.md)



## First Steps

Once SweetClaude is installed, here are some things to try. You'll quickly get oriented.

* `/sweetclaude:help`
* `/sweetclaude:go give me a quick overview of what you can do`
* `/sweetclaude:go tell me about the product development lifecycle phases you use`
* `/sweetclaude:go tell me about the differences in flow mode, kanban mode, level up mode, and agile mode`
* `/sweetclaude:go help me choose the best mode for my project`
* `/sweetclaude:go give me a breakdown of all skills by product lifecycle phase`
* `/sweetclaude:go explain how you would onboard my existing project`
* `/sweetclaude:go tell me about your RAG enabled design and doc management`



## Major Features

- **Discovery-first pipeline** — Compliance requirements (GDPR, HIPAA, PCI DSS) flow from user and data discovery into architecture and code review automatically — not a checkbox at the end.
- **Enforced TDD at four levels** — At the highest level, test writer and implementer are separate AI agents. Test files are physically blocked from modification during implementation by hooks. Tests run after every source edit.
- **Persistent phase state** — `.sweetclaude/` tracks phase, decisions, and scope changes in git. Return after weeks and `/sweetclaude:go` re-orients without re-explaining.
- **Mockup pipeline** — Design UI components in an isolated Vite + React sandbox before touching production code. Graduate approved mockups with acceptance criteria extracted automatically.
- **Corpus management** — Four-step pipeline (consolidate → triage → reconcile → promote) for messy document collections, with local RAG indexing. No external services.
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

<p>
  <img src="sweetclaude-workshop.png" alt="SweetClaude Workshop" width="600">
</p>













## Support

If you're getting value from SweetClaude, consider [buying me a coffee](https://ko-fi.com/carsonsweet). Which in reality means you're moving dollars from my coffee budget to [my dog Smushford's](http://instagram.com/smushford) treat budget. 

Smushford thanks you.
<p>
  <img src="smushford.png" alt="Smushford Wellington DuBois III" width="400">
</p>




