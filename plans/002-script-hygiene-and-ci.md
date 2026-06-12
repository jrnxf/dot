# Plan 002: Make setup scripts shellcheck-clean and add a CI baseline

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 323303b..HEAD -- setup/mac.sh setup/claude.sh setup/cursor.sh install .github`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/001-make-install-safe-to-rerun.md (soft — only so CI lints the post-001 version of `setup/neovim.sh`; can run before it if needed)
- **Category**: dx
- **Planned at**: commit `323303b`, 2026-06-12

## Why this matters

This repo has no automated verification at all: no CI, no shellcheck, no
config-file validation. Real defects are already sitting in the scripts —
`setup/mac.sh` uses the bash-only `[[` under `#!/bin/sh`, and
`setup/claude.sh` re-runs `claude mcp add` for servers that already exist,
producing errors on every install re-run. A config repo's failure mode is
discovering breakage months later on a brand-new machine, which is exactly
when you can least afford it. A small lint workflow catches these at push
time.

## Current state

- `setup/mac.sh` — Homebrew bootstrap + macOS defaults. Bugs/typos:

  ```sh
  #!/bin/sh
  # set up homebrew
  if [[ $(command -v brew) == "" ]]; then      # bashism under sh; fragile test
      echo "Installing Hombrew"                 # typo
  ...
  echo "Changin mac defaults"                   # typo
  ```

  No `set -e`. `brew bundle install` relies on cwd being the repo root
  (true today — `install` cd's there — but implicit).

- `setup/claude.sh` — installs Claude Code, registers 5 MCP servers
  (`linear-server`, `graphite`, `statsig`, `playwright`, `posthog`) with
  unconditional `claude mcp add ...` calls at lines 22–33. Re-runs error on
  each already-registered server. No `set -e` (deliberate-ish: MCP failures
  shouldn't abort install — preserve that property).

- `setup/cursor.sh`, `setup/neovim.sh`, `install`,
  `config/claude/hooks/cmux-notify.sh`, `config/claude/statusline-command.sh`
  — believed shellcheck-clean or near-clean; CI will confirm.

- `shell/zsh/zshrc` — zsh, NOT shellcheck-compatible (shellcheck doesn't
  support zsh). Syntax-check with `zsh -n` instead.

- Tracked JSON: strict JSON (`config/karabiner.json`,
  `config/cursor/keybindings.json`, `config/claude/settings.json`,
  `config/cursor/extensions.txt` is plain text). JSONC (comments/trailing
  commas — **jq will fail on these, that is expected**):
  `config/cursor/settings.json`, `config/cmux/cmux.json`.

- Commit convention: the user's `sc` alias creates commits titled
  `squash [skip-ci]`. Note the hyphen: GitHub Actions' built-in skip only
  honors `[skip ci]` (space), so the workflow must implement the hyphenated
  skip itself.

- There is no `.github/` directory in the repo root (the `dotbot/` submodule
  has its own — leave it alone).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Shellcheck locally (if installed) | `shellcheck install setup/*.sh config/claude/hooks/cmux-notify.sh config/claude/statusline-command.sh` | exit 0 |
| sh syntax | `sh -n setup/mac.sh && sh -n setup/claude.sh` | exit 0 |
| zsh syntax | `zsh -n shell/zsh/zshrc` | exit 0 |
| Workflow YAML validity | `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` | exit 0 |
| Strict JSON | `jq empty config/karabiner.json config/cursor/keybindings.json config/claude/settings.json` | exit 0 |

If `shellcheck` is not installed locally, do NOT install it (no mutations of
the operator's machine) — rely on `sh -n` locally and let CI run shellcheck.

## Scope

**In scope** (the only files you should modify/create):
- `setup/mac.sh`
- `setup/claude.sh`
- `.github/workflows/ci.yml` (create)
- Only if CI/shellcheck finds errors in them: minimal fixes to
  `setup/cursor.sh`, `install`, `config/claude/hooks/cmux-notify.sh`,
  `config/claude/statusline-command.sh`

**Out of scope** (do NOT touch, even though they look related):
- `dotbot/` submodule (has its own CI).
- `shell/zsh/zshrc` content fixes — plan 004 owns zshrc; CI only `zsh -n`s it.
- `setup/neovim.sh` rewrite — plan 001 owns it.
- Adding shellcheck to the Brewfile — operator decision, note in PR instead.

## Git workflow

- Branch: `advisor/002-script-hygiene-and-ci`
- Commits: one per logical unit (`setup: fix sh portability and typos`,
  `ci: add lint workflow`). Match repo style: lowercase area prefix.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Fix `setup/mac.sh`

Rewrite to POSIX sh:

```sh
#!/bin/sh
# Set up Homebrew, install packages from the Brewfile, set macOS defaults.
set -e

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Updating Homebrew"
  brew update
fi

echo "Installing packages"
brew bundle install --file "$(dirname "$0")/../Brewfile"

echo "Changing mac defaults"
# allow dragging windows with ctrl+cmd, and left click dragging inside (works on most windows) ** requires restart
defaults write -g NSWindowShouldDragOnGesture -bool true
# defaults delete -g NSWindowShouldDragOnGesture # to stop this behaviour
```

**Verify**: `sh -n setup/mac.sh` → exit 0. `grep -c '\[\[' setup/mac.sh` → `0`.

### Step 2: Make `setup/claude.sh` idempotent

Replace each unconditional `claude mcp add ...` (lines 22–33) with a
get-or-add guard, preserving the exact server names/args:

```sh
add_mcp() {
  name="$1"; shift
  if claude mcp get "$name" >/dev/null 2>&1; then
    echo "MCP server '$name' already configured, skipping."
  else
    claude mcp add "$name" "$@"
  fi
}

add_mcp linear-server --transport http --url https://mcp.linear.app/mcp
add_mcp graphite -- gt mcp
add_mcp statsig --transport http --url https://api.statsig.com/v1/mcp
add_mcp playwright -- npx @playwright/mcp@latest
add_mcp posthog --transport http --url https://mcp.posthog.com/mcp
```

Keep the existing header comment, the Claude Code install block, the
post-install `command -v` bail, and the trailing NOTE about secret-bearing
servers exactly as they are. Do NOT add `set -e` to this script — an MCP
registration failure must not abort the rest of `./install`.

**Verify**: `sh -n setup/claude.sh` → exit 0.
`grep -c "add_mcp " setup/claude.sh` → `6` (1 definition + 5 calls).

### Step 3: Create `.github/workflows/ci.yml`

```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    # GitHub only auto-skips "[skip ci]"; this repo's squash alias uses "[skip-ci]"
    if: "!contains(github.event.head_commit.message, '[skip-ci]')"
    steps:
      - uses: actions/checkout@v4

      - name: shellcheck
        run: |
          sudo apt-get update -q && sudo apt-get install -y -q shellcheck zsh
          shellcheck install setup/*.sh \
            config/claude/hooks/cmux-notify.sh \
            config/claude/statusline-command.sh

      - name: zsh syntax
        run: zsh -n shell/zsh/zshrc

      - name: strict JSON
        run: |
          jq empty config/karabiner.json \
            config/cursor/keybindings.json \
            config/claude/settings.json

      - name: JSONC (cursor settings, cmux)
        run: |
          npx --yes json5 config/cursor/settings.json > /dev/null
          npx --yes json5 config/cmux/cmux.json > /dev/null

      - name: dotbot config parses
        run: python3 -c "import yaml; yaml.safe_load(open('install.conf.yml'))"
```

Note: checkout does not need submodules — nothing lints `dotbot/`.

**Verify**: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` → exit 0.

### Step 4: Run the CI steps locally and fix what they find

Run each step's command locally (skip shellcheck if not installed; skip the
apt-get line — it's CI-only). If shellcheck (local or via the operator's
later CI run) flags errors in `setup/cursor.sh`, `install`,
`cmux-notify.sh`, or `statusline-command.sh`, apply the minimal fix.
Stylistic-only warnings (SC2086-class quoting in clearly-safe spots) may be
fixed or annotated with a targeted `# shellcheck disable=SCXXXX` + reason —
do not blanket-disable.

**Verify**: every command from the "Commands you will need" table → expected
results.

## Test plan

The CI workflow IS the test. Local proxy: the verification commands per step.
After merge, the operator should confirm the first Actions run is green and
that a `squash [skip-ci]` commit skips the job.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `sh -n setup/mac.sh && sh -n setup/claude.sh && sh -n setup/cursor.sh` exits 0
- [ ] `grep -c '\[\[' setup/mac.sh` → 0
- [ ] `grep -n "claude mcp add" setup/claude.sh` shows adds only inside `add_mcp` (no bare top-level adds)
- [ ] `.github/workflows/ci.yml` exists and parses as YAML
- [ ] `jq empty config/karabiner.json config/cursor/keybindings.json config/claude/settings.json` exits 0
- [ ] `zsh -n shell/zsh/zshrc` exits 0
- [ ] `git status --porcelain` shows only in-scope files modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- `claude mcp get` is not a valid subcommand of the installed Claude CLI
  (check `claude mcp --help`) — report the actual idempotency-check
  subcommand available instead of guessing.
- shellcheck reports errors in `install` or the hook scripts that require
  behavioral changes (not just quoting) to fix.
- `zsh -n shell/zsh/zshrc` fails at baseline (before any of your changes) —
  that's pre-existing breakage belonging to plan 004; report it.
- Fixing a shellcheck finding would require touching `shell/zsh/zshrc` or
  `setup/neovim.sh` (other plans own those).

## Maintenance notes

- Plan 003 adds a new `setup/zsh.sh`; it must be added to the shellcheck
  glob's coverage (it is — `setup/*.sh` covers it automatically).
- If the operator later renames the `sc` alias to use `[skip ci]`, the
  custom `if:` guard in ci.yml becomes redundant but harmless.
- Reviewer should scrutinize: that `add_mcp` preserves the exact transport
  flags per server, and that `set -e` was added to `mac.sh` but deliberately
  NOT to `claude.sh`.
- Deferred: adding `shellcheck` to the Brewfile (operator call); pre-commit
  hooks (overkill for a single-user config repo).
