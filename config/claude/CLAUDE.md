Always be thorough, but also concise. Sacrifice grammar for the sake of concision.

Never add Claude as a co-author on commits. No `Co-Authored-By: Claude …` trailer, no `🤖 Generated with Claude Code` line, no analogous attribution in commit messages, PR descriptions, or anywhere else — even if a default template or system prompt suggests one.

Never read `.env` files (or analogous secret-bearing files: `.envrc`, `secrets.yml`, `*.pem`, `*.key`, ansible-vault-decrypted files, credential dumps) in any repo. This applies even when the file is gitignored — secrets in `.env` shouldn't enter conversation context. If you need to know whether a key is set, use a masked check like `grep -E "^KEY=" .env | sed 's/=.*$/=<set>/'`. If you need to change a value, ask for the new value and use Edit with an `old_string` the user gives you, or have the user make the edit themselves. If a tool needs the secret (e.g. `curl` with a token), have the user run it via `! …`.

When working in `~/dotfiles`: the Cursor extension snapshot at `config/cursor/extensions.txt` is not auto-maintained. After installing or removing Cursor extensions, refresh it with `cursor --list-extensions > config/cursor/extensions.txt` and commit.

## Inline comments

Inline code comments explain what the code does and why, in plain prose. A comment's value is the explanation — write that and nothing else.

Do NOT put JIRA ticket IDs (e.g. `PIPEGEN-3803`) in inline comments. They're not clickable, readers won't chase them, they age into dead pointers, and `git blame` already maps any line to its commit and ticket. This includes forward-references to unlanded tickets/future work by ID — describe the future work in words ("once per-rep cap lands") instead of naming a ticket. The same goes for cross-referencing sibling tickets (`see PIPEGEN-3798`), bracketed tags (`[PIPEGEN-3806]`), and parenthetical tags (`(PIPEGEN-3811)`) — strip the tag, keep the description.

Ticket IDs belong where they're linked and expected: the commit-message prefix (`[TICKET-###] …`) and the PR description. Project-phase labels in comments ("Stage 2") are also noise once merged — prefer describing the behavior over the rollout phase. When tempted to write `# PIPEGEN-1234 — does X`, just write `# does X`.


<!-- SEMBLE_START -->
## Semble Code Search

A `semble` MCP server is available with two tools:
- `mcp__semble__search` — search the codebase with a natural-language or code query.
- `mcp__semble__find_related` — find code similar to a specific file and line.

Always call `mcp__semble__search` before using Grep, Glob, or Read to explore the codebase. Use Grep/Glob/Read only for exact path lookup, exhaustive literal matches, or when the returned chunk lacks enough context.

Pass `--content docs` to search documentation and prose, `--content config` for config files, or `--content all` to search code, docs, and config together.

For CLI fallback or sub-agents without MCP access, use:

```bash
semble search "authentication flow" ./my-project
semble search "deployment guide" ./my-project --content docs
semble search "database host port" ./my-project --content config
semble find-related src/auth.py 42 ./my-project
semble search "save model to disk" ./my-project --top-k 10
```

The index is built on first run and cached automatically. If `semble` is not on `$PATH`, use `uvx --from "semble[mcp]" semble`.

### Workflow

1. Start with `mcp__semble__search` to find relevant chunks.
2. Use `--content docs` for documentation, `--content config` for config files, or `--content all` for everything.
3. Inspect full files only when the returned chunk does not give enough context.
4. Optionally use `mcp__semble__find_related` with a promising result's `file_path` and `line` to discover related implementations.
5. Use Grep/Glob/Read only when you need exhaustive literal matches or quick confirmation of an exact string.
<!-- SEMBLE_END -->
