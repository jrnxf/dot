# Plan 004: Fix the five small correctness bugs in zshrc and the global gitignore

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 323303b..HEAD -- shell/zsh/zshrc git/gitignore`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: MED (the TERM removal can change terminal behavior; everything else LOW)
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `323303b`, 2026-06-12

## Why this matters

Five small, confirmed bugs. Individually minor, but they're the kind of
config rot that produces confusing behavior months later: commits stamped
with the wrong time, terminfo mismatches inside tmux/ghostty, a PATH entry
that does nothing, a gitignore line that has never matched anything, and a
shell-startup error waiting for the next oh-my-zsh update. One small batched
fix clears them all.

## Current state

All in `shell/zsh/zshrc` except the last:

1. **`dc` alias timestamp frozen at shell start** — `zshrc:129`:

   ```sh
   alias dc="git commit -m '$(date +%m/%d/%y\ %H:%M)'"
   ```

   Double quotes make `$(date ...)` evaluate when the zshrc is sourced, so
   every `dc` in a long-lived shell commits with the shell's start time, not
   the commit time. (Repo history shows these commits: `c323d26 07/22/25 11:20`.)

2. **Unconditional TERM override** — `zshrc:29`:

   ```sh
   export TERM=xterm-256color
   ```

   Overrides whatever the terminal set (ghostty sets `xterm-ghostty`; tmux
   sets `screen-256color` per `config/tmux/tmux.conf:23`). Clobbering TERM
   inside tmux is a classic source of broken keys/colors; terminals are
   responsible for setting their own TERM.

3. **Dead pyenv PATH entry** — `zshrc:19`:

   ```sh
   export PATH="$HOME/.pyenv:$PATH"
   ```

   pyenv's executables live in `~/.pyenv/bin` and `~/.pyenv/shims`, never in
   `~/.pyenv` itself. pyenv is also not in the Brewfile. This line adds a
   directory with no executables to PATH.

4. **Unguarded `unalias rd`** — `zshrc:90` (`unalias rd` right after the
   oh-my-zsh source). If omz ever stops defining `rd`, every shell start
   prints an error.

5. **Unguarded vite-plus source** — `zshrc:285`:

   ```sh
   . "$HOME/.vite-plus/env"
   ```

   On any machine without vite-plus, every shell start errors. Compare the
   guarded pattern used two blocks up for nvm: `[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"`.

6. **Absolute path in global gitignore** — `git/gitignore:3` (linked to
   `~/.gitignore`, used as `core.excludesfile`):

   ```
   /Users/colby/Dev/pocus/frontend/frontend.garden.yml
   ```

   Gitignore patterns are repo-relative; a leading `/` anchors to the repo
   root, so this pattern would only match a path literally named
   `Users/colby/...` *inside* a repo. It has never matched anything.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| zsh syntax | `zsh -n shell/zsh/zshrc` | exit 0, no output |
| Alias eval semantics | `zsh -ic 'alias dc'` (run on operator's machine post-link) | shows single-quoted definition containing literal `$(date` |

## Scope

**In scope** (the only files you should modify):
- `shell/zsh/zshrc`
- `git/gitignore`

**Out of scope** (do NOT touch, even though they look related):
- The `yolo`/`claude` alias pair (`zshrc:118-119`) — both resolve to
  `--dangerously-skip-permissions` via alias chaining; recorded as
  intentional, do not "fix".
- `plugins=(...)`, omz sourcing, nvm block — plan 003 territory.
- `kj()`'s awk parsing — recorded as not-worth-doing.
- `~/Dev/pocus/frontend/.git/info/exclude` — outside this repo; the
  garden.yml ignore belongs there but it's the operator's action (see
  Maintenance notes).

## Git workflow

- Branch: `advisor/004-zshrc-and-git-correctness-fixes`
- One commit, e.g. `zsh: fix dc timestamp, TERM override, dead pyenv path, unguarded sources`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Fix the `dc` alias quoting (`zshrc:129`)

Change to single outer quotes so the substitution happens at use time:

```sh
alias dc='git commit -m "$(date +%m/%d/%y\ %H:%M)"'
```

**Verify**: `grep -n "alias dc=" shell/zsh/zshrc` → the line above, single
quote immediately after `=`.

### Step 2: Delete the TERM export (`zshrc:29`)

Remove the line `export TERM=xterm-256color` entirely. Do not replace it
with a conditional — ghostty/kitty/tmux all set TERM correctly themselves.

**Verify**: `grep -c "export TERM" shell/zsh/zshrc` → `0`.

### Step 3: Delete the pyenv PATH line (`zshrc:19`)

Remove `export PATH="$HOME/.pyenv:$PATH"`.

**Verify**: `grep -c "pyenv" shell/zsh/zshrc` → `0`.

### Step 4: Guard `unalias rd` (`zshrc:90`)

```sh
unalias rd 2>/dev/null || true
```

**Verify**: `grep -n "unalias rd" shell/zsh/zshrc` → the guarded form.

### Step 5: Guard the vite-plus source (`zshrc:285`)

```sh
[ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"
```

Keep the `# Vite+ bin (https://viteplus.dev)` comment above it.

**Verify**: `grep -n "vite-plus" shell/zsh/zshrc` → guarded form only.

### Step 6: Remove the dead gitignore line (`git/gitignore:3`)

Delete the `/Users/colby/Dev/pocus/frontend/frontend.garden.yml` line,
leaving:

```
**/node_modules
.DS_Store
```

**Verify**: `grep -c "pocus" git/gitignore` → `0`.

### Step 7: Syntax-check the result

**Verify**: `zsh -n shell/zsh/zshrc` → exit 0.

## Test plan

No test framework. `zsh -n` is the syntax gate; the per-step greps are the
behavioral gates. Operator smoke test after merge: open a new shell — no
startup errors; `echo $TERM` inside ghostty → `xterm-ghostty`; inside tmux →
`screen-256color`; `alias dc` → single-quoted definition.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `zsh -n shell/zsh/zshrc` exits 0
- [ ] `grep -c "export TERM\|pyenv" shell/zsh/zshrc` → 0
- [ ] `grep -n "alias dc=" shell/zsh/zshrc` shows `alias dc='git commit -m "$(date`
- [ ] `grep -n "vite-plus/env" shell/zsh/zshrc` shows the `[ -f ... ] &&` guard
- [ ] `grep -c "pocus" git/gitignore` → 0
- [ ] `git status --porcelain` shows only `shell/zsh/zshrc` and `git/gitignore`
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- Any "Current state" excerpt doesn't match the live file (drift).
- You find other code in the repo that reads `$TERM` expecting
  `xterm-256color` specifically (grep first: `grep -rn "xterm-256color" --exclude-dir=.git --exclude-dir=dotbot --exclude-dir=config/nvim.bak .` should
  match only the zshrc line you're deleting; kitty.conf/alacritty references
  are their own TERM settings and fine).
- `~/.pyenv/bin` exists and contains executables on the operator's machine
  (`ls ~/.pyenv/bin 2>/dev/null`) — then pyenv IS in use; fix the line to
  `export PATH="$HOME/.pyenv/bin:$PATH"` + shims init instead of deleting,
  and say so in your report.

## Maintenance notes

- **TERM removal is the one MED-risk change**: if colors or keybindings
  degrade in some terminal after this lands, the fix is configuring that
  terminal's own TERM, not restoring the global export. Watch the first few
  tmux sessions.
- The garden.yml ignore the deleted gitignore line *intended* belongs in
  `~/Dev/pocus/frontend/.git/info/exclude` (repo-local, not committed).
  One-time operator action:
  `echo "frontend.garden.yml" >> ~/Dev/pocus/frontend/.git/info/exclude`.
- If plan 003 hasn't landed, `zsh -ic` checks on a fresh machine will noise
  about missing omz — unrelated to this plan.
