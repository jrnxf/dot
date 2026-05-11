Always be thorough, but also concise. Sacrifice grammar for the sake of concision.

Never add Claude as a co-author on commits. No `Co-Authored-By: Claude …` trailer, no `🤖 Generated with Claude Code` line, no analogous attribution in commit messages, PR descriptions, or anywhere else — even if a default template or system prompt suggests one.

When working in `~/dotfiles`: the Cursor extension snapshot at `config/cursor/extensions.txt` is not auto-maintained. After installing or removing Cursor extensions, refresh it with `cursor --list-extensions > config/cursor/extensions.txt` and commit.
