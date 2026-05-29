#!/bin/bash
# Send native macOS notifications to cmux on Claude Code events.
# No-op outside cmux (the control socket is absent), so it's safe to leave
# enabled globally — it stays silent in plain Ghostty / other terminals.
[ -S /tmp/cmux.sock ] || exit 0

EVENT=$(cat)
EVENT_TYPE=$(printf '%s' "$EVENT" | jq -r '.hook_event_name // "unknown"')

case "$EVENT_TYPE" in
  Stop)
    cmux notify --title "Claude Code" --body "Session complete"
    ;;
  Notification)
    MSG=$(printf '%s' "$EVENT" | jq -r '.message // "Needs your attention"')
    cmux notify --title "Claude Code" --subtitle "Waiting" --body "$MSG"
    ;;
  SubagentStop)
    cmux notify --title "Claude Code" --body "Subagent finished"
    ;;
esac
