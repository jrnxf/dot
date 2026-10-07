#!/usr/bin/env bash
# Behavior checks for the Linux login directory in home/.zshrc.
#
# The block is lifted out of the tracked file and run in a throwaway HOME, so
# nothing here connects anywhere or touches a herdr session.
# The single-quoted snippets below are zsh source and sed patterns; nothing in
# them is meant to expand here.
# shellcheck disable=SC2016
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ZSHRC="$ROOT/home/.zshrc"
command -v zsh >/dev/null || fail "zsh is required to test home/.zshrc"
zsh -n "$ZSHRC" || fail "home/.zshrc has a syntax error"

login_source=$(sed -n '/^if \[\[ \$OSTYPE == linux\* && -o login /,/^fi$/p' "$ZSHRC")
[ -n "$login_source" ] || fail "Linux login directory block not found in home/.zshrc"

dotfiles_test_tmproot tmp dotfiles-login-dir
# Resolve symlinks (macOS /var -> /private/var) so $PWD comparisons hold.
tmp=$(cd "$tmp" && pwd -P)

host="$tmp/host"
away="$tmp/away"
mkdir -p "$host/firstmate" "$away"

# login_dir <ostype> <home> <start dir> [zsh flags and env assignments...]
# Runs the block in a fresh shell and prints where that shell ends up. TMUX and
# HERDR_ENV are cleared first so the result does not depend on where the test
# itself runs.
login_dir() {
  local ostype=$1 home=$2 start=$3
  shift 3
  ( cd "$start" && env -u TMUX -u HERDR_ENV HOME="$home" LOGIN_SOURCE="$login_source" FAKE_OSTYPE="$ostype" "$@" \
      -c 'OSTYPE=$FAKE_OSTYPE; eval "$LOGIN_SOURCE"; print -r -- "$PWD"' )
}

mkdir -p "$host/elsewhere"
[ "$(login_dir linux-gnu "$host" "$host" zsh -f -l)" = "$host/firstmate" ] || fail "a Linux login shell in \$HOME should start in ~/firstmate"
[ "$(login_dir linux-gnu "$host" "$host" zsh -f)" = "$host" ] || fail "a non-login shell must keep its directory"
[ "$(login_dir linux-gnu "$host" "$host/elsewhere" zsh -f -l)" = "$host/elsewhere" ] || fail "a login shell started outside \$HOME must keep its directory"
[ "$(login_dir linux-gnu "$host" "$host" TMUX=/tmp/tmux-0/default,1,0 zsh -f -l)" = "$host" ] || fail "a tmux window must keep its directory"
[ "$(login_dir linux-gnu "$host" "$host" HERDR_ENV=1 zsh -f -l)" = "$host" ] || fail "a herdr pane must keep its directory"
[ "$(login_dir darwin25.0 "$host" "$host" zsh -f -l)" = "$host" ] || fail "the Mac's login directory must not change"
[ "$(login_dir linux-gnu "$away" "$away" zsh -f -l)" = "$away" ] || fail "a machine without ~/firstmate must keep its login directory"
pass "only a Linux login shell sitting in \$HOME moves to ~/firstmate"

# The block lives in .zshrc, which zsh reads for interactive shells only: a
# command run over ssh, scp or rsync starts a shell that never reaches it.
zdot="$tmp/zdot"
mkdir -p "$zdot"
printf 'OSTYPE=linux-gnu\n%s\n' "$login_source" > "$zdot/.zshrc"
rc_dir() {
  ( cd "$host" && env -u TMUX -u HERDR_ENV HOME="$host" ZDOTDIR="$zdot" zsh "$@" -c 'print -r -- "$PWD"' 2>/dev/null | tail -n 1 )
}
[ "$(rc_dir -l -i)" = "$host/firstmate" ] || fail "an interactive login shell reading .zshrc should start in ~/firstmate"
[ "$(rc_dir -l)" = "$host" ] || fail "a non-interactive login shell must keep its directory"
[ "$(rc_dir)" = "$host" ] || fail "a non-interactive command shell must keep its directory"
pass "non-interactive shells never reach the login directory change"
