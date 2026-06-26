---
name: alert
description: Pop a must-dismiss macOS alert (a modal dialog with an OK button + sound that stays on screen until clicked) — either right now, at a specific time, or when a condition/command finally succeeds. Use when the user says "alert me when…", "let me know when X finishes", "remind me at 6pm to…", "ping me once the deploy/upload/backup is done", "watch X and tell me when…", or wants a desktop notification they can't miss. macOS only.
---

# Must-Dismiss macOS Alert

Fire a **modal** macOS alert — a dialog with an OK button and a sound that sits on
screen until the user clicks it (unlike `display notification`, which is a transient
banner that slips into Notification Center). Three modes: **now**, **at a time**, or
**when a condition becomes true**.

## When to Use

- "alert me when the build / upload / backup / deploy finishes"
- "remind me at 18:00 to …", "ping me in 2 hours"
- "watch this command and let me know when it succeeds / when output appears"
- Any "I can't miss this" desktop notification on macOS

If the thing to watch is **only reachable from this Mac** (LAN hosts, local files,
`ssh` aliases, local services), a local launchd job is the right tool — a cloud
`/schedule` routine can't reach it. Say so if the user reaches for `/schedule`.

## The primitive: a sticky alert

This injection-safe function is the core. It passes text via `argv` (never
interpolated into AppleScript), and uses a foreground app (System Events) so the
dialog appears on top and **requires dismissal** (no `giving up after` timeout).
Args (positional): **title**, **message**, optional **icon** (`0`=stop, `1`=note/info,
`2`=caution; default `1`). It forwards `"$@"` straight to osascript — deliberately no
literal dollar-digit positionals, so invoking this skill as `/alert <args>` can't
mangle the code.

```bash
sticky_alert() { # args: title  message  [icon 0|1|2, default 1]
  /usr/bin/afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
  /usr/bin/osascript - "$@" >/dev/null 2>&1 <<'OSA'
on run argv
  set ic to 1
  if (count of argv) ≥ 3 then set ic to (item 3 of argv as integer)
  tell application "System Events"
    activate
    display dialog (item 2 of argv) with title (item 1 of argv) ¬
      buttons {"OK"} default button "OK" with icon ic
  end tell
end run
OSA
}
```

For ad-hoc terminal use, offer to drop this as `~/.local/bin/sticky-alert` (a script
whose body forwards `"$@"` to `sticky_alert`, `chmod +x`). Then
`sticky-alert "Done" "Build finished" 1`.

## Conventions (keep alert jobs uniform)

| thing            | pattern                                              |
| ---------------- | --------------------------------------------------- |
| launchd label    | `co.jrnxf.alert.<slug>`                              |
| job script       | `~/.local/bin/alert-<slug>.sh` (chmod +x)           |
| launchd plist    | `~/Library/LaunchAgents/co.jrnxf.alert.<slug>.plist`|
| log              | `~/Library/Logs/alert-<slug>.log`                   |

`<slug>` = short kebab-case name of what's being watched (e.g. `b2-verify`, `deploy-done`).

**Generated job scripts must EMBED `sticky_alert`** (don't depend on the skill or a
shared helper) so a scheduled alert keeps working even if this skill is removed.

## Mode A — alert now

Just call the primitive (or `sticky-alert`). No launchd needed.

## Mode B — alert at a specific time (one-shot)

launchd uses **local time** (no UTC conversion). `StartCalendarInterval` with
Day+Hour+Minute would repeat monthly, so the script **removes its own plist** after
firing → true one-shot. If the Mac is asleep at the time, launchd runs it on wake;
if off, at next boot.

Job script `~/.local/bin/alert-<slug>.sh`:

```bash
#!/bin/bash
set -uo pipefail
LABEL="co.jrnxf.alert.<slug>"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
sticky_alert() { # (paste the primitive here)
  /usr/bin/afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
  /usr/bin/osascript - "$@" >/dev/null 2>&1 <<'OSA'
on run argv
  set ic to 1
  if (count of argv) ≥ 3 then set ic to (item 3 of argv as integer)
  tell application "System Events"
    activate
    display dialog (item 2 of argv) with title (item 1 of argv) buttons {"OK"} default button "OK" with icon ic
  end tell
end run
OSA
}

sticky_alert "⏰ Reminder" "<message>" 1

/bin/launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null   # self-destruct (one-shot)
rm -f "$PLIST"
```

Plist (set Day/Hour/Minute to the local target time):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>co.jrnxf.alert.<slug></string>
  <key>ProgramArguments</key><array><string>/Users/colby/.local/bin/alert-<slug>.sh</string></array>
  <key>StartCalendarInterval</key><dict>
    <key>Day</key><integer>DD</integer><key>Hour</key><integer>HH</integer><key>Minute</key><integer>MM</integer>
  </dict>
  <key>StandardOutPath</key><string>/Users/colby/Library/Logs/alert-<slug>.log</string>
  <key>StandardErrorPath</key><string>/Users/colby/Library/Logs/alert-<slug>.log</string>
  <key>EnvironmentVariables</key><dict><key>PATH</key><string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string></dict>
</dict></plist>
```

Load it:

```bash
UID=$(id -u)
launchctl bootout gui/$UID/co.jrnxf.alert.<slug> 2>/dev/null
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/co.jrnxf.alert.<slug>.plist
launchctl print gui/$UID/co.jrnxf.alert.<slug> | grep -iE "state|runs"   # confirm registered
```

## Mode C — alert when a condition becomes true

The job runs a **check command** and only alerts when it passes; otherwise it stays
quiet and tries again later. Two ways to "try again":

- **Poll on an interval** — `StartInterval` (seconds) in the plist. Self-destruct
  only on PASS. Good for "tell me when this finishes" where the finish time is unknown.
- **Re-arm by time** — same one-shot as Mode B but re-schedule if not done.

Have the check distinguish **PASS / NOT-YET / ERROR** and alert accordingly (note /
note / caution icons). Keep checks self-contained; if they `ssh`, use
`ssh -o BatchMode=yes` and let **secrets stay on the remote host** (source the remote
env there — never pull keys onto the Mac or into the conversation).

Poll skeleton:

```bash
#!/bin/bash
set -uo pipefail
LABEL="co.jrnxf.alert.<slug>"; PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
LOG="$HOME/Library/Logs/alert-<slug>.log"
sticky_alert() { :; }   # (paste primitive)

echo "check @ $(date)" >>"$LOG"
if <CHECK_COMMAND> ; then
  sticky_alert "✅ <thing> ready" "<success message>" 1
  /bin/launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null   # done → stop polling
  rm -f "$PLIST"
fi
# not yet → exit quietly; launchd fires again next StartInterval
exit 0
```

Add to that plist instead of (or with) StartCalendarInterval:

```xml
<key>StartInterval</key><integer>1800</integer>   <!-- re-check every 30 min -->
```

## Listing / cancelling alert jobs

```bash
launchctl list | grep co.jrnxf.alert        # what's armed
UID=$(id -u); SLUG=<slug>
launchctl bootout gui/$UID/co.jrnxf.alert.$SLUG 2>/dev/null
rm -f ~/Library/LaunchAgents/co.jrnxf.alert.$SLUG.plist ~/.local/bin/alert-$SLUG.sh
```

## Always verify before leaving it armed

- **Dry-run the check command** (Mode C) so a typo doesn't surface only when it fires.
- **Test the dialog once** (`sticky_alert "Test" "..." 1`) — it must be dismissed.
- Confirm `launchctl print …` shows the job registered.

## Caveats (tell the user)

- Needs a **GUI login session** to render. Asleep at fire time → runs on wake; fully
  off → runs at next boot/login.
- The alert **blocks the job until dismissed** — fine for one-shots; for pollers it
  means the OK click happens before self-destruct (acceptable).
- macOS may ask to allow "System Events"/Terminal to control the computer the first
  time (Automation permission). Approve it once.
- These are **local** jobs — independent of any Claude session, but Mac-only and can't
  reach things this Mac can't.
```
