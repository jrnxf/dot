#!/usr/bin/env bash
# Behavior checks for home/.local/bin/beep.
#
# curl and date are replaced by stubs: curl records how it was called and
# answers with a chosen HTTP status, date reports a chosen time. Nothing here
# reaches the network, so no test can make the NAS beep.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BEEP="$ROOT/home/.local/bin/beep"
[ -x "$BEEP" ] || fail "home/.local/bin/beep must be executable"
bash -n "$BEEP" || fail "home/.local/bin/beep has a syntax error"
grep -q '".local/bin/beep"' "$ROOT/home.nix" || fail "home.nix must link ~/.local/bin/beep"
bash_bin=$(command -v bash)

dotfiles_test_tmproot tmp dotfiles-beep
tmp=$(cd "$tmp" && pwd -P)
calls="$tmp/calls"
out="$tmp/out"

# make_bin <dir> <http status|none|dead> [time]: none leaves curl out, dead is
# a curl that fails the way an unreachable host does. time is what date reports.
make_bin() {
  local dir=$1 status=$2 time=${3:-12:00}
  mkdir -p "$dir"
  printf '#!/bin/sh\necho %s\n' "$time" > "$dir/date"
  chmod +x "$dir/date"
  [ "$status" = none ] && return
  if [ "$status" = dead ]; then
    printf '#!/bin/sh\nprintf "curl %%s\\n" "$*" >> "%s"\nprintf 000\nexit 28\n' "$calls" > "$dir/curl"
  else
    printf '#!/bin/sh\nprintf "curl %%s\\n" "$*" >> "%s"\nprintf %s\n' "$calls" "$status" > "$dir/curl"
  fi
  chmod +x "$dir/curl"
}

# run_beep <bin dir> [NAME=value...] [beep arguments...]
# Leaves beep's exit status in $rc and everything it printed in $out.
# PATH holds the stubs and nothing else, so a missing curl stub can never fall
# through to the real curl and reach the NAS. BEEP_QUIET is cleared and the
# locale pinned so the result does not depend on the caller.
run_beep() {
  local bin=$1
  local -a vars=()
  shift
  while [ $# -gt 0 ]; do
    case $1 in
      *=*) vars+=("$1"); shift ;;
      *) break ;;
    esac
  done
  : > "$calls"
  env -u BEEP_QUIET LC_ALL=C PATH="$bin" ${vars[@]+"${vars[@]}"} "$bash_bin" "$BEEP" "$@" > "$out" 2>&1
  rc=$?
}

# silent_ok <what>: the last run exited 0 and printed nothing.
silent_ok() {
  [ "$rc" -eq 0 ] || fail "$1 should exit 0, exited $rc"
  [ ! -s "$out" ] || fail "$1 should print nothing, said: $(cat "$out")"
}

make_bin "$tmp/day" 202
make_bin "$tmp/full" 429
make_bin "$tmp/bad" 400
make_bin "$tmp/dead" dead
make_bin "$tmp/nocurl" none

# --- sounds --------------------------------------------------------------------

bodies=
for sound in "done" need-you failed; do
  run_beep "$tmp/day" "$sound"
  silent_ok "beep $sound"
  [ "$(wc -l < "$calls")" -eq 1 ] || fail "beep $sound should make exactly one request, ran: $(cat "$calls")"
  call=$(cat "$calls")
  assert_contains "$call" "http://10.94.1.20:7337/beep" "beep $sound should post to the NAS, ran: $call"
  assert_contains "$call" "--max-time 2 " "beep $sound should give up after 2 seconds, ran: $call"
  body=$(printf '%s' "$call" | sed 's/.*--data \(\[.*\]\) http.*/\1/')
  printf '%s' "$body" | jq -e 'length > 0 and all(.[]; (.hz | type) == "number" and (.ms | type) == "number" and .ms > 0)' >/dev/null \
    || fail "beep $sound should send a list of hz/ms notes, sent: $body"
  bodies+="$body"$'\n'
done
[ "$(printf '%s' "$bodies" | sort -u | wc -l)" -eq 3 ] || fail "each sound should have its own tune"
pass "each sound posts its own tune with a 2 second limit"

run_beep "$tmp/day" "done"
tones=$(sed 's/.*--data \(\[.*\]\) http.*/\1/' "$calls" | jq -c '[.[] | select(.hz > 0) | .hz] | [length, (unique | length)]')
[ "$tones" = "[3,1]" ] || fail "done should stay three beeps of one pitch, got [count,pitches]=$tones"
pass "done is three beeps of one pitch"

for args in "" "nonsense" "done-ish" "--help"; do
  # shellcheck disable=SC2086 # empty must become no argument at all
  run_beep "$tmp/day" $args
  silent_ok "beep '$args'"
  [ ! -s "$calls" ] || fail "beep '$args' should request nothing, ran: $(cat "$calls")"
done
pass "an unknown or missing sound is silent and requests nothing"

# --- failures ------------------------------------------------------------------

for bin in full bad dead nocurl; do
  run_beep "$tmp/$bin" "done"
  silent_ok "beep with a $bin NAS"
done
pass "a full queue, a refusal, an unreachable NAS and a missing curl all exit 0 in silence"

# --- quiet hours ---------------------------------------------------------------

# quiet_at <time> [window]: succeeds when beep stays quiet at that time.
quiet_at() {
  make_bin "$tmp/clock" 202 "$1"
  if [ $# -gt 1 ]; then
    run_beep "$tmp/clock" BEEP_QUIET="$2" "done"
  else
    run_beep "$tmp/clock" "done"
  fi
  silent_ok "beep at $1 ${2:+with BEEP_QUIET=$2}"
  [ ! -s "$calls" ]
}

for t in 22:00 23:59 00:00 03:30 07:59; do
  quiet_at "$t" || fail "beep should stay quiet at $t by default"
done
for t in 08:00 12:00 21:59; do
  quiet_at "$t" && fail "beep should play at $t by default"
done
pass "the default quiet hours are 22:00 to 08:00"

quiet_at 13:30 13:00-14:00 || fail "a daytime window should be quiet inside"
quiet_at 14:00 13:00-14:00 && fail "a daytime window should end at its second time"
quiet_at 12:59 13:00-14:00 && fail "a daytime window should not start early"
quiet_at 23:30 23:00-01:00 || fail "an overnight window should be quiet before midnight"
quiet_at 00:59 23:00-01:00 || fail "an overnight window should be quiet after midnight"
quiet_at 22:30 23:00-01:00 && fail "an overnight window should not start early"
quiet_at 03:00 off && fail "BEEP_QUIET=off should play at night"
quiet_at 12:00 12:00-12:00 && fail "an empty window should never be quiet"
pass "BEEP_QUIET moves the window or turns it off"

for window in nonsense 22-8 25:00-08:00 22:00 "22:00-08:00 "; do
  quiet_at 12:00 "$window" || fail "an unreadable window ($window) should stay quiet"
done
quiet_at "not a time" || fail "an unreadable clock should stay quiet"
pass "an unreadable window or clock stays quiet"

# --- -v ------------------------------------------------------------------------

# says <text> <bin> [NAME=value...] [beep arguments...]: -v prints that text.
says() {
  local text=$1 bin=$2
  shift 2
  run_beep "$tmp/$bin" "$@"
  [ "$rc" -eq 0 ] || fail "beep $* should exit 0, exited $rc"
  assert_contains "$(cat "$out")" "$text" "beep $* should say '$text', said: $(cat "$out")"
}

says "sent done" day -v "done"
says "unknown sound: nonsense" day -v nonsense
says "usage: beep" day -v
says "queue is full" full -v "done"
says "NAS answered 400" bad -v "done"
says "NAS unreachable" dead -v "done"
says "NAS unreachable" nocurl -v "done"
says "quiet hours (11:00-13:00)" day BEEP_QUIET=11:00-13:00 -v "done"
pass "-v says what happened and still exits 0"
