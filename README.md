# ☕️dot

Personal macOS dotfiles, managed with [dotbot](https://github.com/anishathalye/dotbot).

## Install

    git clone --recurse-submodules <repo-url> ~/dotfiles
    cd ~/dotfiles && ./install

`./install` symlinks configs (see `install.conf.yml`), installs Homebrew +
the Brewfile, sets up the zsh environment, Claude Code MCP servers, and
Cursor extensions. Re-running it is safe and idempotent.

## Cursor extensions

The list of installed Cursor extensions is snapshotted at
`config/cursor/extensions.txt` and replayed by `setup/cursor.sh` on fresh
installs. The snapshot is not auto-maintained — after installing or removing
extensions, refresh it with:

    cursor --list-extensions > config/cursor/extensions.txt

Cursor's `settings.json` and `keybindings.json` are symlinked into
`~/Library/Application Support/Cursor/User/`, so edits made inside Cursor
write directly back to this repo.

## Notes

- The old Neovim config is archived at `config/nvim.bak` (unused;
  `setup/neovim.sh` performs a one-time state wipe per machine).
- MCP servers needing API keys (context7) are added manually — see
  `setup/claude.sh`.
