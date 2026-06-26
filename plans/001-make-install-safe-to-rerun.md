# Plan 001: Make `./install` safe to re-run

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 323303b..HEAD -- install.conf.yml setup/neovim.sh`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `323303b`, 2026-06-12

## Why this matters

`./install` is meant to be re-run any time a link is added to
`install.conf.yml`. Today a re-run has two destructive side effects:

1. `setup/neovim.sh` unconditionally `rm -rf`s `~/.config/nvim`,
   `~/.cache/nvim`, `~/.local/share/nvim`, and `~/.local/state/nvim`. The
   wipe was a one-time migration (commit `58c0037` "wipe nvim config, archive
   old setup as nvim.bak"), but as written it re-fires on every install run —
   any nvim config, plugins, shada/undo history built *after* the migration
   is silently destroyed the next time the user re-runs `./install` for an
   unrelated reason.
2. The dotbot `clean` task uses `force: true` on `~/`, which makes dotbot
   delete **any** broken symlink in the top level of the home directory, not
   just dead links pointing into this dotfiles repo. Broken symlinks owned by
   other tools get removed without warning.

After this plan, `./install` is idempotent: re-running it never deletes
anything that this repo did not create.

## Current state

- `setup/neovim.sh` — the wipe script, runs on every install via
  `install.conf.yml`'s shell task list:

  ```sh
  #!/bin/sh
  # Wipe all Neovim state so each machine starts from a barebones install.
  # Old config is preserved in this repo at config/nvim.bak for reference.
  set -e

  rm -rf \
    "${HOME}/.config/nvim" \
    "${HOME}/.cache/nvim" \
    "${HOME}/.local/share/nvim" \
    "${HOME}/.local/state/nvim"
  ```

- `install.conf.yml:7-13` — the clean task:

  ```yaml
  - clean:
      ~/:
        force: true
      ~/.config:
        recursive: true
      ~/.claude:
        recursive: true
  ```

  Dotbot semantics: by default `clean` only removes dead symlinks that point
  *into* the dotfiles directory (safe). `force: true` extends removal to dead
  symlinks pointing anywhere. The `~/.config` and `~/.claude` entries do NOT
  have `force` and are already safe.

- Repo conventions: setup scripts are POSIX `#!/bin/sh`, short, commented at
  the top with their purpose (see `setup/cursor.sh` as the exemplar).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Shell syntax check | `sh -n setup/neovim.sh` | exit 0, no output |
| YAML validity | `python3 -c "import yaml,sys; yaml.safe_load(open('install.conf.yml'))"` | exit 0, no output |
| Confirm force removed | `grep -n "force: true" install.conf.yml` | exactly one match, inside the `link:` defaults block (line ~5), none inside `clean:` |

Do NOT run `./install` as verification — it mutates the operator's home
directory and is the operator's job to run after review.

## Scope

**In scope** (the only files you should modify):
- `setup/neovim.sh`
- `install.conf.yml` (the `clean:` block only)

**Out of scope** (do NOT touch, even though they look related):
- `config/nvim.bak/` — archived old config, reference only.
- The `link:` and `shell:` sections of `install.conf.yml`.
- Other setup scripts (`mac.sh`, `claude.sh`, `cursor.sh`) — covered by plan 002.

## Git workflow

- Branch: `advisor/001-make-install-safe-to-rerun`
- Single commit; message style matches repo: lowercase area prefix, e.g.
  `install: make re-runs non-destructive` (cf. `tmux: switch status theme to
  Cursor Dark with a11y contrast`).
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Gate the nvim wipe behind a sentinel file

Replace the body of `setup/neovim.sh` with:

```sh
#!/bin/sh
# One-time migration: wipe all Neovim state so the machine starts from a
# barebones install. Old config is preserved in this repo at config/nvim.bak.
# A sentinel file marks the wipe as done so install re-runs never touch
# Neovim state built after the migration.
set -e

sentinel="${HOME}/.local/state/dotfiles/nvim-wiped"

if [ -f "$sentinel" ]; then
  exit 0
fi

rm -rf \
  "${HOME}/.config/nvim" \
  "${HOME}/.cache/nvim" \
  "${HOME}/.local/share/nvim" \
  "${HOME}/.local/state/nvim"

mkdir -p "$(dirname "$sentinel")"
touch "$sentinel"
echo "Neovim state wiped (one-time migration); sentinel at $sentinel"
```

Note the ordering: the sentinel is created *after* the `rm -rf` (which
deletes `~/.local/state/nvim`, a sibling of the sentinel's parent dir, so the
order matters).

**Verify**: `sh -n setup/neovim.sh` → exit 0. Then
`grep -c "sentinel" setup/neovim.sh` → `5`.

### Step 2: Remove `force: true` from the clean task

In `install.conf.yml`, change:

```yaml
- clean:
    ~/:
      force: true
    ~/.config:
```

to:

```yaml
- clean:
    ~/: {}
    ~/.config:
```

(`~/: {}` keeps cleaning dead dotfiles-owned links in `~` with default, safe
semantics. Do not touch the `force: true` under `defaults: link:` at the top
of the file — that one controls link overwriting, not cleaning, and is
intentional.)

**Verify**: `python3 -c "import yaml,sys; c=yaml.safe_load(open('install.conf.yml')); print([t for t in c if 'clean' in t])"`
→ prints the clean task with `'~/': {}` (or `None`) and no `force` key.

## Test plan

No test framework exists in this repo (shell-script config repo). The
verification commands above are the test gate. The operator's acceptance test
is running `./install` twice after merge and confirming the second run prints
the no-op behavior (no "Neovim state wiped" line).

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `sh -n setup/neovim.sh` exits 0
- [ ] `grep -n "rm -rf" setup/neovim.sh` shows the rm guarded below the sentinel check (sentinel check on an earlier line)
- [ ] `grep -A2 "clean:" install.conf.yml` contains no `force`
- [ ] `python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"` exits 0
- [ ] `git status --porcelain` shows only `setup/neovim.sh` and `install.conf.yml` modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The live `setup/neovim.sh` or the `clean:` block doesn't match the
  "Current state" excerpts (drift).
- `python3 -c "import yaml"` fails (no PyYAML on this machine) — fall back to
  `ruby -ryaml -e "YAML.load_file('install.conf.yml')"`; if that's also
  unavailable, report instead of skipping YAML validation.
- You find any other script in the repo that depends on the nvim wipe
  re-running (grep for `nvim-wiped` and `neovim.sh` first — only
  `install.conf.yml` should reference it).

## Maintenance notes

- If the user ever wants to re-trigger the migration on a machine, the
  documented way is `rm ~/.local/state/dotfiles/nvim-wiped && ./install`.
- Plan 005 deletes terminal configs whose `~/.config` symlinks then become
  dead; the (non-forced) clean task is what garbage-collects those, so keep
  the `clean:` entries for `~/.config` even if they look unused.
- Reviewer should scrutinize: sentinel path creation order vs. the `rm -rf`
  list (the rm deletes `~/.local/state/nvim`; sentinel lives in
  `~/.local/state/dotfiles/` — siblings, not nested).
