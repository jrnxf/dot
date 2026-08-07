# The legacy Neovim setup (pre-wipe archaeology)

This doc records what the old, fully-built-out Neovim configuration looked like before it was
wiped, where to find it in git history, and which pieces are worth resurrecting into the current
minimal `home/.config/nvim` setup.

## The commits that matter

| Commit | What it is |
|---|---|
| `22be109` | **The reference commit.** Last commit where the full setup lived at `config/nvim/`. "nvim restructuring pt11" - the end state of an 11-part restructuring effort. |
| `58c0037` | The wipe (May 4, 2026). Renamed `config/nvim` to `config/nvim.bak` because the packer-based config had broken against then-current Neovim. |
| `39f6a45` | The nix-darwin migration. Deleted `config/nvim.bak` entirely - nothing of the old setup survives in the working tree today. |

To browse or recover anything:

```sh
git show 22be109:config/nvim/init.lua               # read any single file
git ls-tree -r --name-only 22be109 -- config/nvim   # list everything
git checkout 22be109 -- config/nvim                 # resurrect the whole tree
```

## Architecture

Everything was namespaced under `lua/jrnxf/` with a deliberate module layout:

```
config/nvim/
├── init.lua                  -- one line: require('jrnxf.bootstrap').init()
├── .stylua.toml
├── lua/jrnxf/
│   ├── bootstrap.lua         -- globals, disable stock plugins, boot order
│   ├── core/                 -- options, keymaps, commands, autocmd events, colors
│   ├── lib/                  -- hand-rolled stdlib (see below)
│   ├── lsp/                  -- one file per language server
│   └── plugins/              -- packer spec + one config file per plugin
└── snippets/                 -- LuaSnip snippets (all, lua, typescript)
```

Boot order was explicit and documented in `bootstrap.lua`: define globals, disable ~20
distribution plugins (netrw, tar, zip, tutor, shada, ...), load `impatient.nvim` for startup
caching, then `core` then `plugins`. The `jrnxf.lsp` namespace deliberately loaded only after
`nvim-lspconfig` and all its dependencies were up, wired through packer's `after`/`config` hooks.

Plugin management was **packer.nvim** with a custom `conf` handler so a spec could say
`{ 'folke/trouble.nvim', conf = 'trouble' }` and packer would expand it to
`require('jrnxf.plugins.trouble')` - a tidy convention worth noting even though packer is dead.

## The hand-rolled `lib/`

The most personal part of the setup and the easiest thing to lose without noticing:

- **`lib/reload.lua`** - `full_reload()`: nukes every `jrnxf.core` / `jrnxf.plugins` entry from
  `package.loaded`, re-runs bootstrap, then `packer.sync()`. Bound to `<F3>` and `<leader>fr`.
  Live-editable config without restarting Neovim.
- **`lib/utils.lua`** - the greatest hits:
  - `smart_telescope_files()` - git-aware file finder (git files inside a repo, all files outside)
  - `exec_current_file()` - run the current file (`<F1>`)
  - `open_url_under_cursor()` - opens URLs, including bare `user/repo` GitHub shorthand (`<F2>`)
  - table utilities: `vec_union`, `tbl_deep_clone`, `tbl_union_extend_or_overwrite`
- **`lib/keymaps.lua`** - defined global `nmap` / `vmap` / `xmap` / `cmap` / `kmap` / `buf_map`
  helpers used throughout, keeping every mapping terse and uniform.
- **`bootstrap.lua` globals** - `_G.put(...)`: inspect-and-notify debug printing used everywhere
  during config development.
- **`lib/platform.lua`, `lib/path.lua`, `lib/modlist.lua`, `lib/events.lua`, `lib/colors.lua`** -
  small platform/path/module-enumeration helpers supporting the above.

## LSP setup

One file per server under `lua/jrnxf/lsp/`: `bashls`, `eslint`, `gopls`, `jsonls`, `null_ls`,
`prismals`, `pyright`, `rust_analyzer`, `sumneko_lua`, `tsserver`.

`lsp/init.lua` established the shared behavior:

- Rounded borders on every floating surface (diagnostics, hover, signature help, `:LspInfo`)
- `virtual_text = false` - diagnostics lived in the sign column and floats, not inline
- Custom diagnostic gutter icons per severity
- **Format on save** via a shared `LspFormatting` augroup, plus `<leader>fo` and visual-mode
  `<CR>` to format on demand, and a per-buffer `:LspFormatting` command
- Highlight-references-on-hold with a documented toggle between vim-illuminate and a
  plugin-free LSP `documentHighlight` implementation

Tooling was auto-installed through **mason** + **mason-tool-installer** with this
`ensure_installed` list: `tailwindcss-language-server`, `pyright`, `html-lsp`,
`bash-language-server`, `editorconfig-checker`, `gopls`, `lua-language-server`, `luacheck`,
`misspell`, `prettierd`, `shellcheck`, `shfmt`, `stylua`, `typescript-language-server`, `xo`.

**null-ls** provided formatting (prettierd, shfmt, stylua), code actions (shellcheck, xo,
gitsigns), and the fun `hover.dictionary` / `hover.printenv` sources.

## Plugin inventory (~45 plugins)

| Area | Plugins |
|---|---|
| Syntax | nvim-treesitter (+ playground, ts-autotag, ts-context-commentstring for working JSX comments) |
| Finding | telescope (+ fzf-native, live-grep-args, bookmarks), **and** fzf-lua, **and** harpoon |
| Completion | nvim-cmp (nvim-lua, nvim-lsp, buffer, path, emoji, cmdline sources, lspkind icons), LuaSnip + custom snippets |
| Git | fugitive, gitsigns, diffview (pinned to a commit to dodge a horizontal-split bug) |
| UI | feline statusline (custom, two files), bufferline v3, nvim-tree, dressing, nui, fidget, notifier, indent-blankline, zen-mode, trouble |
| Editing | Comment.nvim, vim-surround, nvim-autopairs, inc-rename (live rename preview), better-escape (`jk`/`kj`) |
| Motion | cinnamon smooth scrolling (leap and neoscroll tried and commented out) |
| Colors | nightfox (**terafox** was the active scheme), rose-pine, onenord, onedark, catppuccin, nvim-colorizer |
| Lang | go.nvim, typescript.nvim, neodev, schemastore |

The commented-out graveyard is itself informative: noice, lualine, legendary, leap, neoscroll,
todo-comments - all tried, all rejected. Feline carried a warning about a packer `VimEnter`
double-fire bug. Trouble had previously run from a personal fork carrying a looping feature.

## Keymaps worth remembering

Space leader. Highlights beyond the usual suspects:

- `jk` / `kj` to escape insert mode (better-escape)
- `x`/`X` delete to void register; `<leader>d` void-delete motion; `<leader>p` paste without clobbering the register
- Arrow keys resize windows; `<leader>=` equalizes
- `<CR>` clears search highlight (and still behaves as `<CR>`)
- `n`/`N` recenter with `zzzv`; `j`/`k` respect wrapped lines
- Visual `J`/`K` move selected lines; `<`/`>` keep the selection after indenting
- `c.` starts a `%s` substitution pre-filled with the word under the cursor
- `<leader>o`/`<leader>O` insert blank lines without entering insert mode (count-aware)
- `<leader>gB` opens the current file *and line* on GitHub via `gh browse`
- Fugitive: `gs` for `:0G` status, `gj`/`gk` for `diffget //2` / `//3` in merge conflicts
- Diffview: `<leader>gd` open, `<leader>gh` full history, `<leader>gH` current-file history
- Emacs-style cmdline navigation (`<C-a>`, `<C-e>`, `<C-h/j/k/l>`), `<C-f>` inserts current file path
- `<F1>` run current file, `<F2>` open URL under cursor, `<F3>` hot-reload the whole config

There was also a small `docs/nvim.md` with vim tips (`vim -V9log` debugging, `:v/pat/d` /
`:g!/pat/d` to delete non-matching lines).

## What the current setup has vs. what to bring over

Today's `home/.config/nvim` is a minimal lazy.nvim config: snacks.nvim, which-key, gitsigns,
neogit, diffview, oil, rose-pine. That leaves real gaps the old setup covered.

**Bring over, with modern replacements where the old plugin is dead:**

1. **The LSP + formatting layer** - the single biggest gap. Recreate the per-server layout and
   format-on-save behavior. Modern stack: `nvim-lspconfig` + `mason` (still alive) +
   **conform.nvim** for formatting and **nvim-lint** for linting (null-ls is abandoned;
   its fork none-ls exists but conform/nvim-lint is the cleaner path). Rename the relics:
   `sumneko_lua` is now `lua_ls`, `tsserver` is now `ts_ls`.
2. **The mason `ensure_installed` list** - it is a complete census of the languages actually
   worked in (TS/JS, Go, Python, Lua, Bash, Rust, Prisma, Tailwind). Port it wholesale.
3. **Treesitter** - not present today; was foundational (plus ts-context-commentstring if JSX
   commenting matters again).
4. **Completion + snippets** - nvim-cmp or its modern successor blink.cmp; carry the LuaSnip
   snippets dir (`cl`, `imp`, plus lua/all snippets) - tiny files, pure muscle memory.
5. **`lib/utils.lua` helpers** - `smart_telescope_files` (adapt to snacks.picker),
   `open_url_under_cursor` with GitHub shorthand, `exec_current_file`, and `put()` debug
   printing. These are personal tooling, not replaceable by any plugin.
6. **The keymaps** - the whole "Keymaps worth remembering" section above, especially the
   void-register family, `c.`, `<leader>gB`, fugitive/diffview bindings, and window-resize
   arrows. Diff them against current `lua/keys.lua` and port what's missing.
7. **inc-rename** - live-preview LSP rename, small and still maintained.
8. **Format-on-save discipline** - the `LspFormatting` augroup pattern (or conform's
   `format_on_save`) with `<leader>fo` escape hatch.

**Leave behind:** packer (dead - lazy.nvim won), impatient (built into Neovim as
`vim.loader.enable()`), feline (unmaintained; snacks/lualine/heirline cover it), null-ls
(abandoned), nvim-tree (oil covers it), the colorscheme zoo (rose-pine already won), cinnamon
(Neovim 0.10+ has `smoothscroll`, and snacks has scroll animations), notifier/dressing/nui
(snacks.nvim and `vim.ui` improvements cover these), harpoon (grab only if the workflow itch
returns - snacks has similar affordances).

**Judgment call:** telescope vs fzf-lua vs snacks.picker - the old config carried both telescope
and fzf-lua simultaneously; today snacks.picker likely suffices. Trouble is worth re-evaluating
(v3 rewrote it) if diagnostics-list workflows come back.
