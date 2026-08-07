#!/usr/bin/env bash
# statusline-command.sh — Claude Code custom statusline
# Phase 1: Line 1 (CWD, git branch, thinking, model, flags, context window)
# Phase 2: Cost badges + log infrastructure

# ── ANSI constants (§6) ────────────────────────────────────────────────────────
RESET=$'\033[0m'
DIM=$'\033[90m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
ORANGE=$'\033[38;5;208m'
RED=$'\033[31m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
BOLD=$'\033[1m'
STRIKETHROUGH=$'\033[9m'
DOT_GREEN=$'\033[38;5;82m'
DOT_YELLOW=$'\033[38;5;220m'
DOT_ORANGE=$'\033[38;5;208m'
DOT_RED=$'\033[38;5;196m'
DOT_GREY=$'\033[38;5;245m'

# ── Named thresholds ───────────────────────────────────────────────────────────
COST_EQ_THRESHOLD=0.01    # ±$0.01 treated as equal (§8.6)
LOG_PRUNE_WINDOW=129600   # 36 hours in seconds
BASELINE_TTL=2592000      # 30 days in seconds
BUDGET_WARN_LO=0.925      # green/yellow threshold (within 7.5%)
BUDGET_WARN_HI=1.075      # yellow/red threshold (over 7.5%)

SPACE=$'\xe2\x80\x8b'   # U+200B zero-width space — leads line 2
BRANCH_ICON='⎇'         # U+2387

# Detect user's decimal separator once; used by _fmt_money for locale-consistent output.
DECIMAL_POINT=$(locale -k LC_NUMERIC 2>/dev/null \
                | awk -F'"' '/^decimal_point=/{print $2; exit}')
: "${DECIMAL_POINT:=.}"

# ── State file paths (§4) ──────────────────────────────────────────────────────
_CLAUDE_DIR="${CLAUDE_STATUSLINE_STATE_DIR:-$HOME/.claude}"
LOG_FILE="$_CLAUDE_DIR/statusline-global-usage-log.cache"
BASELINE_FILE="$_CLAUDE_DIR/statusline-session-baselines.tsv"
LOCK_DIR="$_CLAUDE_DIR/statusline-log.lock"
USAGE_CACHE_FILE="$_CLAUDE_DIR/statusline-usage-cache.json"
USAGE_FETCH_LOCK="$_CLAUDE_DIR/statusline-usage-fetch.lock"
RUNWAY_CACHE_FILE="$_CLAUDE_DIR/statusline-runway-allowances.cache"
AUTH_ERROR_FILE="$_CLAUDE_DIR/statusline-usage-fetch.error"
CACHE_TTL=300
LOCK_INFLIGHT_GRACE=60    # lock_age < this → fetch in flight → suppress ⚠️
FETCH_RETRY_COOLDOWN=120  # don't spawn a new fetch more often than this
LOCK_LEAK_TIMEOUT=600     # lock_age >= this → abandoned (sleep/reboot) → suppress ⚠️

# ── Read stdin ─────────────────────────────────────────────────────────────────
input=$(cat)

# ── Field extraction (§2) — single jq pass, one field per line (bash 3.2 safe) ─
{
  IFS= read -r cwd
  IFS= read -r model_name
  IFS= read -r used_pct
  IFS= read -r window_size
  IFS= read -r fast_mode
  IFS= read -r effort_level
  IFS= read -r thinking_enabled
  IFS= read -r cost
  IFS= read -r session_id
  IFS= read -r transcript_path
  IFS= read -r version
} < <(jq -r '
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    ((.context_window.used_percentage // "") | tostring),
    ((.context_window.context_window_size // "") | tostring),
    ((.fast_mode // "") | tostring),
    (.effort.level // ""),
    ((.thinking.enabled // "") | tostring),
    ((.cost.total_cost_usd // 0) | tostring),
    (.session_id // ""),
    (.transcript_path // ""),
    (.version // "2.1.76")
  ' <<< "$input" 2>/dev/null | tr -d '\r')
cost="${cost:-0}"
# awk-normalized cost: always "." decimal, 6dp — safe for bash printf %.6f in any locale
cost_6f=$(awk -v c="$cost" 'BEGIN{printf "%.6f", c+0}')

# ── Helpers ────────────────────────────────────────────────────────────────────

# workspace_hash(cwd) — SHA-256 of cwd, fallback cksum, fallback "empty" (§4.1)
workspace_hash() {
  local d="$1"
  if [ -z "$d" ]; then
    printf 'empty'; return
  fi
  local h
  if command -v shasum >/dev/null 2>&1; then
    read -r h _ < <(shasum -a 256 <<< "$d" 2>/dev/null)
  elif command -v sha256sum >/dev/null 2>&1; then
    read -r h _ < <(sha256sum <<< "$d" 2>/dev/null)
  fi
  if [ -z "$h" ] && command -v cksum >/dev/null 2>&1; then
    read -r h _ < <(cksum <<< "$d" 2>/dev/null)
  fi
  [ -n "$h" ] || h="empty"
  printf '%s' "$h"
}

# _mtime(path) — file mtime epoch (GNU stat first: -f on Linux means filesystem stat and exits 0
# with garbage output, so GNU -c %Y must come before BSD -f %m)
_mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }

# _env_opt VAR_NAME default val1 val2 … — case-fold + validate env var (bash 3.2 safe)
_env_opt() {
  local _var="$1" _def="$2"; shift 2
  local val; val=$(tr '[:upper:]' '[:lower:]' <<< "${!_var:-$_def}")
  local v; for v in "$@"; do [ "$val" = "$v" ] && { printf '%s' "$val"; return; }; done
  printf '%s' "$_def"
}

# _fmt_money value [decimals=2] — locale-aware monetary format via integer math.
# Always emits $DECIMAL_POINT as separator; never calls locale-sensitive printf.
_fmt_money() {
  local v=$1 d=${2:-2}
  awk -v x="$v" -v d="$d" -v dp="$DECIMAL_POINT" 'BEGIN{
    mult = 1; for (i=0;i<d;i++) mult *= 10
    c = int(x*mult + (x>=0 ? 0.5 : -0.5))
    sign=""; if (c<0) { sign="-"; c=-c }
    if (d==0) { printf "%s%d", sign, c }
    else      { fmt = "%s%d%s%0" d "d"; printf fmt, sign, int(c/mult), dp, c%mult }
  }'
}

# _fmt_cents cents [decimals=2] — convert integer cents to USD string, locale-aware decimal point
_fmt_cents() {
  local c=$1 d=${2:-2}
  awk -v c="$c" -v d="$d" -v dp="$DECIMAL_POINT" 'BEGIN{
    sign=""; if (c<0){sign="-";c=-c}
    if (d==0) { printf "%s%d", sign, int(c/100 + 0.5) }
    else      { printf "%s%d%s%02d", sign, int(c/100), dp, c%100 }
  }'
}

# _cost_same(a, b) — exit 0 when |a-b| <= COST_EQ_THRESHOLD (§8.6 equality test)
_cost_same() {
  awk -v a="$1" -v b="$2" -v thr="$COST_EQ_THRESHOLD" \
    'BEGIN { d = a - b; if (d < 0) d = -d; exit (d <= thr ? 0 : 1) }'
}

# _mid_ellipsis(str, target_len) — middle-ellipsis, tail-weighted 40/60 split
_mid_ellipsis() {
  local str="$1" target="$2"
  local slen="${#str}"
  if (( slen <= target )); then printf '%s' "$str"; return; fi
  if (( target < 3 )); then printf '%s' "${str:0:$target}"; return; fi
  local budget=$(( target - 1 ))   # 1 char for "…"
  local head=$(( budget * 4 / 10 ))
  (( head < 1 )) && head=1
  local tail=$(( budget - head ))
  local tail_start=$(( slen - tail ))
  printf '%s' "${str:0:$head}…${str:$tail_start}"
}

# _shorten_path(str, max) — slash-aware shortener for CWD and branch names
_shorten_path() {
  local str="$1" max="$2"
  if (( ${#str} <= max )); then printf '%s' "$str"; return; fi

  # Min-savings guard: a "…" insertion costs 1 char; if the string is
  # only a few chars over budget the ellipsized form is not worthwhile.
  if (( ${#str} - max < 5 )); then printf '%s' "$str"; return; fi

  # Tokenize on '/'. Bash 3.2: read each segment individually.
  local IFS='/'
  local parts
  # shellcheck disable=SC2206
  parts=( $str )
  local n="${#parts[@]}"

  # Single segment (no slash): pure middle-ellipsis
  if (( n <= 1 )); then
    _mid_ellipsis "$str" "$max"
    return
  fi

  # Step 1: reduce all leading segments to 2 chars. Absolute paths (parts[0]="")
  # and home-relative paths (parts[0]="~") keep their root token verbatim;
  # branch-style prefixes ("feature", "mklaman", etc.) are always abbreviated.
  local i prefix
  if [[ -n "${parts[0]}" && "${parts[0]}" != "~" ]]; then
    prefix="${parts[0]:0:2}"
  else
    prefix="${parts[0]}"
  fi
  for (( i=1; i<n-1; i++ )); do
    prefix+="/${parts[$i]:0:2}"
  done
  local last="${parts[$((n-1))]}"
  local candidate="${prefix}/${last}"

  if (( ${#candidate} <= max )); then
    printf '%s' "$candidate"
    return
  fi

  # Step 2: budget remaining space for last segment
  local prefix_len="${#prefix}"
  local last_budget=$(( max - prefix_len - 1 ))  # 1 for '/'

  # Step 2a: prefix-collapse fallback. If the last segment is short enough
  # to render almost in full with a collapsed "…/" prefix, and the
  # alternative mid-ellipsis would retain less than half of it, prefer the
  # cleaner form. May exceed max by up to 1 char.
  if (( last_budget >= 3 && ${#last} <= max - 1 && n <= 4 && (last_budget - 1) * 2 < ${#last} )); then
    printf '%s' "…/${last}"
    return
  fi

  if (( last_budget >= 3 )); then
    printf '%s' "${prefix}/$(_mid_ellipsis "$last" "$last_budget")"
    return
  fi

  # Step 3: collapse middle intermediates to a single '…' token,
  # keeping the first and second-to-last intermediates visible (if there are enough)
  if (( n >= 4 )); then
    local first_inter="${parts[1]:0:2}"
    local second_to_last_inter="${parts[$((n-2))]:0:2}"
    local collapsed_prefix="${parts[0]}/${first_inter}/…/${second_to_last_inter}"
    local collapsed_budget=$(( max - ${#collapsed_prefix} - 1 ))
    if (( collapsed_budget >= 3 )); then
      printf '%s' "${collapsed_prefix}/$(_mid_ellipsis "$last" "$collapsed_budget")"
      return
    fi
    if (( collapsed_budget > 0 && ${#last} <= collapsed_budget )); then
      printf '%s' "${collapsed_prefix}/${last}"
      return
    fi
  fi

  # Step 4: fallback — middle-ellipsis the whole string
  _mid_ellipsis "$str" "$max"
}

# _acquire_lock / _release_lock — mkdir-based POSIX lock (§9)
LOCK_HELD=0
_acquire_lock() {
  local i=0 pid age mtime now
  while [ $i -lt 5 ]; do
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      printf '%d' $$ > "$LOCK_DIR/pid"
      LOCK_HELD=1
      return 0
    fi
    if [ -f "$LOCK_DIR/pid" ]; then
      IFS= read -r pid < "$LOCK_DIR/pid" 2>/dev/null || pid=""
      if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        sleep 0.05
      else
        rm -rf "$LOCK_DIR" 2>/dev/null
      fi
    else
      now=$(date +%s)
      mtime=$(_mtime "$LOCK_DIR")
      age=$(( now - mtime ))
      if [ "$age" -gt 20 ]; then
        rm -rf "$LOCK_DIR" 2>/dev/null
      else
        sleep 0.05
      fi
    fi
    i=$(( i + 1 ))
  done
  return 1
}

_release_lock() {
  if [ "$LOCK_HELD" -eq 1 ]; then
    rm -f "$LOCK_DIR/pid" 2>/dev/null
    rmdir "$LOCK_DIR" 2>/dev/null
    LOCK_HELD=0
  fi
}

# §11: fmt_ctx_k(n) — format token count with optional k suffix
fmt_ctx_k() {
  local n=$1
  awk -v n="$n" 'BEGIN { if (n >= 1000) printf "%dk", int((n+500)/1000); else printf "%d", n }'
}

# ── Persistent state (§4.1, §4.2) ─────────────────────────────────────────────
NOW=$(date +%s)
ws_hash=$(workspace_hash "$cwd")

# Session ID fallback (§13)
[ -z "$session_id" ] && session_id="anon"

# Initialize baseline_cost to current cost (no-baseline fallback)
mkdir -p "$_CLAUDE_DIR"
baseline_cost="$cost"

if _acquire_lock; then
  trap _release_lock EXIT

  # ── Session baseline upsert (§4.2) ─────────────────────────────────────────
  existing_baseline=""
  [ -f "$BASELINE_FILE" ] && \
    existing_baseline=$(awk -F'\t' -v sid="$session_id" '$1==sid{print $2;exit}' "$BASELINE_FILE")

  if [ -n "$existing_baseline" ]; then
    baseline_cost="$existing_baseline"
    cutoff_30d=$(( NOW - BASELINE_TTL ))
    if [ $(( RANDOM % 100 )) -eq 0 ]; then
      awk -F'\t' -v OFS='\t' -v sid="$session_id" -v now="$NOW" -v cutoff="$cutoff_30d" '
        $1==sid { $4=now }
        $4+0 >= cutoff { print }
      ' "$BASELINE_FILE" > "$BASELINE_FILE.tmp" && mv "$BASELINE_FILE.tmp" "$BASELINE_FILE"
    else
      awk -F'\t' -v OFS='\t' -v sid="$session_id" -v now="$NOW" '
        $1==sid { $4=now }
        { print }
      ' "$BASELINE_FILE" > "$BASELINE_FILE.tmp" && mv "$BASELINE_FILE.tmp" "$BASELINE_FILE"
    fi
  else
    baseline_cost="$cost"
    printf '%s\t%.6f\t%d\t%d\n' "$session_id" "$cost_6f" "$NOW" "$NOW" >> "$BASELINE_FILE"
  fi

  # ── Global usage log append + prune (§4.1) ─────────────────────────────────
  printf '%d %s %s %s\n' "$NOW" "$session_id" "$cost_6f" "$ws_hash" >> "$LOG_FILE"

  cutoff_36h=$(( NOW - LOG_PRUNE_WINDOW ))
  awk -v cutoff="$cutoff_36h" '
    NF >= 4 {
      t = $1 + 0; sid = $2
      if (t >= cutoff) {
        recent[++nr] = $0
      } else if (!(sid in anc_t) || t > anc_t[sid]) {
        anc_t[sid] = t; anc_row[sid] = $0
      }
    }
    END {
      for (sid in anc_row) print anc_row[sid]
      for (i = 1; i <= nr; i++) print recent[i]
    }
  ' "$LOG_FILE" | sort -n > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"

  _release_lock
fi

# ── Cost pair computation (§8.6) ──────────────────────────────────────────────
session_cost=$(awk -v inst="$cost" -v base="$baseline_cost" \
  'BEGIN { s = inst - base; printf "%.6f", (s > 0 ? s : 0) }')

cost_mode=$(_env_opt CLAUDE_STATUSLINE_COST_CURRENT on on session instance off)
loadavg_mode=$(_env_opt CLAUDE_STATUSLINE_COST_LOADAVG on on spent_only off)
sign_mode=$(_env_opt CLAUDE_STATUSLINE_BUDGET_SIGN_MODE neutral neutral used_minus remaining_plus both)
show_pace_ratio=$(_env_opt CLAUDE_STATUSLINE_SHOW_PACE_RATIO on on off)

hours_per_day="${CLAUDE_STATUSLINE_BUDGET_HOURS_PER_DAY:-6}"
awk -v h="$hours_per_day" 'BEGIN { exit (h+0 > 0 ? 0 : 1) }' </dev/null 2>/dev/null || hours_per_day=6

work_days_str=$(printf '%s' "${CLAUDE_STATUSLINE_BUDGET_WORK_DAYS:-12345}" | tr -cd '1-7')
[ -z "$work_days_str" ] && work_days_str="12345"

holidays_raw="${CLAUDE_STATUSLINE_BUDGET_HOLIDAYS:-}"
extra_preview_pct="${CLAUDE_STATUSLINE_EXTRA_PREVIEW_PCT:-75}"

cost_seg=""
if [ "$cost_mode" != "off" ]; then
  inst_fmt=$(_fmt_money "$cost")
  sess_fmt=$(_fmt_money "$session_cost")
  if [ "$cost_mode" = "instance" ]; then
    cost_seg="${RESET}${BLUE}${BOLD}∑ⁱ\$${inst_fmt}${RESET}"
  else
    cost_seg="${RESET}${BLUE}${BOLD}∑ˢ\$${sess_fmt}${RESET}"
    if [ "$cost_mode" = "on" ] && ! _cost_same "$session_cost" "$cost"; then
      cost_seg+=" ${DIM}∑ⁱ\$${inst_fmt}${RESET}"
    fi
  fi
fi

# ── Rolling window helpers (§8.7) ─────────────────────────────────────────────

# _local_day_start — epoch of local 00:00 today (SPEC §8.7 fallback chain)
# _DAY_START is computed once below after function definition and reused throughout.
_local_day_start() {
  local ymd ds
  ymd=$(date +%F)
  ds=$(date -jf "%Y-%m-%d %H:%M:%S" "$ymd 00:00:00" +%s 2>/dev/null)
  [ -n "$ds" ] && { printf '%s' "$ds"; return; }
  ds=$(date -d "$ymd 00:00:00" +%s 2>/dev/null)
  [ -n "$ds" ] && { printf '%s' "$ds"; return; }
  ds=$(date -r "$NOW" -v0H -v0M -v0S +%s 2>/dev/null)
  [ -n "$ds" ] && { printf '%s' "$ds"; return; }
  printf '%d' $(( NOW - 86400 ))
}

# _DAY_START — epoch of local midnight, computed once and reused
_DAY_START=$(_local_day_start)

# calc_spent_all — emit: s15 s1h s1d nd15 nd1h nd1d  (SPEC §8.7 + §4.1 filtering)
calc_spent_all() {
  local day_start="${_DAY_START:-$(_local_day_start)}"
  local day_gated=0
  [ $(( NOW - 3600 )) -ge "$day_start" ] && day_gated=1
  awk -v now="$NOW" -v cur_sid="$session_id" -v cost_now="$cost" -v day_start="$day_start" -v day_gated="$day_gated" '
    BEGIN {
      cut15 = now - 900
      cut1h = now - 3600
      cut1d = day_start
      split("15m 1h 1d", wins, " ")
      nsess = 0
    }
    NF < 4 { next }
    {
      t = $1 + 0; sid = $2; c = $3 + 0
      age = now - t; elig = (age >= 5)
      if (!(sid in sess_seen)) { sessions[++nsess] = sid; sess_seen[sid] = 1 }
      if (t > sess_latest_t[sid]) { sess_latest_t[sid] = t; sess_cur[sid] = c }
      if (elig) total_rows++
      for (i = 1; i <= 3; i++) {
        k = wins[i]
        cutoff = (k == "15m") ? cut15 : (k == "1h") ? cut1h : cut1d
        key = sid SUBSEP k
        if (t >= cutoff) {
          if (elig) {
            rows[k]++
            if (!(key in win_t) || t < win_t[key]) { win_t[key] = t; win_c[key] = c }
          }
        } else {
          if (elig && (!(key in anc_t) || t > anc_t[key])) { anc_t[key] = t; anc_c[key] = c; has_anc[k] = 1 }
        }
      }
    }
    END {
      if (!(cur_sid in sess_seen)) { sessions[++nsess] = cur_sid; sess_seen[cur_sid] = 1 }
      sess_cur[cur_sid] = cost_now
      for (i = 1; i <= 3; i++) {
        k = wins[i]; total = 0
        for (s = 1; s <= nsess; s++) {
          sid = sessions[s]; scur = sess_cur[sid]; key = sid SUBSEP k
          if (key in win_t) ref = win_c[key]
          else if (key in anc_t) ref = anc_c[key]
          else ref = scur
          delta = scur - ref; if (delta < 0) delta = 0
          total += delta
        }
        spent[k] = total
        nodata[k] = (rows[k] == 0 && !has_anc[k] && cost_now == 0) ? 1 : 0
      }
      s15 = spent["15m"]; s1h = spent["1h"]; s1d = spent["1d"]
      if (s1h < s15) s1h = s15
      if (day_gated && s1d < s1h) s1d = s1h
      printf "%.6f %.6f %.6f %d %d %d\n", s15, s1h, s1d, nodata["15m"], nodata["1h"], nodata["1d"]
    }
  ' "$LOG_FILE" 2>/dev/null || printf '0.000000 0.000000 0.000000 0 0 0\n'
}

# _roll_slot label spent nodata [sign_mode] [allowance] [budget_color]
# Renders one rolling-window slot with optional sign mode and allowance suffix.
# allowance="" means no suffix; budget_color defaults to no color when empty.
_roll_slot() {
  local label="$1" spent="$2" nodata="$3"
  local smode="${4:-neutral}" allowance="${5:-}" bcolor="${6:-}"
  local allow_sfx=""
  if [ -n "$allowance" ]; then
    allow_sfx="/${DIM}\$$(_fmt_money "$allowance" 0)${RESET}"
  fi
  if [ "$nodata" = "1" ]; then
    printf '%s' "${label}:${DIM}—${RESET}${allow_sfx}"
    return
  fi
  local remaining=""
  [ -n "$allowance" ] && remaining=$(_fmt_money \
    "$(awk -v a="$allowance" -v s="$spent" 'BEGIN{ r=a-s; print (r>0?r:0) }')")
  local out="${label}:"
  local spent_fmt; spent_fmt=$(_fmt_money "$spent")
  case "$smode" in
    used_minus)
      if awk -v s="$spent" 'BEGIN{exit (s+0>0?0:1)}'; then
        out+="${bcolor}-\$${spent_fmt}${RESET}"
      else
        out+="\$${spent_fmt}"
      fi
      out+="${allow_sfx}" ;;
    remaining_plus)
      if [ -n "$remaining" ]; then
        out+="${bcolor}+\$${remaining}${RESET}${allow_sfx}"
      else
        out+="\$${spent_fmt}"
      fi ;;
    both)
      out+="${bcolor}-\$${spent_fmt}${RESET}"
      if [ -n "$remaining" ]; then
        out+="/${bcolor}+\$${remaining}${RESET}"
      fi
      out+="${allow_sfx}" ;;
    *)
      if [ -n "$bcolor" ]; then
        out+="${bcolor}\$${spent_fmt}${RESET}${allow_sfx}"
      else
        out+="${DIM}\$${spent_fmt}${RESET}${allow_sfx}"
      fi ;;
  esac
  printf '%s' "$out"
}

# ── Line 1 display budget (§7.2, §7.3) ───────────────────────────────────────
_DEFAULT_CWD_MAXLEN=64
_DEFAULT_BRANCH_MAXLEN=64
_MAXLEN_MIN=8        # minimum accepted env var value; below this falls back to default
_TERM_W_MIN=88       # floor: narrower terminals are treated as this wide
_TERM_W_FALLBACK=220 # used when no tty is detectable; wide assumption avoids false compression

# Env var ceilings for CWD and branch display lengths (validated: integer >= _MAXLEN_MIN)
_CWD_MAXLEN_raw="${CLAUDE_STATUSLINE_CWD_MAXLEN:-$_DEFAULT_CWD_MAXLEN}"
_BRANCH_MAXLEN_raw="${CLAUDE_STATUSLINE_BRANCH_MAXLEN:-$_DEFAULT_BRANCH_MAXLEN}"
case "$_CWD_MAXLEN_raw" in (*[!0-9]*|'') _CWD_MAXLEN=$_DEFAULT_CWD_MAXLEN ;; (*) _CWD_MAXLEN=$_CWD_MAXLEN_raw ;; esac
[ "$_CWD_MAXLEN" -ge "$_MAXLEN_MIN" ] || _CWD_MAXLEN=$_DEFAULT_CWD_MAXLEN
case "$_BRANCH_MAXLEN_raw" in (*[!0-9]*|'') _BRANCH_MAXLEN=$_DEFAULT_BRANCH_MAXLEN ;; (*) _BRANCH_MAXLEN=$_BRANCH_MAXLEN_raw ;; esac
[ "$_BRANCH_MAXLEN" -ge "$_MAXLEN_MIN" ] || _BRANCH_MAXLEN=$_DEFAULT_BRANCH_MAXLEN

# Terminal width with floor. stdin is the JSON payload (not a tty).
# Detection chain:
#   1. $COLUMNS — not set by Claude Code itself, but may be present if the user's shell
#      exports it or if a wrapper sets it; treated as an override when present.
#   2. /dev/tty  — the controlling terminal; fails in Claude Code (no controlling tty).
#   3. stderr fd — only if [ -t 2 ] confirms it's a real tty; tput returns 80 as its
#      own fallback when given a non-tty fd, indistinguishable from a real 80-col terminal.
#   4. Ancestor PTY walk — the primary reliable method under Claude Code: walks up the
#      ppid chain (max 8 hops) to find an ancestor with a real PTY, then queries it via
#      `stty -f /dev/$tty size` (macOS) or `stty -F /dev/$tty size` (Linux). The -f/-F
#      flag is required — `stty size < /dev/$tty` returns ENOTTY under Claude Code ≥ 2.1.139.
#   5. _TERM_W_FALLBACK — wide value so undetected width does not cause false compression.
_term_width_from_ancestor_pty() {
  local pid=$$
  local tty w _depth
  for _depth in 1 2 3 4 5 6 7 8; do
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [ -z "$pid" ] || [ "$pid" = "0" ] || [ "$pid" = "1" ] && return 1
    tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    [ -z "$tty" ] || [ "$tty" = "??" ] || [ "$tty" = "?" ] && continue
    # Try macOS BSD stty (-f), then Linux GNU stty (-F), then redirect fallback
    w=$(stty -f "/dev/$tty" size 2>/dev/null | awk '{print $2}') \
      || w=$(stty -F "/dev/$tty" size 2>/dev/null | awk '{print $2}') \
      || w=$(stty size < "/dev/$tty" 2>/dev/null | awk '{print $2}')
    if [ -n "$w" ] && [ "$w" -gt 0 ] 2>/dev/null; then
      printf '%s' "$w"; return 0
    fi
  done
  return 1
}

_TERM_W=${COLUMNS:-}
if [ -z "$_TERM_W" ]; then
  if _w=$( (tput cols </dev/tty) 2>/dev/null ) && [ -n "$_w" ]; then
    _TERM_W=$_w
  elif [ -t 2 ] && _w=$(tput cols <&2 2>/dev/null) && [ -n "$_w" ]; then
    _TERM_W=$_w
  elif _w=$(_term_width_from_ancestor_pty) && [ -n "$_w" ]; then
    _TERM_W=$_w
  else
    _TERM_W=$_TERM_W_FALLBACK
  fi
fi


_TERM_W_RAW=$_TERM_W   # save pre-floor value for line 2 adaptive truncation
(( _TERM_W < _TERM_W_MIN )) && _TERM_W=$_TERM_W_MIN

# Estimate chars consumed by fixed elements (model, effort, fast, thinking, ctx, leading space).
# Branch separator " ⎇ " (3 chars) is excluded here — it's subtracted separately in the cwd budget.
_thinking_chars=0; [ "$thinking_enabled" = "true" ] && _thinking_chars=3
_effort_chars=0;   [ -n "$effort_level" ] && _effort_chars=2
_fast_chars=0;     [ "$fast_mode" = "true" ] && _fast_chars=2
_model_chars=0;    [ -n "$model_name" ] && _model_chars=$(( 1 + ${#model_name} ))
# 1=leading space, 20=ctx segment worst-case " ctx:200k/200k≈100%"
_fixed_overhead=$(( 1 + _thinking_chars + _model_chars + _effort_chars + _fast_chars + 20 ))

_combined_budget=$(( _TERM_W - _fixed_overhead ))
(( _combined_budget < 20 )) && _combined_budget=20

# Branch gets priority: ~55% of combined, capped by ceiling
_branch_budget=$(( _combined_budget * 55 / 100 ))
(( _branch_budget > _BRANCH_MAXLEN )) && _branch_budget=$_BRANCH_MAXLEN
(( _branch_budget < 8 )) && _branch_budget=8

# Resolve branch early so CWD gets the actual remaining space, not a worst-case proxy.
_branch_disp=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  _branch_raw=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$_branch_raw" ] && _branch_raw=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$_branch_raw" ] && _branch_disp=$(_shorten_path "$_branch_raw" "$_branch_budget")
fi

# CWD budget: subtract actual branch display length (not its ceiling) + 3 for " ⎇ " separator
if [ -n "$_branch_disp" ]; then
  _cwd_budget=$(( _combined_budget - ${#_branch_disp} - 3 ))
else
  _cwd_budget=$_combined_budget
fi
(( _cwd_budget < 8 )) && _cwd_budget=8
(( _cwd_budget > _CWD_MAXLEN )) && _cwd_budget=$_CWD_MAXLEN

# ── Line 1 assembly ────────────────────────────────────────────────────────────
line1=" ${RESET}"

# §7.2 CWD segment (yellow)
if [ -n "$cwd" ]; then
  cwd_disp="${cwd/#$HOME/\~}"
  cwd_disp=$(_shorten_path "$cwd_disp" "$_cwd_budget")
  line1+="${YELLOW}${cwd_disp}${RESET}"
fi

# §7.3 Git branch segment (green, optional)
if [ -n "$_branch_disp" ]; then
  line1+=" ${GREEN}${BRANCH_ICON} ${_branch_disp}${RESET}"
fi

# §7.4 Thinking indicator
if [ "$thinking_enabled" = "true" ]; then
  line1+=" 🧠"
fi

# §7.5 Model segment (magenta)
if [ -n "$model_name" ]; then
  line1+=" ${MAGENTA}${model_name}${RESET}"
fi

# §7.6 Model flags
if [ "$fast_mode" = "true" ]; then
  line1+=" ${ORANGE}↯${RESET}"
fi

if [ -n "$effort_level" ]; then
  case "$effort_level" in
    none)  line1+=" ${DIM}∅${RESET}" ;;
    low)   line1+=" ${GREEN}○${RESET}" ;;
    medium)line1+=" ${MAGENTA}◑${RESET}" ;;
    auto)  line1+=" ${MAGENTA}🅐${RESET}" ;;
    high)  line1+=" ${ORANGE}●${RESET}" ;;
    xhigh) line1+=" ${ORANGE}◉${RESET}" ;;
    max)   line1+=" ${RED}◈${RESET}" ;;
  esac
fi

# §7.7 Context window segment
if [ -z "$used_pct" ]; then
  line1+=" ${DIM}ctx:—${RESET}"
else
  used_int="${used_pct%%.*}"

  # Window size fallback
  W="$window_size"
  if [ -z "$W" ] || [ "$W" -eq 0 ] 2>/dev/null; then
    W=200000
  fi

  # Token counts
  used_tokens=$(awk -v w="$W" -v u="$used_int" 'BEGIN { printf "%d", int((w*u/100)+0.5) }')
  used_k=$(fmt_ctx_k "$used_tokens")
  win_k=$(fmt_ctx_k "$W")

  # Effective ceiling E
  E=95
  if [ -n "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" ] && \
     [ "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" -ge 1 ] 2>/dev/null && \
     [ "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" -le 100 ] 2>/dev/null; then
    E=$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE
    [ "$E" -gt 95 ] && E=95
  fi

  # Warn percentage (default 75)
  warn_pct=75
  if [ -n "$CLAUDE_STATUSLINE_CTX_WARN_PCT" ] && \
     [ "$CLAUDE_STATUSLINE_CTX_WARN_PCT" -ge 1 ] 2>/dev/null && \
     [ "$CLAUDE_STATUSLINE_CTX_WARN_PCT" -le 99 ] 2>/dev/null; then
    warn_pct=$CLAUDE_STATUSLINE_CTX_WARN_PCT
  fi

  # Caution tokens (default 150000; 0 = disabled)
  caution_tokens=150000
  if [ -n "$CLAUDE_STATUSLINE_CTX_CAUTION_TOKENS" ]; then
    caution_tokens=$CLAUDE_STATUSLINE_CTX_CAUTION_TOKENS
  fi

  # warn_at: orange starts above this threshold
  if [ -n "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" ] && \
     [ "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" -ge 1 ] 2>/dev/null && \
     [ "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" -le 100 ] 2>/dev/null; then
    warn_at=$(awk -v e="$E" -v w="$warn_pct" 'BEGIN { printf "%d", int(e*w/100) }')
  else
    warn_at=$warn_pct
  fi

  # Color selection
  ctx_color="$DIM"
  if [ "$used_int" -ge "$E" ] 2>/dev/null; then
    ctx_color="$RED"
  elif [ "$used_int" -gt "$warn_at" ] 2>/dev/null; then
    ctx_color="$ORANGE"
  elif [ "$caution_tokens" -gt 0 ] 2>/dev/null && [ "$used_tokens" -gt "$caution_tokens" ] 2>/dev/null; then
    ctx_color="$BLUE"
  fi

  line1+=" ${ctx_color}ctx:${used_k}/${win_k}${RESET}≈${used_int}%"
fi

# ── Performance badge computation (§8.1, §3.1) ────────────────────────────────
perf_mode=$(_env_opt CLAUDE_STATUSLINE_PERF_BADGE on on off cache_only latency_only)

_perf_level_for_cache() {
  awk -v r="$1" 'BEGIN {
    if (r == "") { print -1; exit }
    r += 0
    if      (r >= 95) print 0
    else if (r >= 90) print 1
    else if (r >= 75) print 2
    else              print 3
  }'
}

_perf_level_for_latency() {
  awk -v d="$1" 'BEGIN {
    if (d == "") { print -1; exit }
    d += 0
    if      (d <= 10) print 0
    else if (d <= 30) print 1
    else if (d <= 60) print 2
    else              print 3
  }'
}

_build_perf_badge() {
  local level="$1"
  local cols=("$DOT_GREEN" "$DOT_YELLOW" "$DOT_ORANGE" "$DOT_RED")
  local out="" i
  for i in 0 1 2 3; do
    if [ "$level" -ge 0 ] 2>/dev/null && [ "$i" -eq "$level" ] 2>/dev/null; then
      out+="${cols[$i]}●${RESET}"
    else
      out+="${DOT_GREY}●${RESET}"
    fi
  done
  printf '%s' "$out"
}

perf_badge=""
if [ "$perf_mode" != "off" ]; then
  hit_rate="" avg_resp=""
  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ] && [ -r "$transcript_path" ]; then
    signals=$(jq -rs '
      def usage: (.message.usage // .toolUseResult.usage // null);
      def ts:
        .timestamp as $t |
        if   ($t | type) == "number" then (if $t > 1e12 then $t/1000 else $t end)
        elif ($t | type) == "string" then ($t | fromdateiso8601? // null)
        elif ($t | type) == "object" then ($t.epoch // $t.seconds // null)
        else null end;
      . as $rows
      | ([$rows[] | usage | select(. != null)]) as $u
      | ([$u[] | (.cache_read_input_tokens // 0)] | add // 0) as $hits
      | ([$u[] | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)] | add // 0) as $total
      | (if $total > 0 then ($hits * 100.0 / $total) else null end) as $hit_rate
      | (reduce range(0; $rows|length) as $i ([];
           ($rows[$i]) as $row |
           if $row.type == "assistant" then
             ([range(0; $i) | . as $j | $rows[$j] | select(.type == "user") | ts | select(. != null)]) as $uts
             | ($row | ts) as $a_ts
             | (if ($uts|length) > 0 then ($uts | last) else null end) as $u_ts
             | if $u_ts != null and $a_ts != null and ($a_ts - $u_ts) > 0 and ($a_ts - $u_ts) < 86400
               then . + [$a_ts - $u_ts]
               else . end
           else . end
        )) as $deltas
      | (if ($deltas|length) > 0 then ($deltas | add / length) else null end) as $avg_resp
      | "\($hit_rate // "")\t\($avg_resp // "")"
    ' "$transcript_path" 2>/dev/null)
    hit_rate="${signals%%	*}"
    avg_resp="${signals#*	}"
  fi

  cache_level=$(_perf_level_for_cache "$hit_rate")
  latency_level=$(_perf_level_for_latency "$avg_resp")

  case "$perf_mode" in
    cache_only)   overall_level="$cache_level" ;;
    latency_only) overall_level="$latency_level" ;;
    *)
      if [ "$cache_level" -lt 0 ] && [ "$latency_level" -lt 0 ]; then
        overall_level=-1
      elif [ "$cache_level" -lt 0 ]; then
        overall_level="$latency_level"
      elif [ "$latency_level" -lt 0 ]; then
        overall_level="$cache_level"
      else
        overall_level=$(( cache_level > latency_level ? cache_level : latency_level ))
      fi ;;
  esac

  perf_badge=$(_build_perf_badge "$overall_level")
fi

# ── Utility: visible-length measurement ──────────────────────────────────────

# _visible_len str — ANSI-stripped display column count; emoji (4-byte UTF-8) count as 2
_visible_len() {
  printf '%s' "$1" | LC_ALL=C awk -v ESC='\033' '
    BEGIN { pat = ESC "\\[[0-9;]*[A-Za-z]" }
    {
      s = $0
      while (match(s, pat)) {
        n += _cols(substr(s, 1, RSTART - 1))
        s  = substr(s, RSTART + RLENGTH)
      }
      n += _cols(s)
    }
    function _cols(t,    i, b, c) {
      c = 0; i = 1
      while (i <= length(t)) {
        b = substr(t, i, 1)
        if      (b >= "\360") { c += 2; i += 4 }
        else if (b >= "\340") { c += 1; i += 3 }
        else if (b >= "\300") { c += 1; i += 2 }
        else if (b >= "\200") {         i += 1 }
        else                  { c += 1; i += 1 }
      }
      return c
    }
    END { print n+0 }
  '
}

# ── Utility: level/budget color helpers ───────────────────────────────────────

# _level_color v yt rt → ANSI escape (SPEC §11)
_level_color() {
  local v="$1" yt="$2" rt="$3"
  awk -v v="$v" -v yt="$yt" -v rt="$rt" \
      -v red="$RED" -v yel="$YELLOW" -v grn="$GREEN" \
      'BEGIN { if (v+0 >= rt+0) print red; else if (v+0 >= yt+0) print yel; else print grn }'
}

_level_color_int() {
  local v=$1 yt=$2 rt=$3
  if   [ "$v" -ge "$rt" ]; then printf '%s' "$RED"
  elif [ "$v" -ge "$yt" ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# _budget_color spent allowance → ANSI escape (SPEC §11)
_budget_color() {
  local spent="$1" allowance="$2"
  awk -v s="$spent" -v a="$allowance" \
      -v red="$RED" -v yel="$YELLOW" -v grn="$GREEN" -v rst="$RESET" \
      -v wlo="$BUDGET_WARN_LO" -v whi="$BUDGET_WARN_HI" \
      'BEGIN {
        if (a+0 <= 0) { if (s+0 > 0) print red; else print rst; exit }
        r = s / a
        if (r <= wlo) print grn
        else if (r <= whi) print yel
        else print red
      }'
}

# _iso_reset_hhmm dt → local HH:MM or empty
_iso_reset_hhmm() {
  local dt="$1"
  [ -z "$dt" ] && return
  # Strip fractional seconds and Z/offset, parse to epoch, format local HH:MM
  local epoch
  epoch=$(printf '%s' "$dt" | sed 's/\.[0-9]*//g; s/Z$//' | \
    (date -jf "%Y-%m-%dT%H:%M:%S" "$(cat)" +%s 2>/dev/null || \
     date -d "$(cat | sed 's/T/ /')" +%s 2>/dev/null)) 2>/dev/null
  [ -n "$epoch" ] && (date -d "@$epoch" +%H:%M 2>/dev/null || date -r "$epoch" +%H:%M 2>/dev/null)
}

# count_month_workdays work_days_str [holidays_raw] → "elapsed total remaining"
count_month_workdays() {
  local wds="$1" hols="${2:-}"
  awk -v wds="$wds" -v holidays="$hols" 'BEGIN {
    cmd_ym = "date +%Y-%m"
    cmd_ym | getline ym; close(cmd_ym)
    split(ym, a, "-"); yr=a[1]+0; mo=a[2]+0

    # Days in month
    if (mo==2) { dim=(yr%4==0 && (yr%100!=0||yr%400==0)) ? 29 : 28 }
    else if (index("4 6 9 11", mo"") > 0) { dim=30 }
    else { dim=31 }

    # DOW of 1st (1=Mon..7=Sun, date +%u)
    cmd_dow = "date +%u -d \""yr"-"sprintf("%02d",mo)"-01\" 2>/dev/null"
    if ((cmd_dow | getline dow_str) <= 0 || dow_str+0 == 0) {
      # BSD fallback
      cmd_dow2 = "date -jf \"%Y-%m-%d\" \""yr"-"sprintf("%02d",mo)"-01\" +%u 2>/dev/null"
      close(cmd_dow)
      cmd_dow2 | getline dow_str; close(cmd_dow2)
    } else { close(cmd_dow) }
    dow1 = (dow_str == "" ? 1 : dow_str+0)

    cmd_dom = "date +%-d 2>/dev/null || date +%d"
    cmd_dom | getline dom_str; close(cmd_dom)
    today = dom_str+0; if (today < 1) today=1

    # Count workdays
    el=0; tot=0; rem=0
    for (d=1; d<=dim; d++) {
      # DOW: (dow1-1+d-1)%7 → 0=Mon..6=Sun → convert to 1-7
      dw = ((dow1-1 + d-1) % 7) + 1
      if (index(wds, dw"") > 0) {
        tot++
        if (d <= today) el++
        if (d >= today) rem++
      }
    }
    if (tot < 1) tot=1
    if (rem < 1) rem=1

    # Holiday adjustment — purely awk, no extra date subshells
    if (holidays != "") {
      n = split(holidays, harr, ",")
      for (hi = 1; hi <= n; hi++) {
        h = harr[hi]; gsub(/ /, "", h)
        if (h !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) continue
        h_ym = substr(h, 1, 7)
        if (h_ym != ym) continue
        h_da = substr(h, 9, 2) + 0
        h_dw = ((dow1 - 1 + h_da - 1) % 7) + 1
        if (index(wds, h_dw "") == 0) continue
        if      (h_da < today) { el--; tot-- }
        else if (h_da == today) { el--; tot--; rem-- }
        else                    { tot--; rem-- }
      }
      if (el < 0) el = 0
      if (tot < 1) tot = 1
      if (rem < 1) rem = 1
    }

    print el, tot, rem
  }'
}

# ── OAuth fetch helper (§4.4, §4.6, §5.1, §5.2) ──────────────────────────────

_fetch_usage_cache_bg() {
  printf '%s' "$$" > "$USAGE_FETCH_LOCK"
  # Lock is NOT removed on exit — its mtime serves as the "last fetch attempt" timestamp.

  local _pfx="" _token
  command -v timeout >/dev/null 2>&1 && _pfx="timeout 5"
  # macOS keychain first; fall back to ~/.claude/.credentials.json on Linux
  if command -v security >/dev/null 2>&1; then
    _token=$($_pfx security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
             | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  fi
  if [ -z "$_token" ] && [ -f "$_CLAUDE_DIR/.credentials.json" ]; then
    _token=$(jq -r '.claudeAiOauth.accessToken // empty' "$_CLAUDE_DIR/.credentials.json" 2>/dev/null)
  fi

  if [ -z "$_token" ]; then
    printf '%s' "$NOW" > "$AUTH_ERROR_FILE"
    return
  fi

  local _tmp="${USAGE_CACHE_FILE}.tmp.$$"
  curl --max-time 10 -sS \
    -H "Authorization: Bearer $_token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/${version}" \
    "https://api.anthropic.com/api/oauth/usage" \
    -o "$_tmp" 2>/dev/null
  local _ce=$?

  if [ "$_ce" -eq 0 ] && jq -e . "$_tmp" >/dev/null 2>&1 \
     && ! jq -e '.error' "$_tmp" >/dev/null 2>&1; then
    rm -f "$AUTH_ERROR_FILE"
    mv "$_tmp" "$USAGE_CACHE_FILE"
  else
    printf '%s' "$NOW" > "$AUTH_ERROR_FILE"
    rm -f "$_tmp"
  fi
}

# ── OAuth usage cache: stale detection + refresh trigger (§4.4, §4.6) ────────
#
# Phase 1 — read lock state (no mutations yet)
_lock_age=999999
if [ -f "$USAGE_FETCH_LOCK" ]; then
  _lm=$(_mtime "$USAGE_FETCH_LOCK")
  _lock_age=$(( NOW - ${_lm:-0} ))
fi

# Phase 2 — read cache state
cache_age=999999
if [ -f "$USAGE_CACHE_FILE" ]; then
  cache_mtime=$(_mtime "$USAGE_CACHE_FILE")
  cache_age=$(( NOW - ${cache_mtime:-0} ))
fi

# Phase 3 — stale display decision (must happen BEFORE fetch spawn so the
# brand-new lock created in Phase 5 does not suppress ⚠️ on this render)
plan_seg="" extra_seg="" monthly_seg=""
_usage_cache_stale=0 _usage_fetch_slow=0

if [ "$cache_age" -lt 999999 ] && [ "$cache_age" -ge $(( 3 * CACHE_TTL )) ]; then
  if [ -f "$USAGE_FETCH_LOCK" ]; then
    if [ "$_lock_age" -lt "$LOCK_INFLIGHT_GRACE" ]; then
      _usage_cache_stale=0   # fetch in flight; suppress
    elif [ "$_lock_age" -lt "$LOCK_LEAK_TIMEOUT" ]; then
      _usage_cache_stale=1   # fetch completed but cache not refreshed → failed
    else
      _usage_cache_stale=0   # lock abandoned (sleep/reboot); treat as hopeful
    fi
  fi  # no lock → first render after expiry → hopeful (stale=0, fetch spawned below)
fi

# Slow-fetch spinner: cache overdue but not yet showing ⚠️ (⚠️ supersedes ↻)
[ "$cache_age" -ge $(( CACHE_TTL + 30 )) ] && [ "$_usage_cache_stale" -eq 0 ] && _usage_fetch_slow=1

# Phase 4 — clean up leaked lock (≥ LOCK_LEAK_TIMEOUT old)
if [ -f "$USAGE_FETCH_LOCK" ] && [ "$_lock_age" -ge "$LOCK_LEAK_TIMEOUT" ]; then
  rm -f "$USAGE_FETCH_LOCK"
  _lock_age=999999
fi

# Phase 5 — fetch trigger (rate-limited by FETCH_RETRY_COOLDOWN)
_need_refresh=0
if [ "$cache_age" -ge "$CACHE_TTL" ]; then
  if [ ! -f "$USAGE_FETCH_LOCK" ]; then
    _need_refresh=1
  elif [ "$_lock_age" -ge "$FETCH_RETRY_COOLDOWN" ]; then
    _need_refresh=1
  fi
fi

if [ "$_need_refresh" = "1" ]; then
  : > "$USAGE_FETCH_LOCK"   # touch (sets mtime=NOW); NOT removed on fetch exit
  ( _fetch_usage_cache_bg & ) >/dev/null 2>&1 3>&- 4>&- 5>&- 6>&- 7>&- 8>&- 9>&-
fi

# Parse cache fields — single jq pass
_fh_util="" _sd_util="" _fh_resets="" _sd_resets=""
_ex_enabled="" _ex_used="" _ex_limit=""
if [ -f "$USAGE_CACHE_FILE" ]; then
  {
    IFS= read -r _fh_util
    IFS= read -r _sd_util
    IFS= read -r _fh_resets
    IFS= read -r _sd_resets
    IFS= read -r _ex_enabled
    IFS= read -r _ex_used
    IFS= read -r _ex_limit
  } < <(jq -r '
      ((.five_hour.utilization // null) | if . then (. + 0.5 | floor | tostring) else "" end),
      ((.seven_day.utilization // null) | if . then (. + 0.5 | floor | tostring) else "" end),
      (.five_hour.resets_at // ""),
      (.seven_day.resets_at // ""),
      (.extra_usage.is_enabled // ""),
      (.extra_usage.used_credits // ""),
      (.extra_usage.monthly_limit // "")
    ' "$USAGE_CACHE_FILE" 2>/dev/null)
fi

# Auth error flag — computed once, used in multiple sections below
_auth_error=0
[ -f "$AUTH_ERROR_FILE" ] && _auth_error=1

# _plan_slot label int color resets — renders one Pro/Max utilization slot
_plan_slot() {
  local label="$1" int="$2" color="$3" resets="$4"
  local slot
  if [ "$int" -ge 100 ] 2>/dev/null; then
    slot="${RED}${BOLD}🪫100%${RESET}"
  else
    slot="${color}${label}:"
    if [ "$_usage_cache_stale" = "1" ]; then
      slot+="${STRIKETHROUGH}"
    else
      slot+="${BOLD}"
    fi
    slot+="${int}%${RESET}"
    if [ "$int" -ge 75 ] && [ -n "$resets" ]; then
      local hhmm; hhmm=$(_iso_reset_hhmm "$resets")
      [ -n "$hhmm" ] && slot+=" ${DIM}↻${hhmm}${RESET}"
    fi
  fi
  printf '%s' "$slot"
}

# ── Pro/Max plan display (§8.2) ───────────────────────────────────────────────
if [ -n "$_fh_util" ]; then
  _fh_int="${_fh_util:-0}"
  _sd_int="${_sd_util:-0}"
  _fh_color=$(_level_color_int "$_fh_int" 75 90)
  _sd_color=$(_level_color_int "$_sd_int" 75 90)

  _fh_slot=$(_plan_slot "5h" "$_fh_int" "$_fh_color" "$_fh_resets")
  _sd_slot=$(_plan_slot "7d" "$_sd_int" "$_sd_color" "$_sd_resets")
  plan_seg="${_fh_slot}  ${_sd_slot}"

  # Extra badge (§8.3) for Pro/Max
  if [ "$_ex_enabled" = "true" ] && [ -n "$_ex_limit" ] && [ "${_ex_limit:-0}" != "0" ]; then
    _show_extra=0
    [ "${_ex_used:-0}" != "0" ] && _show_extra=1
    if [ "$_fh_int" -ge "${extra_preview_pct:-75}" ] 2>/dev/null; then _show_extra=1; fi
    if [ "$_show_extra" = "1" ]; then
      _used_fmt=$(_fmt_cents "${_ex_used:-0}")
      _lim_fmt="\$$(_fmt_cents "${_ex_limit:-0}" 0)"
      if [ "$_auth_error" = "1" ]; then
        extra_seg=" ${DIM}+🔑${RESET} ${STRIKETHROUGH}\$${_used_fmt}/${_lim_fmt}${RESET}"
      elif [ "$_usage_cache_stale" = "1" ]; then
        extra_seg=" ${DIM}+⚠️${RESET} ${STRIKETHROUGH}\$${_used_fmt}${RESET}${DIM}/${_lim_fmt}${RESET}"
      else
        extra_seg=" ${DIM}+💰${RESET} ${BOLD}\$${_used_fmt}${RESET} ${DIM}/${_lim_fmt}${RESET}"
      fi
    fi
  fi
fi

# ── Enterprise monthly display (§8.4) ─────────────────────────────────────────
_allow_1h="" _allow_1d=""

if [ -z "$_fh_util" ] && [ "$_ex_enabled" = "true" ] && [ -n "$_ex_limit" ]; then
  _ex_used_v="${_ex_used:-0}"
  _ex_limit_v="${_ex_limit:-1}"

  # Determine state glyph
  if [ "$_auth_error" = "1" ]; then
    _ent_glyph="🔑" _ent_stale=1
  elif [ "$_usage_cache_stale" = "1" ]; then
    _ent_glyph="⚠️" _ent_stale=1
  else
    _ent_glyph="💰" _ent_stale=0
    # Check burned
    if awk -v u="$_ex_used_v" -v l="$_ex_limit_v" 'BEGIN{exit (u+0 >= l+0 ? 0 : 1)}'; then
      _ent_glyph="🪫"
    fi
  fi

  # Workday counting (with holidays)
  read -r _wk_elapsed _wk_total _wkdays < <(count_month_workdays "$work_days_str" "$holidays_raw")

  # Fractional elapsed (for pace)
  _midnight="$_DAY_START"
  _secs_since_mid=$(( NOW - _midnight ))
  [ "$_secs_since_mid" -lt 0 ] && _secs_since_mid=0
  _today_dow=$(date +%u)
  _is_workday=0
  [[ "$work_days_str" == *"$_today_dow"* ]] && _is_workday=1
  _today_frac=$(awk -v s="$_secs_since_mid" -v h="${hours_per_day:-6}" \
    'BEGIN{ step=s/(h*3600); if(step>3)step=3; printf "%.6f", step/3 }')
  if [ "$_is_workday" = "1" ] && [ "$_wk_elapsed" -ge 1 ] 2>/dev/null; then
    _wk_elapsed_frac=$(awk -v e="$_wk_elapsed" -v f="$_today_frac" 'BEGIN{printf "%.6f", (e-1)+f}')
  else
    _wk_elapsed_frac=$(awk -v e="$_wk_elapsed" 'BEGIN{printf "%.6f", e+0}')
  fi

  # All monetary calcs in awk
  _ent_calcs=$(awk -v u="$_ex_used_v" -v l="$_ex_limit_v" \
    -v ef="$_wk_elapsed_frac" -v wt="$_wk_total" \
    -v wd="$_wkdays" -v hpd="${hours_per_day:-6}" \
    'BEGIN{
      used=u/100; lim=l/100
      rem_usd=(lim-used > 0 ? lim-used : 0)
      usage_pct = (lim > 0 ? used/lim : 0)
      day_pct   = (wt > 0 ? ef/wt    : 0)
      pct_int   = int(usage_pct * 100 + 0.5)
      if (day_pct < 1e-9) { pace="—" }
      else { pace = sprintf("%.6f", usage_pct / day_pct) }
      if (day_pct < 0.05) {
        if      (usage_pct < 0.05)  m_level=0
        else if (usage_pct <= 0.10) m_level=1
        else                        m_level=2
      } else {
        ratio = usage_pct / day_pct
        if      (ratio < 0.9)  m_level=0
        else if (ratio <= 1.1) m_level=1
        else                   m_level=2
      }
      # per-day allowance
      per_day  = (wd > 0 ? rem_usd/wd : rem_usd)
      allow_1h = per_day / hpd
      allow_15m= allow_1h / 4
      allow_1d = per_day
      printf "%s\t%s\t%d\t%.6f\t%.6f\t%.6f\t%.6f\t%s\t%d\n", \
        sprintf("%.6f",used), sprintf("%.6f",rem_usd), pct_int, \
        allow_15m, allow_1h, allow_1d, per_day, pace, m_level
    }')
  IFS=$'\t' read -r _used_usd _rem_usd _pct_int _allow_15m _allow_1h _allow_1d _per_day _pace _m_level \
    <<< "$_ent_calcs"
  _used_usd=$(_fmt_money "$_used_usd")
  _rem_usd=$(_fmt_money "$_rem_usd")
  [ "$_pace" != "—" ] && _pace=$(_fmt_money "$_pace")

  case "$_m_level" in
    0) _m_color="$GREEN"  ;;
    1) _m_color="$YELLOW" ;;
    2) _m_color="$RED"    ;;
    *) _m_color=""        ;;
  esac

  _lim_usd=$(_fmt_cents "$_ex_limit_v" 0)

  # Runway allowance cache (§4.5) — written only when loadavg=on
  if [ "$loadavg_mode" = "on" ]; then
    _hols_key="${holidays_raw:-none}"
    _ra_today=$(date +%Y-%m-%d)
    # Check if existing cache is still valid
    _write_ra=1
    if [ -f "$RUNWAY_CACHE_FILE" ]; then
      read -r _ra_ep _ra_ymd _ra_lim _ra_hkey _ra_used _ra_15m _ra_1h _ra_1d < "$RUNWAY_CACHE_FILE" 2>/dev/null || true
      _ra_day_start="$_DAY_START"
      if [ "$_ra_ymd" = "$_ra_today" ] && \
         [ "${_ra_ep:-0}" -ge "$_ra_day_start" ] 2>/dev/null && \
         [ "$_ra_lim" = "$_ex_limit_v" ] && \
         [ "$_ra_hkey" = "$_hols_key" ]; then
        _write_ra=0
        _allow_15m=$_ra_15m
        _allow_1h=$_ra_1h
        _allow_1d=$_ra_1d
      fi
    fi
    if [ "$_write_ra" = "1" ]; then
      printf '%d %s %s %s %s %s %s %s\n' \
        "$NOW" "$_ra_today" "$_ex_limit_v" "$_hols_key" "$_ex_used_v" \
        "$_allow_15m" "$_allow_1h" "$_allow_1d" \
        > "$RUNWAY_CACHE_FILE"
    fi
  else
    # When not loadavg=on, clear allowances so no suffix appears
    _allow_15m="" _allow_1h="" _allow_1d=""
  fi

  # Build monthly_seg — precedence: auth-broken > burned > normal/stale
  if [ "$_ent_glyph" = "🔑" ]; then
    # Auth-broken (§8.4, Example F): no ≈%, no 🔥pace×; amount+limit struck through, no color
    monthly_seg="${DIM}🔑${RESET}${STRIKETHROUGH}\$${_used_usd}/\$${_lim_usd}${RESET}  "
  elif [ "$_ent_glyph" = "🪫" ]; then
    # Burned state
    monthly_seg="${DIM}🪫${RED}${BOLD}\$${_used_usd}/\$${_lim_usd}${RESET}  "
  else
    # Fresh (💰) or stale (⚠️) — glyph already set in _ent_glyph; stale adds STRIKETHROUGH to amount
    if [ "$_ent_stale" = "1" ]; then
      _money="${_m_color}${STRIKETHROUGH}\$${_used_usd}${RESET}"
    else
      case "$sign_mode" in
        used_minus)
          if awk -v u="$_used_usd" 'BEGIN{exit (u+0>0?0:1)}'; then
            _money="${BOLD}${_m_color}-\$${_used_usd}${RESET}"
          else
            _money="${BOLD}\$${_used_usd}${RESET}"
          fi ;;
        remaining_plus)
          _money="${BOLD}${_m_color}+\$${_rem_usd}${RESET}" ;;
        both)
          _money="${BOLD}${_m_color}-\$${_used_usd} +\$${_rem_usd}${RESET}" ;;
        *)
          _money="${BOLD}${_m_color}\$${_used_usd}${RESET}" ;;
      esac
    fi
    monthly_seg="${DIM}${_ent_glyph}${_money}${DIM}/\$${_lim_usd}${RESET}${DIM}≈${BOLD}${_pct_int}%${RESET}  "
    if [ "$show_pace_ratio" = "on" ]; then
      monthly_seg+="${DIM}🔥${BOLD}${_pace}×${RESET}  "
    fi
  fi
fi

# ── Line 2 assembly (§10) ──────────────────────────────────────────────────────
# §10 item 1: leading ZWSP + two spaces
line2="${SPACE}  "

# §10 item 2: performance badge
if [ -n "$perf_badge" ]; then
  line2+="${perf_badge}"
fi
# §10 item 3: always two spaces
line2+="  "

# §10 items 4–7: slow-fetch + plan/extra/monthly (§8.2–§8.5)
_has_plan_seg=0
[ -n "$plan_seg" ]   && _has_plan_seg=1
[ -n "$extra_seg" ]  && _has_plan_seg=1
[ -n "$monthly_seg" ] && _has_plan_seg=1
# §8.5 slow-fetch ↻ — shown before segments when lock is old and segments non-empty
if [ "$_usage_fetch_slow" = "1" ] && [ "$_has_plan_seg" = "1" ]; then
  line2+="${DIM}↻${RESET}"
fi
[ -n "$plan_seg" ]    && line2+="${plan_seg}"
[ -n "$extra_seg" ]   && line2+="${extra_seg}"
if [ -n "$monthly_seg" ]; then
  line2+="${monthly_seg}"  # monthly_seg already carries trailing "  "
elif [ "$_has_plan_seg" = "1" ]; then
  line2+="  "
fi

# §10 item 8: cost pair + 3 trailing spaces (if non-empty)
if [ -n "$cost_seg" ]; then
  line2+="${cost_seg}   "
fi

# §10 item 9: rolling 💸 windows — built into _spend_seg for adaptive truncation
_spend_seg=""
if [ "$loadavg_mode" != "off" ] && [ -f "$LOG_FILE" ]; then
  read -r s15 s1h s1d nd15 nd1h nd1d < <(calc_spent_all)
  # Allowances for 15m/1h/1d (Enterprise + loadavg=on only)
  _r_allow_15m="" _r_allow_1h="" _r_allow_1d=""
  if [ "$loadavg_mode" = "on" ] && [ -n "$_allow_1h" ] && [ "$_auth_error" != "1" ]; then
    _r_allow_15m=$(_fmt_money "$_allow_15m")
    _r_allow_1h=$(_fmt_money "$_allow_1h")
    _r_allow_1d=$(_fmt_money "$_allow_1d")
  fi
  if [ -n "$_r_allow_1h" ]; then
    IFS=$'\t' read -r _bc_15m _bc_1h _bc_1d <<< "$(awk \
      -v s15="$s15" -v a15="$_r_allow_15m" \
      -v s1h="$s1h" -v a1h="$_r_allow_1h" \
      -v s1d="$s1d" -v a1d="$_r_allow_1d" \
      -v red="$RED" -v yel="$YELLOW" -v grn="$GREEN" -v rst="$RESET" \
      -v wlo="$BUDGET_WARN_LO" -v whi="$BUDGET_WARN_HI" \
      'BEGIN{
        split("", sa); split("", aa)
        sa[1]=s15; sa[2]=s1h; sa[3]=s1d
        aa[1]=a15; aa[2]=a1h; aa[3]=a1d
        for (i=1;i<=3;i++) {
          s=sa[i]+0; a=aa[i]+0
          if (a<=0) { c=(s>0?red:rst) }
          else { r=s/a; c=(r<=wlo?grn:r<=whi?yel:red) }
          printf "%s%s", c, (i<3?"\t":"")
        }
        printf "\n"
      }')"
  else
    _bc_15m="" _bc_1h="" _bc_1d=""
  fi
  # 15m: colored but no allowance suffix (pass empty 5th arg, bcolor as 6th)
  _spend_seg="${DIM}💸${RESET}  $(_roll_slot 15m "$s15" "$nd15" "$sign_mode" "" "$_bc_15m")  $(_roll_slot 1h "$s1h" "$nd1h" "$sign_mode" "$_r_allow_1h" "$_bc_1h")  $(_roll_slot 1d "$s1d" "$nd1d" "$sign_mode" "$_r_allow_1d" "$_bc_1d")"
elif [ "$loadavg_mode" != "off" ]; then
  # log file doesn't exist yet (very first run before lock acquired or log created)
  _spend_seg="${DIM}💸${RESET}  15m:${DIM}—${RESET}  1h:${DIM}—${RESET}  1d:${DIM}—${RESET}"
fi

# Adaptive truncation: suppress spend segment if it would cause line 2 to wrap.
# Uses _TERM_W_RAW (pre-floor) so narrow terminals (<88) still trigger suppression.
if [ -n "$_spend_seg" ]; then
  _line2_available=$(( _TERM_W_RAW - 3 ))
  _len_without=$(( $(_visible_len "$line2") - 3 ))
  _len_spend=$(_visible_len "$_spend_seg")

  if [ "$_len_without" -le "$_line2_available" ] && \
     [ $(( _len_without + _len_spend )) -gt "$_line2_available" ]; then
    _spend_seg=""
  fi
fi
[ -n "$_spend_seg" ] && line2+="$_spend_seg"

# ── Output (§14) ──────────────────────────────────────────────────────────────
printf '%s\n' "$line1"
printf '%s'   "$line2"
