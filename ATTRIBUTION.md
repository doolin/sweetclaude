# Attribution

## Authors

Design: Carson Sweet, assisted by Anthropic, Google, and OpenAI
Code: Carson Sweet, assisted by Claude Code (Opus 4.6)
Review: Carson Sweet, assisted by GPT-5.3-Codex (OpenAI)

## Runtime Dependencies

SweetClaude requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as its host environment.

### Standalone Claude Code Skills (Used, Not Wrapped)

These are third-party skills invoked by name but not forked or modified:

- `caucus` — multi-perspective review (strategy, design phases)
- `reasoning-frameworks` — structured analysis (strategy, design phases)
- `reconciling-documents` — document consolidation (product phase)
- `hibernate-project` — project freeze/thaw (extended by `sweetclaude:hibernate`)

### Optional MCP Servers

| Server | Install | Role |
|---|---|---|
| [mcp-local-rag](https://www.npmjs.com/package/mcp-local-rag) | `npm install -g mcp-local-rag` | Local semantic search via per-project vector index (uses [LanceDB](https://lancedb.com/)) |

### CLI Tools

| Tool | Required | Role |
|---|---|---|
| git | Yes | Version control, branching, commit hooks |
| [GitHub CLI (gh)](https://cli.github.com/) | Recommended | Project init, issue/PR management |
| Node.js | Optional | Required only if using RAG indexing (`mcp-local-rag`) |

## License

SweetClaude is released under the [GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0-or-later).

Copyright 2026 Carson Sweet. All rights reserved under the terms of the AGPL-3.0.
