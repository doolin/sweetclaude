# Installing SweetClaude

## Prerequisites

| Dependency | Check | Install |
|---|---|---|
| [Claude Code](https://claude.ai/code) | `claude --version` | [Install guide](https://docs.anthropic.com/en/docs/claude-code/getting-started) |
| Git | `git --version` | [git-scm.com](https://git-scm.com/downloads) |
| [GitHub CLI](https://cli.github.com/) | `gh --version` | `brew install gh` or [cli.github.com](https://cli.github.com/) |
| Node.js (for RAG) | `node --version` | [nodejs.org](https://nodejs.org/) — optional, needed only for corpus management and semantic search |

Claude Code requires an Anthropic subscription. [Superpowers](https://github.com/obra/superpowers) (minimum version 5.0.7) is required for code and TDD features; not required for strategy-skills-only installs.

---

## Full Install

```bash
git clone https://github.com/carson-sweet/sweetclaude.git ~/dev/sweetclaude
cd ~/dev/sweetclaude
./install.sh
```

> **Note:** Clone to `~/dev/sweetclaude`. Some skills reference scripts at `~/dev/sweetclaude/scripts/` and require the repository to remain at that path after install.

The installer:
- Checks prerequisites (Claude Code, Git; Superpowers for full install)
- Backs up your existing `~/.claude/` configuration
- Scans for conflicting plugins and offers to clean them up
- Copies skills, hooks, agents, rules, and config to `~/.claude/`
- Wires TDD enforcement hooks into `settings.json`
- Generates `uninstall.sh` and `restore-config.sh` for clean removal

After install, all skills are available as `/sweetclaude:skill-name` in every Claude Code session. The first time you run `/sweetclaude:go` in a project, it will walk through setup and run a short mode-assessment interview to configure enforcement for your workflow (Flow, Kanban, Level Up, or Agile).

---

## Strategy Skills Only

If you want product thinking, strategy, and corpus management — without code and TDD phases:

```bash
./install.sh --strategy-skills-only
```

Installs strategy, product, corpus, and orchestration skills. No TDD hooks, no subagents, no Superpowers required. Upgrade to the full install later by running `./install.sh`.

---

---

## Updating

```bash
/sweetclaude:update
```

Fetches the latest version from GitHub and syncs to all installed locations. Shows what changed, migrates state schemas if needed, and prompts to onboard any skills marked `uninitialized`.

---

## Optional Integrations

### Firecrawl (web research enhancement)

[Firecrawl](https://firecrawl.dev) adds JavaScript-rendered page extraction, structured schema output, and autonomous multi-page research to `sweetclaude:product-research` and `sweetclaude:product-competition`. Both skills degrade gracefully if Firecrawl is absent.

1. Create an account at [firecrawl.dev](https://firecrawl.dev) — Hobby tier ($16/mo) or free trial.
2. Add the MCP server to Claude Code settings:
   ```json
   {
     "mcpServers": {
       "firecrawl": {
         "command": "npx",
         "args": ["-y", "@firecrawl/mcp-server"],
         "env": { "FIRECRAWL_API_KEY": "YOUR_API_KEY" }
       }
     }
   }
   ```
3. Restart Claude Code. The research and competition skills will automatically detect Firecrawl and use it when present.

---

## Uninstalling

```bash
./uninstall.sh
```

Run from the repository directory (`~/dev/sweetclaude`). The installer generated this script during install. It restores your pre-install `~/.claude/` configuration from the backup.

To suspend SweetClaude for one project without uninstalling globally:

```bash
touch .sweetclaude/disabled
```

Run `/sweetclaude` to reactivate.
