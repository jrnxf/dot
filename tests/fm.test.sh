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

# make_bin <dir> <herdr --remote exit status|none>: none leaves herdr out.
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
printf 'herdr %s [config=%s]\n' "\$*" "\${HERDR_CONFIG_PATH:-}" >> "$calls"
exit $status
EOF
  chmod +x "$dir/herdr"
}

# run_fm <home> <bin dir>: prints the directory fm left the shell in.
run_fm() {
  : > "$calls"
  HOME=$1 PATH="$2:/usr/bin:/bin" FM_SOURCE=$fm_source \
    zsh -f -c 'cd "$HOME"; eval "$FM_SOURCE"; fm; print -r -- "$PWD"'
}

host="$tmp/host"
away="$tmp/away"
mkdir -p "$host/firstmate" "$away"
ssh_fallback="ssh -t firstmate cd ~/firstmate && exec herdr"

make_bin "$tmp/bin-new" 0
[ "$(run_fm "$host" "$tmp/bin-new")" = "$host/firstmate" ] || fail "fm should cd into ~/firstmate where it exists"
[ ! -s "$calls" ] || fail "fm should not connect anywhere where ~/firstmate exists, ran: $(cat "$calls")"
pass "fm changes directory on the machine that hosts Firstmate"

[ "$(run_fm "$away" "$tmp/bin-new")" = "$away" ] || fail "fm should leave the local directory alone when it connects"
[ "$(cat "$calls")" = "herdr --remote firstmate [config=$away/.config/herdr-firstmate/config.toml]" ] \
  || fail "fm should remote-attach with the Firstmate config and nothing else, ran: $(cat "$calls")"
pass "fm remote-attaches with the Firstmate config"

make_bin "$tmp/bin-refused" 1
run_fm "$away" "$tmp/bin-refused" >/dev/null
[ "$(sed -n 1p "$calls")" = "herdr --remote firstmate [config=$away/.config/herdr-firstmate/config.toml]" ] \
  || fail "fm should try remote attach first, ran: $(cat "$calls")"
[ "$(sed -n 2p "$calls")" = "$ssh_fallback" ] || fail "fm should fall back to ssh when remote attach fails, ran: $(cat "$calls")"
pass "fm falls back to plain ssh when remote attach fails"

make_bin "$tmp/bin-none" none
run_fm "$away" "$tmp/bin-none" >/dev/null
[ "$(cat "$calls")" = "$ssh_fallback" ] || fail "fm should use ssh when herdr is not installed, ran: $(cat "$calls")"
pass "fm uses plain ssh when herdr is missing"

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
