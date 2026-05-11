# ☕️dot

## Cursor extensions

The list of installed Cursor extensions is snapshotted at `config/cursor/extensions.txt` and replayed by `setup/cursor.sh` on fresh installs. The snapshot is not auto-maintained — after installing or removing extensions, refresh it with:

```sh
cursor --list-extensions > config/cursor/extensions.txt
```

Cursor's `settings.json` and `keybindings.json` are symlinked into `~/Library/Application Support/Cursor/User/`, so edits made inside Cursor write directly back to this repo.

## Acknowledgements

My neovim configuration is a representation of all of the dotfiles I have ever poured through. A few special
configurations I have heavily sourced / pulled inspiration from include:

- [EdenEast/nyx](https://github.com/EdenEast/nyx/tree/main/config/.config/nvim)
- [jose-elias-alvarex/dotfiles](https://github.com/jose-elias-alvarez/dotfiles/tree/main/config/nvim)
- [sindrets/dotfiles](https://github.com/sindrets/dotfiles/tree/master/.config/nvim)
