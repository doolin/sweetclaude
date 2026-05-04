<img src="sweetclaude.png" alt="SweetClaude" width="180" align="left">

# SweetClaude

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

A Claude Code plugin based on the Skills 2.0 framework that implements full product / project lifecycle workflows, from concept to production maintenance.

SweetClaude exists to take a project from idea through discovery, architecture, test-driven implementation, and shipped code as a single coherent workflow — with discipline enforced, not suggested. It was originally built as my own personal Claude Code toolchain. It quickly evolved to support early-stage founders, technical solopreneurs, and senior independent consultants who want structure — from strategy to deployment, with variable discipline levels depending on your project needs.

SweetClaude has 70+ skills under the hood, mostly purpose-developed and refined. Some code-related skills leverage Jesse Vincent's excellent Superpowers project.  These skills are combined into workflows that operate in one of four modes:

- **Flow** — Solo dev in early exploration. No ceremony. SweetClaude observes quietly and stays out of the way.
- **Kanban** — Continuous delivery, no fixed sprints. Issues flow through a status board at whatever pace fits.
- **Level Up** — 6-week cycles with pitches. Fixed appetite, variable scope. Structure without standups.
- **Agile** — Sprint-based. Velocity tracking, backlog grooming, retrospectives. Full rhythm.

You can start with one mode and migrate later. So start with vibe-coding in flow mode, which will passively and quietly collect artifacts as you go. When you're ready for Kanban or higher-level structures, those artifacts will be there, so you're not starting from zero.

## Quick Start

```bash
git clone https://github.com/carson-sweet/sweetclaude.git
cd sweetclaude && ./install.sh
```

Then go to your project and run:

```
/sweetclaude introduce me to sweetclaude
```



## Basic Usage

Inside Claude Code, one entry point handles everything:  `/sweetclaude` 

That's it. Install SweetClaude and use the single entry point followed by what you want to do. Describe what you want in plain English — "I want to start building X", "pick up where I left off", "what should I work on next" — or just press enter for a status prompt. SweetClaude will ask questions if needed and the orchestrator detects your project state, routes to the right skill, and collaborates with you - it handles the red tape, you do the thinking.

You can use SweetClaude to start a new effort from scratch, or have it adopt an existing project. Just point to any documents you might have — backlog, roadmaps, design, etc. — it will assess and migrate what you have and then help you fill in the gaps.

→ [Full install options, updating, uninstalling](INSTALL.md)
→ [First session walkthrough](QUICKSTART.md)
→ [All skills by category](docs/user-guide/skills-reference.md)



## First Steps

Once SweetClaude is installed, here are some things to try. You'll quickly get oriented.

* `/sweetclaude help`
* `/sweetclaude give me a quick overview of what you can do`
* `/sweetclaude tell me about the product development lifecycle phases you use`
* `/sweetclaude tell me about the differences in flow mode, kanban mode, level up mode, and agile mode`
* `/sweetclaude help me choose the best mode for my project` 
* `/sweetclaude give me a breakdown of all skills by product lifecycle phase`
* `/sweetclaude explain how you would onboard my existing project`
* `/sweetclaude tell me about your RAG enabled design and doc management`



## Major Features

- **Discovery-first pipeline** — Product discovery derives compliance requirements (GDPR, HIPAA, PCI DSS) from your actual users and data. That context flows automatically into architecture, tech spec, data model, and final code review — not a checkbox at the end.
- **Enforced TDD at four levels** — At the highest level, test writer and implementer are separate AI agents in isolated contexts. Test files are physically blocked from modification during implementation by PostToolUse hooks. Tests run after every source edit.
- **Persistent phase state** — `.sweetclaude/` tracks phase, decisions, assumptions, and scope changes in git. Return after weeks and `/sweetclaude` re-orients without you re-explaining anything.
- **Mockup pipeline** — Design UI components in an isolated Vite + React sandbox before touching production code. Graduate approved mockups with acceptance criteria extracted automatically.
- **Corpus management** — Four-step pipeline (consolidate → triage → reconcile → promote) for messy document collections, with local RAG indexing for semantic search. No external services.
- **Behavioral contracts** — 15 behavioral properties tested against each Claude model version. Hook-enforced properties are deterministic; instruction-guided properties are validated by a regression suite after every model upgrade.

**Key architectural decisions:**

- **Single front door** — `/sweetclaude` is the only command you need. Describe what you want in plain English, and it routes to the right skill. Or just run it for a status and routing prompt.
- **Skills under the hood** — Every capability is a skill with defined entry criteria, deference levels, and exit gates. Structured contracts replace freeform prompting. Skills are accessible directly if you know what you want.
- **Hooks for enforcement** — TDD rules and session discipline are enforced by shell hooks (PreToolUse/PostToolUse), not instructions. Instructions can drift; hooks cannot.
- **Agent isolation** — Test writer and implementer run in separate AI contexts with restricted tool sets (`tools:` frontmatter). The implementer never sees the spec — only failing tests.
- **State as git history** — `.sweetclaude/sweetclaude.yaml` should be committed to git, not gitignored. Phase progression, decisions, and assumptions are project history, not session memory.
- **Deference levels** — Collaborative (stop after every sub-step), Guided (stop at major decisions), Autonomous (stop only at phase gates). Set in state, changeable mid-session.



## How It Works

SweetClaude is a Claude Code plugin. After install, all skills are available as slash commands in every Claude Code session. You can also load it for a single session with `--plugin-dir` without a global install.

**State tracking.** SweetClaude creates a `.sweetclaude/` directory in your project. The unified state file `.sweetclaude/sweetclaude.yaml` tracks phase, decisions, assumptions, scope changes, and feature activation. Commit it to git — it is project history, not cache. When you return, `/sweetclaude` reads state and re-orients without you re-explaining anything.

**Enforcement.** TDD hooks physically block test file modification during implementation (hook-enforced, not advisory) and run tests automatically after every source edit. At higher TDD levels, test writer and implementer are separate AI agents in separate contexts — the implementer never sees the spec, only the failing tests.

**Behavioral stability.** Not all behavioral properties are guaranteed equally. Hook-enforced properties are deterministic and version-stable. Protocol Guardian (`/sweetclaude:guardian-on`) upgrades instruction-guided properties to deterministic enforcement for a session. The 15-contract behavioral regression suite validates properties after model upgrades.

**Deference levels.** Collaborative (stop after every sub-step), Guided (stop at major decisions), Autonomous (stop only at phase gates). Changeable mid-session.

For a full explanation of the architecture and design decisions behind SweetClaude → [How It Works](docs/user-guide/how-it-works.md)



## Common Commands

Even though the single entry point will support you completely, you can invoke most of the under-the-hood commands manually if you wish. These are the most common. You can also refer to the [complete skills reference](docs/user-guide/skills-reference.md).

### Primary Entry Point
| Command | What it does |
|---|---|
| `/sweetclaude` | Everything. Describe what you want, or run with no arguments for a status prompt. Routes to setup, go, feature offers, or any skill based on project state and plain-English input. |
| `/sweetclaude:help` | Conversational help — describe what you want to do, browse features, or ask questions |

### Housekeeping
| Command | What it does |
|---|---|
| `/sweetclaude:off` | Suspend SweetClaude — preserves all artifacts, reactivate with `/sweetclaude` |
| `/sweetclaude:purge` | Delete all SweetClaude artifacts — recommends a backup branch, shows all files, requires "I understand". **Taking a branch snapshot before is highly recommended.** |
| `/sweetclaude:update` | Fetch latest SweetClaude from GitHub and sync to all projects |
| `/sweetclaude:fix-sweetclaude` | Audit and repair SweetClaude configuration |

### Advanced
| Command | What it does |
|---|---|
| `/sweetclaude:behavioral-regression` | Run the 15-contract behavioral test suite — validates that the current model version honors SweetClaude's behavioral contracts. Run after any Claude model upgrade. **15/15 passing on claude-sonnet-4-6 (2026-05-01).** [Contract status by model version →](docs/user-guide/behavioral-contracts.md) |
| `/sweetclaude:guardian-on` | Enable Protocol Guardian — enforces skill invocations and protocol steps for the session |
| `/sweetclaude:guardian-off` | Disable Protocol Guardian |
| `/sweetclaude:session-export` | Export a Claude.ai session as a structured document |
| `/sweetclaude:usage` | View, enable, or disable local usage tracking |

Individual workflow skills (product, design, code, testing, corpus) are accessible directly if you know what you want, but `/sweetclaude` routes to all of them automatically.

→ [All skills by category](docs/user-guide/skills-reference.md)



## Dependencies

SweetClaude orchestrates these plugins — it does not fork or modify them:

| Dependency | License | Required | Role |
|---|---|---|---|
| [Superpowers](https://github.com/obra/superpowers) | MIT | Required for code/TDD features | Dev mechanics (plans, worktrees, debugging, code review). Not required for strategy-skills-only install. |
| [mcp-local-rag](https://www.npmjs.com/package/mcp-local-rag) | MIT | Optional | Local semantic search — per-project vector index, no external services |

For dependency risk, failure modes, and contingency plans → [Platform Dependencies](docs/user-guide/platform-dependencies.md)



## License

[GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0-or-later) — free to use, modify, and distribute. No restrictions for personal or commercial tools you build. AGPL obligations activate only if you deploy SweetClaude as a network service offered to others — in that case, you must make your modified source available under the same license. See [LICENSE](LICENSE) for full terms.

Contact the project owner with questions about licensing.



## Contribute

Contributions welcome. SweetClaude is built by solo developers, for solo developers.

**Looking for a technical co-maintainer.** SweetClaude is currently maintained by one person. The areas that need a second reviewer — the hook system, migration registry, and orchestration layer — require someone who understands how the phase pipeline works end to end. If you have read through the codebase and want meaningful ownership of a growing open-source project, open an issue introducing yourself. See [what requires full framework knowledge](CONTRIBUTING.md#what-requires-full-framework-knowledge) for the scope.

For skill improvements, documentation, walkthroughs, and examples — read [CONTRIBUTING.md](CONTRIBUTING.md) for where to start. Questions and ideas belong in [GitHub Discussions](https://github.com/carson-sweet/sweetclaude/discussions). Bugs and PRs go to Issues.

<p align="center">
  <img src="sweetclaude-workshop.png" alt="SweetClaude Workshop" width="600">
</p>













## Support

If you're getting value from SweetClaude, consider [buying me a coffee](https://ko-fi.com/carsonsweet). Which in reality means you're moving dollars from my coffee budget to [my dog Smushford's](http://instagram.com/smushford) treat budget. 

Smushford thanks you.
<p align="center">
  <img src="smushford.png" alt="Smushford Wellington DuBois III" width="400">
</p>




