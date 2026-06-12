# Plan 005: Prune dead config (stale lockfile, unused terminal configs, empty files) and refresh the README

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 323303b..HEAD -- Brewfile.lock.json playground.lua config/kitty.conf config/alacritty.yml config/iterm install.conf.yml README.md .gitignore`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW (deletions are recoverable from git history; the riskiest assumption — that kitty/alacritty/iterm are unused — has its own STOP condition)
- **Depends on**: plans/001-make-install-safe-to-rerun.md (soft — after 001, dotbot's clean task garbage-collects the symlinks these deletions orphan)
- **Category**: tech-debt
- **Planned at**: commit `323303b`, 2026-06-12

## Why this matters

About 100KB of the repo is dead: a Brewfile lockfile that hasn't tracked the
Brewfile since 2025, three terminal-emulator configs for terminals the user
has visibly moved off of (recent commits theme ghostty and tmux; kitty/
alacritty/iterm are untouched since 2025-11), an empty `playground.lua` at
the repo root, and a README whose main content is acknowledgements for a
Neovim config that was wiped and archived. Dead config misleads — both
future-you and any agent auditing this repo spends time on files that don't
matter.

## Current state

- `Brewfile.lock.json` (117KB) — last commits touching it are from the
  "nvim restructuring" era (2025); `Brewfile` has changed since (May 2026
  mtime), so the lock no longer describes reality. `brew bundle` regenerates
  it on every run; for a personal dotfiles repo it's noise.
- `playground.lua` — 0 bytes, repo root, referenced by nothing
  (verify: `grep -rn "playground" --exclude-dir=.git --exclude-dir=dotbot .`
  → no matches).
- `config/kitty.conf` (77KB, mostly commented defaults), `config/alacritty.yml`
  (6KB), `config/iterm/` — terminal configs. kitty and alacritty are linked
  by `install.conf.yml:23,25`; iterm is not linked by anything. The actively
  maintained terminal is ghostty (`config/ghostty`, themed "Cursor Dark" in
  recent commits, matching `tmux: switch status theme to Cursor Dark`).
- `install.conf.yml:23,25` — the two link entries to remove:

  ```yaml
      ~/.config/alacritty/alacritty.yml: config/alacritty.yml
      ...
      ~/.config/kitty/kitty.conf: config/kitty.conf
  ```

- `README.md` — documents only the Cursor-extensions snapshot workflow plus
  "Acknowledgements" for the wiped nvim config. No setup/install
  instructions at all.
- `.gitignore` (repo root) — currently ignores only `.codex/` (with an
  explanatory comment) — preserve that entry and its comment.
- `docs/nvim.md` — generic nvim debugging tips; harmless, KEEP (out of scope).
- `config/nvim.bak/` — deliberate archive, KEEP (out of scope).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Confirm terminal configs are stale | `git log -1 --format="%as %s" -- config/kitty.conf config/alacritty.yml config/iterm` | date ≤ 2025-11 |
| YAML validity | `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"` | exit 0 |
| No dangling references | `grep -rn "kitty\|alacritty\|iterm\|playground" --exclude-dir=.git --exclude-dir=dotbot --exclude-dir=config/nvim.bak --exclude-dir=plans .` | no matches after deletion |

## Scope

**In scope** (the only files you should modify/delete):
- `Brewfile.lock.json` (delete, then ignore)
- `playground.lua` (delete)
- `config/kitty.conf`, `config/alacritty.yml`, `config/iterm/` (delete)
- `install.conf.yml` (remove the two dead link lines only)
- `.gitignore` (add `Brewfile.lock.json`)
- `README.md` (rewrite)

**Out of scope** (do NOT touch, even though they look related):
- `docs/nvim.md`, `config/nvim.bak/` — kept deliberately.
- `Brewfile` itself — content decisions (e.g. node-vs-nvm) are the
  operator's; see direction notes in `plans/README.md`.
- `config/tmux/`, `config/ghostty` — active.
- Anything under `~/.config` on disk — the orphaned symlinks are dotbot
  clean's job (plan 001), not yours.

## Git workflow

- Branch: `advisor/005-prune-dead-config`
- Two commits: `prune stale lockfile, unused terminal configs, empty playground.lua`
  and `readme: document install flow`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Confirm staleness, then delete

Run the staleness check from the commands table. If it confirms (no commits
after 2025-12 touching those paths):

```sh
git rm Brewfile.lock.json playground.lua config/kitty.conf config/alacritty.yml
git rm -r config/iterm
```

**Verify**: `git status --porcelain` → five `D`/`R` entries, nothing else yet.

### Step 2: Ignore future lockfile regeneration

Append to `.gitignore` (keep the existing `.codex/` entry and comment):

```
# brew bundle regenerates this; not useful to track for a personal machine
Brewfile.lock.json
```

**Verify**: `git check-ignore Brewfile.lock.json` → prints the path, exit 0.

### Step 3: Remove the two dead links from `install.conf.yml`

Delete exactly these lines from the `link:` block:

```yaml
    ~/.config/alacritty/alacritty.yml: config/alacritty.yml
    ~/.config/kitty/kitty.conf: config/kitty.conf
```

**Verify**: `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"`
→ exit 0; `grep -c "kitty\|alacritty" install.conf.yml` → `0`.

### Step 4: Rewrite `README.md`

Replace the whole file with (adjust wording freely, keep all sections):

```markdown
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
```

Caveats: only claim "safe and idempotent" if plan 001 has landed (check
`plans/README.md` status); only mention the one-time wipe semantics if 001
landed — otherwise describe current behavior. Keep the Cursor section's
content unchanged from the original (it's accurate and referenced by
`config/claude/CLAUDE.md`).

**Verify**: `grep -c "Acknowledgements" README.md` → `0`;
`grep -c "./install" README.md` → ≥ 1.

### Step 5: Repo-wide dangling-reference sweep

**Verify**: the "No dangling references" grep from the commands table → no
matches (kitty/alacritty/iterm/playground absent everywhere outside git
history, `dotbot/`, `config/nvim.bak/`, and `plans/`).

## Test plan

No test framework. Gates: the per-step verifications plus
`python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"`.
Operator follow-up after merge: run `./install` once so dotbot's clean task
removes the now-dead `~/.config/kitty` / `~/.config/alacritty` symlinks
(requires plan 001's non-forced clean — still works, those links point into
the dotfiles dir).

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `test ! -e Brewfile.lock.json && test ! -e playground.lua && test ! -e config/kitty.conf && test ! -e config/alacritty.yml && test ! -d config/iterm` exits 0
- [ ] `git check-ignore Brewfile.lock.json` exits 0
- [ ] `grep -c "kitty\|alacritty" install.conf.yml` → 0
- [ ] `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"` exits 0
- [ ] README has an Install section; no Acknowledgements section
- [ ] `git status --porcelain` touches only in-scope files
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- `git log` shows any commit touching `config/kitty.conf`,
  `config/alacritty.yml`, or `config/iterm` dated after 2025-12 — the
  "unused" assumption is wrong; report instead of deleting.
- Anything outside this repo (e.g. a script in `~/bin`) is found referencing
  these configs — you can't check the whole machine, so limit to repo greps,
  but report any in-repo hit.
- The operator's working tree has uncommitted changes to any in-scope file.

## Maintenance notes

- The deletions are one `git revert` away; mention in the PR body that
  restoring kitty/alacritty support = revert + re-adding the two
  install.conf.yml lines.
- If the operator later switches terminals again, prefer adding the new
  config + link over resurrecting the old ones from history.
- Deferred deliberately: trimming the Brewfile itself (taps like
  `jason0x43/neovim-nightly`, duplicated tooling) — needs the operator's
  knowledge of what's still used; revisit as its own audit pass if asked.
