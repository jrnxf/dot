# Plan 003: Install the shell/tmux dependencies `./install` silently assumes

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 323303b..HEAD -- install.conf.yml setup/ shell/zsh/zshrc config/tmux/tmux.conf`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/002-script-hygiene-and-ci.md (soft — so the new script is shellcheck-gated; can land first if needed)
- **Category**: bug
- **Planned at**: commit `323303b`, 2026-06-12

## Why this matters

The whole point of this repo is that `./install` on a fresh Mac reproduces
the working environment. Today it doesn't: the zshrc and tmux.conf depend on
five things that nothing in the repo installs. On a new machine the first
shell errors out of oh-my-zsh loading, fzf-tab/autosuggestions silently don't
exist, tmux has no plugin manager, and nvm is absent. The user would have to
rediscover and hand-install each one — exactly the failure dotfiles exist to
prevent.

The fix is one new idempotent `setup/zsh.sh` that installs the missing
pieces, wired into `install.conf.yml`.

## Current state

Unmet dependencies, each with the line that requires it:

- **oh-my-zsh** — `shell/zsh/zshrc:4` (`export ZSH="$HOME/.oh-my-zsh"`) and
  `:89` (`source $ZSH/oh-my-zsh.sh`). Not installed by anything in the repo.
- **fzf-tab** (omz custom plugin) — `shell/zsh/zshrc:10`
  (`plugins=(fzf-tab zsh-autosuggestions aws tmux gh fzf docker git)`).
  Upstream: `https://github.com/Aloxaf/fzf-tab`. Must live at
  `$ZSH_CUSTOM/plugins/fzf-tab` (default `~/.oh-my-zsh/custom/plugins/`).
- **zsh-autosuggestions** (omz custom plugin) — same `plugins=` line. NOTE:
  the Brewfile installs `brew "zsh-autosuggestions"`, but the omz plugin
  loader does NOT read the brew formula — it needs a clone at
  `$ZSH_CUSTOM/plugins/zsh-autosuggestions`
  (`https://github.com/zsh-users/zsh-autosuggestions`). Leave the brew
  formula alone (out of scope).
- **tpm** — `config/tmux/tmux.conf:108` (`run '~/.tmux/plugins/tpm/tpm'`).
  Needs a clone at `~/.tmux/plugins/tpm`
  (`https://github.com/tmux-plugins/tpm`).
- **nvm** — `shell/zsh/zshrc:272-274` sources `$HOME/.nvm/nvm.sh` (guarded,
  so absence is silent rather than fatal — but node-via-nvm just won't
  exist). Installer:
  `https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh`.

Already handled, do not re-install: `fzf`, `lsd`, `bat`, `starship`,
`thefuck`, `tmux` are all in the `Brewfile` (installed by `setup/mac.sh`);
`~/.fzf.zsh` and `~/.vite-plus/env` sourcing are zshrc concerns (plan 004
guards the unguarded one).

`install.conf.yml:35-51` shell tasks today (order: mac → neovim → claude →
cursor):

```yaml
- shell:
    - command: ./setup/mac.sh
      description: Setting up Mac
      stdout: true
      stderr: true
    - command: ./setup/neovim.sh
    ...
```

Repo conventions: setup scripts are POSIX `#!/bin/sh`, top comment stating
purpose, graceful skip with `exit 0` when a prerequisite is missing — see
`setup/cursor.sh` as the exemplar.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| sh syntax | `sh -n setup/zsh.sh` | exit 0 |
| shellcheck (if installed locally) | `shellcheck setup/zsh.sh` | exit 0 |
| YAML validity | `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"` | exit 0 |

Do NOT run `setup/zsh.sh` itself as verification on the operator's machine —
everything is already installed here, so it would only prove the skip paths;
the operator validates the install paths on the next fresh machine. (Running
it IS safe — every step is guarded — just not probative.)

## Scope

**In scope** (the only files you should modify/create):
- `setup/zsh.sh` (create)
- `install.conf.yml` (add one shell task)

**Out of scope** (do NOT touch, even though they look related):
- `shell/zsh/zshrc` — plan 004 owns zshrc edits.
- `Brewfile` — leave `zsh-autosuggestions` formula and `node` as they are;
  the brew-node-vs-nvm duplication is a recorded direction item, operator's
  call.
- `config/tmux/tmux.conf` — tpm line stays as is.
- `setup/mac.sh`, `setup/claude.sh` — plan 002 owns them.

## Git workflow

- Branch: `advisor/003-bootstrap-fresh-machine`
- One commit, e.g. `setup: bootstrap oh-my-zsh, zsh plugins, tpm, nvm`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Create `setup/zsh.sh`

```sh
#!/bin/sh
# Install the shell environment zshrc and tmux.conf depend on:
# oh-my-zsh, fzf-tab, zsh-autosuggestions (omz custom plugins), tpm, nvm.
# Every step is guarded, so re-runs are no-ops.
set -e

# oh-my-zsh — RUNZSH/CHSH/KEEP_ZSHRC keep the installer from launching a
# shell, changing the login shell, or clobbering the dotbot-linked ~/.zshrc.
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

if [ ! -d "${ZSH_CUSTOM}/plugins/fzf-tab" ]; then
  echo "Installing fzf-tab"
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM}/plugins/fzf-tab"
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions"
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  echo "Installing tpm (tmux plugin manager)"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  echo "NOTE: run prefix + I inside tmux to install tmux plugins."
fi

if [ ! -d "${HOME}/.nvm" ]; then
  echo "Installing nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
fi

echo "Shell environment ready."
```

(`PROFILE=/dev/null` stops the nvm installer from appending its loader to
the dotbot-managed zshrc — the zshrc already has the nvm block at lines
271–274.)

**Verify**: `sh -n setup/zsh.sh` → exit 0. `chmod +x setup/zsh.sh` then
`ls -l setup/zsh.sh` → mode includes `x` (match the other setup scripts).

### Step 2: Wire it into `install.conf.yml`

Add to the `shell:` list, immediately AFTER the `./setup/mac.sh` entry
(brew/git available first) and before `./setup/neovim.sh`:

```yaml
    - command: ./setup/zsh.sh
      description: Setting up zsh environment (oh-my-zsh, plugins, tpm, nvm)
      stdout: true
      stderr: true
```

**Verify**: `python3 -c "import yaml; c=yaml.safe_load(open('install.conf.yml')); cmds=[s['command'] for t in c if 'shell' in t for s in t['shell']]; print(cmds)"`
→ list contains `./setup/zsh.sh` at index 1.

## Test plan

No test framework. Gates: `sh -n`, shellcheck (locally if present, otherwise
the CI from plan 002 covers it since the workflow globs `setup/*.sh`), and
the YAML parse check. Real-world validation is the operator's next fresh
machine or a throwaway macOS VM — note that in the PR description.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `setup/zsh.sh` exists, is executable, `sh -n` exits 0
- [ ] `grep -c "if \[ ! -d" setup/zsh.sh` → `5` (every install step guarded)
- [ ] `grep -n "zsh.sh" install.conf.yml` → one match, positioned after mac.sh's entry
- [ ] `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"` exits 0
- [ ] `git status --porcelain` shows only `setup/zsh.sh` (new) and `install.conf.yml`
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The `plugins=(...)` line in `shell/zsh/zshrc` no longer lists `fzf-tab` or
  `zsh-autosuggestions` (drift — the operator may have moved off omz, which
  changes this plan's whole approach; see direction item D2 in
  `plans/README.md`).
- You're tempted to also fix the unguarded `~/.vite-plus/env` source or
  anything else inside zshrc — that's plan 004; report the overlap instead.
- The nvm installer URL 404s (version pin moved) — report; do not substitute
  `master`.

## Maintenance notes

- The nvm version is pinned (`v0.40.3`); bumping it is a one-line change in
  `setup/zsh.sh`. Check https://github.com/nvm-sh/nvm/releases occasionally.
- If direction item D2 (drop oh-my-zsh) is ever executed, this script shrinks
  to tpm + nvm and the plugin clones move/vanish — revisit then.
- The clones are `--depth 1` and never updated by re-runs; updating omz
  custom plugins is manual (`git -C ~/.oh-my-zsh/custom/plugins/fzf-tab pull`).
  Deliberate: dotfiles install should be deterministic, not an updater.
- Reviewer should scrutinize: installer env guards (`RUNZSH=no CHSH=no
  KEEP_ZSHRC=yes`, `PROFILE=/dev/null`) — these are what protect the
  dotbot-managed zshrc from being overwritten or appended to.
