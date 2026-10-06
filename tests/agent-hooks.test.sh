#!/usr/bin/env bash
# Sanity checks for the tracked agent session hooks (Claude Code, Codex,
# OpenCode).
#
# Two installers write into these files through the Home Manager symlinks:
# - `herdr integration install <agent>` only recognizes its own hook form,
#   `bash '/Users/jrnxf/...'`. Any other spelling of the same hook gets a
#   second copy appended beside it, so the tracked files keep herdr's form.
# - `lavish-axi setup hooks` writes the CLI's /nix/store path, which breaks on
#   the next lavish-axi upgrade.
# Run this before committing a change to any of these files.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

CLAUDE="$ROOT/home/.claude/settings.json"
CODEX="$ROOT/home/.codex/hooks.json"
OPENCODE_LAVISH="$ROOT/home/.config/opencode/plugins/axi-lavish-axi.js"

# Every hook command, one per line, prefixed with its event name.
hook_commands() {
  jq -r '.hooks | to_entries[] | .key as $event | .value[].hooks[].command | "\($event)\t\(.)"' "$1"
}

for file in "$CLAUDE" "$CODEX"; do
  name=${file#"$ROOT/"}
  commands=$(hook_commands "$file") || fail "$name is not valid hook JSON"

  foreign=$(printf '%s\n' "$commands" | grep '/Users/' | grep -v '/Users/jrnxf/')
  [ -z "$foreign" ] || fail "$name has a hook under another user's home: $foreign"
  # shellcheck disable=SC2016 # the literal text $HOME is what must be absent
  assert_not_contains "$commands" '$HOME' "$name spells a hook with \$HOME; herdr would append a duplicate, use /Users/jrnxf"
  assert_not_contains "$commands" "/nix/store/" "$name has a hook with a /nix/store path; call the tool by name"

  duplicates=$(printf '%s\n' "$commands" | grep 'herdr-agent-state' | cut -f1 | sort | uniq -d)
  [ -z "$duplicates" ] || fail "$name runs herdr-agent-state more than once on: $(printf '%s' "$duplicates" | tr '\n' ' ')"

  lavish=$(printf '%s\n' "$commands" | grep 'lavish' | cut -f2)
  [ "$lavish" = "lavish-axi" ] || fail "$name should run lavish-axi by bare name exactly once, got: ${lavish:-nothing}"
done
pass "Claude Code and Codex hooks are stable under reinstall and not duplicated"

plugin=$(cat "$OPENCODE_LAVISH")
assert_contains "$plugin" 'const command = "lavish-axi";' "OpenCode lavish plugin must call lavish-axi by bare name"
assert_not_contains "$plugin" "axi-sdk-js managed opencode plugin" "OpenCode lavish plugin must not carry the managed marker, or setup overwrites it"
pass "OpenCode lavish plugin is portable and unmanaged"
