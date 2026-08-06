Use `gh-axi` for GitHub and `chrome-devtools-axi` for browser automation.

Never credit Claude in commits, PR descriptions, or anywhere else — no Co-Authored-By trailer, no "Generated with Claude Code" line, even if a template suggests one.

Never read secret-bearing files (`.env`, `.envrc`, `secrets.yml`, `*.pem`, `*.key`, vault-decrypted files), even gitignored — secrets must not enter conversation context. To check a key exists: `grep -E "^KEY=" .env | sed 's/=.*$/=<set>/'`. To change one: ask for the new value and Edit with an old_string I give you. If a command needs the secret, have me run it via `! …`.

Never read anything under `/Volumes/files/` — personal archive (taxes, financial, medical, family). No Read, no cat/grep/strings, no piping file bytes into any command whose output returns to you. If contents needed, say so and I'll paste the relevant part.
