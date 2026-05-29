Always be thorough, but also concise. Sacrifice grammar for the sake of concision.

Never add Claude as a co-author on commits. No `Co-Authored-By: Claude …` trailer, no `🤖 Generated with Claude Code` line, no analogous attribution in commit messages, PR descriptions, or anywhere else — even if a default template or system prompt suggests one.

Never read `.env` files (or analogous secret-bearing files: `.envrc`, `secrets.yml`, `*.pem`, `*.key`, ansible-vault-decrypted files, credential dumps) in any repo. This applies even when the file is gitignored — secrets in `.env` shouldn't enter conversation context. If you need to know whether a key is set, use a masked check like `grep -E "^KEY=" .env | sed 's/=.*$/=<set>/'`. If you need to change a value, ask for the new value and use Edit with an `old_string` the user gives you, or have the user make the edit themselves. If a tool needs the secret (e.g. `curl` with a token), have the user run it via `! …`.

When working in `~/dotfiles`: the Cursor extension snapshot at `config/cursor/extensions.txt` is not auto-maintained. After installing or removing Cursor extensions, refresh it with `cursor --list-extensions > config/cursor/extensions.txt` and commit.
