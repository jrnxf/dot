#!/usr/bin/env python3
"""Stop hook: enforce the `Skills used: ...` trailer mandated by CLAUDE.md.

When the assistant invoked one or more Skills during the current turn but its
final message lacks a `Skills used:` line, block the stop and instruct the model
to append it. `stop_hook_active` guards against looping after the single nudge.

Reads the Claude Code Stop-hook JSON on stdin:
  { transcript_path, stop_hook_active, ... }
Emits (only when a fix is needed):
  {"decision":"block","reason":"..."}
Otherwise exits 0 silently.
"""
import json
import re
import sys


def is_human_turn(rec):
    """A real user prompt vs. a tool_result-bearing 'user' record."""
    if rec.get("type") != "user" or rec.get("isSidechain"):
        return False
    content = (rec.get("message") or {}).get("content")
    if isinstance(content, str):
        return True
    # Human messages carry text blocks; tool results carry tool_result blocks.
    return isinstance(content, list) and any(
        isinstance(b, dict) and b.get("type") == "text" for b in content
    )


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    # Already nudged once this stop-cycle — don't loop.
    if data.get("stop_hook_active"):
        sys.exit(0)

    path = data.get("transcript_path")
    if not path:
        sys.exit(0)
    try:
        rows = [json.loads(l) for l in open(path, errors="ignore") if l.strip()]
    except Exception:
        sys.exit(0)

    # Index of the most recent real human prompt.
    last_user = max(
        (i for i, r in enumerate(rows) if is_human_turn(r)), default=-1
    )
    if last_user < 0:
        sys.exit(0)

    skills, final_text = [], []
    for rec in rows[last_user + 1:]:
        if rec.get("isSidechain") or rec.get("type") != "assistant":
            continue
        for b in (rec.get("message") or {}).get("content") or []:
            if not isinstance(b, dict):
                continue
            if b.get("type") == "tool_use" and b.get("name") == "Skill":
                name = (b.get("input") or {}).get("skill")
                if name and name not in skills:
                    skills.append(name)
            elif b.get("type") == "text":
                final_text.append(b.get("text", ""))

    if not skills:
        sys.exit(0)

    # Already has the trailer (any line starting with "Skills used:").
    if re.search(r"(?im)^\s*skills used:", "\n".join(final_text)):
        sys.exit(0)

    listed = ", ".join(skills)
    print(json.dumps({
        "decision": "block",
        "reason": (
            "CLAUDE.md requires that when you invoke skills you end the "
            f"response with a trailer line listing them. You used: {listed}. "
            "Reply with exactly that final line and nothing else:\n"
            f"Skills used: {listed}"
        ),
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
