# Installing SweetClaude

## Marketplace Install (Recommended)

Inside Claude Code, no terminal required:

```
/plugin marketplace add https://github.com/carson-sweet/sweetclaude
/plugin install sweetclaude@sweetclaude
```

All skills are immediately available. Then go to your project and run `/sweetclaude:go` to begin.

**One extra step for TDD hooks:** The marketplace install copies files but cannot modify your `settings.json`. TDD enforcement hooks (test-guardian, auto-test-runner) need to be wired once. Run `/sweetclaude:on` in your first project — it detects the install and wires them automatically.

---

## Manual Install

Preferred if you want hooks wired automatically with no extra step, or if you want the `--strategy-skills-only` variant.

### Prerequisites

| Dependency | Check | Install |
|---|---|---|
| [Claude Code](https://claude.ai/code) | `claude --version` | [Install guide](https://docs.anthropic.com/en/docs/claude-code/getting-started) |
| Git | `git --version` | [git-scm.com](https://git-scm.com/downloads) |
| [GitHub CLI](https://cli.github.com/) | `gh --version` | `brew install gh` or [cli.github.com](https://cli.github.com/) |
| Node.js (for RAG) | `node --version` | [nodejs.org](https://nodejs.org/) — optional, needed only for corpus management and semantic search |

```bash
git clone https://github.com/carson-sweet/sweetclaude.git ~/dev/sweetclaude
cd ~/dev/sweetclaude
./install.sh
```

> **Note:** Clone to `~/dev/sweetclaude`. Some skills reference scripts at `~/dev/sweetclaude/scripts/` and require the repository to remain at that path after install.

The installer:
- Checks prerequisites (Claude Code, Git, GitHub CLI)
- Backs up your existing `~/.claude/` configuration
- Scans for conflicting plugins and offers to clean them up
- Copies skills, hooks, agents, rules, and config to `~/.claude/`
- Wires TDD enforcement hooks into `settings.json`
- Generates `uninstall.sh` and `restore-config.sh` for clean removal

### Strategy Skills Only

If you want product thinking, strategy, and corpus management — without code and TDD phases:

```bash
./install.sh --strategy-skills-only
```

Installs strategy, product, corpus, and orchestration skills. No TDD hooks, no subagents. Upgrade to the full install later by running `./install.sh`.

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
