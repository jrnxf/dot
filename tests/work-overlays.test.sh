#!/usr/bin/env bash
# Behavior tests for work-overlays.sh, the activation step that applies the
# machine-local `.work` overlays. Runs against a fixture checkout and a
# temporary HOME, never the live ones.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT="$ROOT/work-overlays.sh"

dotfiles_test_tmproot TMP work-overlays
DOTFILES="$TMP/dotfiles"
INSTRUCTIONS="$TMP/state/dotfiles/AGENTS.md"
export HOME="$TMP/home"

mkdir -p "$DOTFILES/home/.agents/skills/tracked" "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"
printf '# shared\n' > "$DOTFILES/home/AGENTS.md"
# Links Home Manager or an installer owns, which the script must leave alone.
for dir in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  ln -s "$DOTFILES/home/.agents/skills/tracked" "$dir/tracked"
  ln -s "$TMP/missing" "$dir/foreign-dangling"
done

apply() {
  "$SCRIPT" "$DOTFILES" "$INSTRUCTIONS" 2>"$TMP/stderr" || fail "work-overlays.sh exited non-zero: $(cat "$TMP/stderr")"
}

home_listing() {
  (cd "$HOME" && find . -print0 | sort -z | xargs -0 ls -ld | awk '{print $1, $NF}')
}

# --- no overlay ----------------------------------------------------------------

before=$(home_listing)
apply
[ -L "$INSTRUCTIONS" ] && [ "$(readlink "$INSTRUCTIONS")" = "$DOTFILES/home/AGENTS.md" ] \
  || fail "without an overlay the instructions must be a live link to home/AGENTS.md"
[ "$(home_listing)" = "$before" ] || fail "without an overlay HOME must not change"
[ ! -s "$TMP/stderr" ] || fail "without an overlay nothing should be reported: $(cat "$TMP/stderr")"
pass "no overlay keeps a live link to home/AGENTS.md and leaves HOME untouched"

# --- overlay present -----------------------------------------------------------

printf '# machine only\n' > "$DOTFILES/home/AGENTS.work.md"
mkdir -p "$DOTFILES/home/.agents/skills/extra.work"
apply
[ -f "$INSTRUCTIONS" ] && [ ! -L "$INSTRUCTIONS" ] || fail "with an overlay the instructions must be a generated file"
[ "$(cat "$INSTRUCTIONS")" = "$(printf '# shared\n\n# machine only')" ] \
  || fail "instructions must be home/AGENTS.md followed by home/AGENTS.work.md, got: $(cat "$INSTRUCTIONS")"
for dir in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  [ "$(readlink "$dir/extra")" = "$DOTFILES/home/.agents/skills/extra.work" ] \
    || fail "$dir/extra must link to the extra.work overlay"
done
pass "overlay is appended to the instructions and its skill is linked without the suffix"

printf '# shared, edited\n' > "$DOTFILES/home/AGENTS.md"
after_first=$(home_listing)
apply
[ "$(home_listing)" = "$after_first" ] || fail "rerunning with the same overlays must not change HOME"
[ ! -s "$TMP/stderr" ] || fail "rerunning must not report anything: $(cat "$TMP/stderr")"
assert_contains "$(cat "$INSTRUCTIONS")" "# shared, edited" "rerunning must regenerate the instructions from current files"
pass "rerunning is idempotent and picks up edits"

# --- collision -----------------------------------------------------------------

mkdir -p "$DOTFILES/home/.agents/skills/tracked.work"
apply
assert_contains "$(cat "$TMP/stderr")" "already exists" "a name already taken must be reported"
[ "$(readlink "$HOME/.claude/skills/tracked")" = "$DOTFILES/home/.agents/skills/tracked" ] \
  || fail "an overlay must never replace an existing skill"
rmdir "$DOTFILES/home/.agents/skills/tracked.work"
pass "an overlay never replaces an existing skill of the same name"

# --- overlay removed -----------------------------------------------------------

rm "$DOTFILES/home/AGENTS.work.md"
rmdir "$DOTFILES/home/.agents/skills/extra.work"
apply
[ -L "$INSTRUCTIONS" ] && [ "$(readlink "$INSTRUCTIONS")" = "$DOTFILES/home/AGENTS.md" ] \
  || fail "removing the overlay must restore the live link"
[ "$(home_listing)" = "$before" ] || fail "removing the overlays must return HOME to its original state"
pass "removing the overlays restores the live link and drops their skill links"

# --- gitignore -----------------------------------------------------------------

for path in home/AGENTS.work.md home/.agents/skills/extra.work/SKILL.md; do
  git -C "$ROOT" check-ignore -q --no-index "$path" || fail "$path must be gitignored"
done
for path in home/AGENTS.md home/.agents/skills/lavish/SKILL.md; do
  ! git -C "$ROOT" check-ignore -q --no-index "$path" || fail "$path must not be gitignored"
done
pass "overlays are gitignored and tracked files are not"
