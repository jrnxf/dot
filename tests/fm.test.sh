#!/usr/bin/env bash
# Behavior checks for `fm` and the Linux login directory in home/.zshrc.
#
# Both are lifted out of the tracked file and run in a throwaway HOME, with
# herdr and ssh replaced by stubs that only record how they were called, so
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

fm_source=$(sed -n '/^fm() {$/,/^}$/p' "$ZSHRC")
[ -n "$fm_source" ] || fail "fm function not found in home/.zshrc"
login_source=$(sed -n '/^if \[\[ \$OSTYPE == linux\* && -o login /,/^fi$/p' "$ZSHRC")
[ -n "$login_source" ] || fail "Linux login directory block not found in home/.zshrc"

dotfiles_test_tmproot tmp dotfiles-fm
# Resolve symlinks (macOS /var -> /private/var) so $PWD comparisons hold.
tmp=$(cd "$tmp" && pwd -P)
calls="$tmp/calls"

# --- fm ------------------------------------------------------------------------

# make_bin <dir> <herdr exit status|none>: none leaves herdr out.
make_bin() {
  local dir=$1 status=$2
  mkdir -p "$dir"
  cat > "$dir/ssh" <<EOF
#!/bin/sh
printf 'ssh %s\n' "\$*" >> "$calls"
EOF
  chmod +x "$dir/ssh"
  [ "$status" = none ] && return
  cat > "$dir/herdr" <<EOF
#!/bin/sh
printf 'herdr %s [config=%s] [cwd=%s]\n' "\$*" "\${HERDR_CONFIG_PATH:-}" "\$PWD" >> "$calls"
exit $status
EOF
  chmod +x "$dir/herdr"
}

# run_fm <ostype> <home> <bin dir> [NAME=value...] [fm arguments...]
# Prints the directory fm left the shell in; what fm itself said goes to
# $fm_err. TMUX, HERDR_ENV and HERDR_CONFIG_PATH are cleared first so the result
# does not depend on where the test itself runs.
run_fm() {
  local ostype=$1 home=$2 bin=$3
  local -a vars=()
  shift 3
  while [ $# -gt 0 ]; do
    case $1 in
      *=*) vars+=("$1"); shift ;;
      *) break ;;
    esac
  done
  : > "$calls"
  env -u TMUX -u HERDR_ENV -u HERDR_CONFIG_PATH HOME="$home" PATH="$bin:/usr/bin:/bin" \
    FM_SOURCE="$fm_source" FAKE_OSTYPE="$ostype" ${vars[@]+"${vars[@]}"} \
    zsh -f -c 'OSTYPE=$FAKE_OSTYPE; cd "$HOME"; eval "$FM_SOURCE"; fm "$@"; print -r -- "$PWD"' fm-test "$@" \
    2> "$fm_err"
}

host="$tmp/host"
away="$tmp/away"
mkdir -p "$host/firstmate" "$away"
fm_err="$tmp/fm-err"
mac="darwin25.0"
linux="linux-gnu"
ssh_fallback="ssh -t firstmate cd ~/firstmate && exec herdr"
# remote_attach <home>: the one herdr call a macOS fm makes from that home.
remote_attach() {
  printf 'herdr --remote firstmate [config=%s/.config/herdr-firstmate/config.toml] [cwd=%s]' "$1" "$1"
}

make_bin "$tmp/bin-new" 0
make_bin "$tmp/bin-refused" 1
make_bin "$tmp/bin-none" none

# macOS: always the Linux machine, whatever is in the local home.
[ "$(run_fm "$mac" "$away" "$tmp/bin-new")" = "$away" ] || fail "fm should leave the local directory alone when it connects"
[ "$(cat "$calls")" = "$(remote_attach "$away")" ] \
  || fail "fm should remote-attach with the Firstmate config and nothing else, ran: $(cat "$calls")"
pass "fm on macOS remote-attaches with the Firstmate config"

[ "$(run_fm "$mac" "$host" "$tmp/bin-new")" = "$host" ] || fail "fm on macOS must not change into a local ~/firstmate"
[ "$(cat "$calls")" = "$(remote_attach "$host")" ] \
  || fail "fm on macOS should remote-attach even with a local ~/firstmate, ran: $(cat "$calls")"
pass "fm on macOS still remote-attaches when a local ~/firstmate exists"

run_fm "$mac" "$host" "$tmp/bin-refused" >/dev/null
[ "$(sed -n 1p "$calls")" = "$(remote_attach "$host")" ] || fail "fm should try remote attach first, ran: $(cat "$calls")"
[ "$(sed -n 2p "$calls")" = "$ssh_fallback" ] || fail "fm should fall back to ssh when remote attach fails, ran: $(cat "$calls")"
pass "fm on macOS falls back to plain ssh when remote attach fails"

run_fm "$mac" "$host" "$tmp/bin-none" >/dev/null
[ "$(cat "$calls")" = "$ssh_fallback" ] || fail "fm should use ssh when herdr is not installed, ran: $(cat "$calls")"
pass "fm on macOS uses plain ssh when herdr is missing"

# macOS `fm local`: the spare copy, and nothing opened.
[ "$(run_fm "$mac" "$host" "$tmp/bin-new" local)" = "$host/firstmate" ] || fail "fm local should cd into the local ~/firstmate"
[ ! -s "$calls" ] || fail "fm local should open nothing, ran: $(cat "$calls")"
assert_contains "$(cat "$fm_err")" "never run Firstmate on both machines at once" "fm local should remind that Firstmate runs on one machine only"
[ "$(wc -l < "$fm_err")" -eq 1 ] || fail "fm local's reminder should be one line, said: $(cat "$fm_err")"
pass "fm local on macOS changes into the spare copy and opens nothing"

[ "$(run_fm "$mac" "$away" "$tmp/bin-new" local)" = "$away" ] || fail "fm local should stay put without a local ~/firstmate"
[ ! -s "$calls" ] || fail "fm local should open nothing without a local ~/firstmate, ran: $(cat "$calls")"
assert_contains "$(cat "$fm_err")" "there is no ~/firstmate on this machine" "fm local should say when there is no local ~/firstmate"
pass "fm local on macOS says so when there is no local ~/firstmate"

[ "$(run_fm "$mac" "$host" "$tmp/bin-new" nonsense)" = "$host" ] || fail "fm should stay put for an unknown argument"
[ ! -s "$calls" ] || fail "fm should open nothing for an unknown argument, ran: $(cat "$calls")"
assert_contains "$(cat "$fm_err")" "usage: fm [local]" "fm should print its usage for an unknown argument"
pass "fm rejects an unknown argument"

# Linux: the machine that hosts Firstmate.
[ "$(run_fm "$linux" "$host" "$tmp/bin-new")" = "$host/firstmate" ] || fail "fm on Linux should cd into ~/firstmate"
[ "$(cat "$calls")" = "herdr  [config=] [cwd=$host/firstmate]" ] \
  || fail "fm on Linux should open plain herdr from ~/firstmate, ran: $(cat "$calls")"
pass "fm on Linux changes directory and then opens herdr"

[ "$(run_fm "$linux" "$host" "$tmp/bin-new" HERDR_ENV=1)" = "$host/firstmate" ] || fail "fm in a herdr pane should cd into ~/firstmate"
[ ! -s "$calls" ] || fail "fm in a herdr pane must not open a second herdr, ran: $(cat "$calls")"
[ "$(run_fm "$linux" "$host" "$tmp/bin-new" TMUX=/tmp/tmux-0/default,1,0)" = "$host/firstmate" ] || fail "fm in a tmux window should cd into ~/firstmate"
[ ! -s "$calls" ] || fail "fm in a tmux window must not open herdr, ran: $(cat "$calls")"
pass "fm on Linux only changes directory inside herdr or tmux"

[ "$(run_fm "$linux" "$host" "$tmp/bin-none")" = "$host/firstmate" ] || fail "fm on Linux without herdr should cd into ~/firstmate"
[ ! -s "$calls" ] || fail "fm on Linux without herdr should run nothing, ran: $(cat "$calls")"
pass "fm on Linux only changes directory when herdr is missing"

[ "$(run_fm "$linux" "$host" "$tmp/bin-new" local)" = "$host/firstmate" ] || fail "fm local on Linux should cd into ~/firstmate"
[ ! -s "$calls" ] || fail "fm local on Linux should open nothing, ran: $(cat "$calls")"
[ ! -s "$fm_err" ] || fail "fm local on Linux has nothing to remind about, said: $(cat "$fm_err")"
pass "fm local on Linux changes directory and opens nothing"

# --- Linux login directory -----------------------------------------------------

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
