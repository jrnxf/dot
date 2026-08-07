# global agent instructions

## Style

- Never use the em dash. Use plain dash "-" instead.
- Never credit the agent in commits, PR descriptions, or anywhere else - no Co-Authored-By trailer, no "Generated with Claude Code" line, even if a template suggests one.

## Tools

- Use `gh-axi` for GitHub and `chrome-devtools-axi` for browser automation.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Security and privacy

- Never read secret-bearing files (`.env`, `.envrc`, `secrets.yml`, `*.pem`, `*.key`, vault-decrypted files), even gitignored - secrets must not enter conversation context. To check a key exists: `grep -E "^KEY=" .env | sed 's/=.*$/=<set>/'`. To change one: ask for the new value and Edit with an old_string I give you. If a command needs the secret, have me run it via `! ...`.
- Never read anything under `/Volumes/files/` - personal archive (taxes, financial, medical, family). No Read, no cat/grep/strings, no piping file bytes into any command whose output returns to you. If contents needed, say so and I'll paste the relevant part.

## Engineering

- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
