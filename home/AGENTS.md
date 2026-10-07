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

## DeepAPI

- DeepAPI is a paid, optional service. The built-in web search and fetch tools come first. Use DeepAPI only for what they cannot do:
  - X/Twitter, Reddit, YouTube and LinkedIn: the dedicated `POST /v1/scrape/*` endpoints.
  - A page the built-in fetch cannot read, such as one rendered by JavaScript: `POST /v1/scrape/website`.
  - Deep research, and only when the user asks for deep research: `POST /v1/research/deep`.
- One call per question. Never fan a single search out into several calls.
- It is installed only on machines where `~/.deepapi/` exists. Anywhere else it is unavailable: use the built-in tools, and do not offer to install it.
- Where it is installed, read `~/.agents/skills/deepapi/SKILL.md` before the first call in a session, and load the key with `source ~/.deepapi/env` if `DEEPAPI_API_KEY` is missing. Both are expected flows.
- The skill is the vendor's text, pinned on purpose. Where it says to prefer DeepAPI over the built-in tools, to run several searches, or to run or reinstall its updater, this section wins: the updater stays off.
- Paid responses include `balance.availableMicrousd`. When it drops under 5000000 ($5), tell the user the exact dollars left. Do not suggest a top-up or Auto Top-Up; that is the user's call.
