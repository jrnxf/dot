#!/usr/bin/env bash
# Checks the Claude Code leaf mod (home/.claude/skills/leaf) with Claude Code's
# own plugin tooling: `validate` reads the manifest and hooks module the way a
# session will, and `test` runs the mod's *.test.ts files against the engine.
#
# Claude Code writes type declarations into a mod folder it loads, and the
# folder is linked into ~/.claude/skills from this repo, so the last check is
# that none of that shows up as a change to commit.
# Run this before committing a change to the mod.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MOD="$ROOT/home/.claude/skills/leaf"

if ! command -v claude >/dev/null 2>&1; then
  echo "skip: claude not found for the leaf mod checks"
  exit 0
fi

output=$(claude plugin validate "$MOD" 2>&1) || fail "claude plugin validate refused the leaf mod: $output"
assert_contains "$output" "Validation passed" "claude plugin validate did not pass the leaf mod: $output"
pass "leaf mod validates"

output=$(claude plugin test "$MOD" 2>&1) || fail "leaf mod tests failed: $output"
assert_contains "$output" " 0 fail" "leaf mod tests did not report zero failures: $output"
pass "leaf mod tests pass"

untracked=$(git -C "$ROOT" status --porcelain --untracked-files=all -- "$MOD" | grep '^??')
[ -z "$untracked" ] || fail "Claude Code left untracked files in the leaf mod folder: $untracked"
pass "leaf mod folder has nothing new to commit"
