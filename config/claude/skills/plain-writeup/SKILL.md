---
name: plain-writeup
description:
  Write a short, plain-English summary of a finding, investigation, or change — leading with the conclusion, saying how
  you know and what the fix is, in a human voice with no AI slop (noslopgrenade.com / stopsloppypasta.ai style). Use
  when the user asks to "summarize this plainly", "keep it terse", "less technical", "write it up", "explain it like a
  human", references either site, or wants a short readable recap of work you just did.
---

# Plain Writeup

Turn an investigation, diagnosis, change, or a user supplied body of text into a short human recap. Reference style:
https://noslopgrenade.com/, https://stopsloppypasta.ai/en/.

## When to use

- User asks to summarize something "plainly", "terse", "less technical", "like a human", or links either site.
- User wants a quick recap of work you just did: what's true, how you know, what you changed.

## Shape

Two short paragraphs. Each 2-3 sentences. If two feels long, use one.

1. **What's true + how you know.** Conclusion first. Then how you found out, in one plain clause. Not a methodology
   writeup.
2. **The fix + what's left.** What changed and where (PR number). Then the loose ends, in a few words.

No fix yet? Drop half of paragraph 2 — verdict plus what's next.

## Rules

- **Cut hard.** If a sentence survives deletion without losing meaning, delete it. Aim for half the words you first
  write. Every word you leave in is work you're pushing to the reader.
- **Match the medium.** A Slack reply should read like a Slack reply — a few sentences, not paragraphs. Calibrate length
  to what a person would write in that context, not to what the topic could support.
- **Distill, don't paste.** You own what you send. Your job is to extract the one thing that matters from everything you
  know — not to forward a summary. Length without distillation is just dumping.
- **Less technical by default.** "Jobs piled up faster than the workers could clear them" beats "queue saturation from
  enqueue-rate exceeding drain-rate." Skip metric names, exact numbers, timestamps, and file internals unless one
  specific detail is the whole point. "About two hours" beats "7,559s."
- **Say how you know in one clause**, not a play-by-play. "I checked PagerDuty and the metrics" is enough. Don't list
  every query.
- Conclusion in sentence one. No preamble, no "TL;DR" unless asked.
- Short plain sentences. Contractions fine. Write like a person, not a report.
- No "it's not just X, it's Y", no rule-of-three, no "here's the thing", no em-dash glue.
- State uncertainty plainly when it's real. Don't hedge when it isn't.
- No closing offer, no emoji, no ceremony.

## Delete on sight

- "Let me summarize", "Based on my analysis", "In conclusion", "I investigated and found that"
- Metric names and precise figures that a reader doesn't need to act
- Any clause explaining _how_ something works when _what happened_ is the point
- Adjective stacks ("robust, comprehensive")
- Headers, nested bullets, and bold labels — prose, not a report structure

## Example

Too much (reads like AI):

> The alert was right. `conversation_bot_handler` queue latency climbed to ~2 hours on June 26 and tripped the alert
> (`leadgenie_sidekiq_queue_latency_seconds > 3600s`). I confirmed fire/resolve times in PagerDuty (19:13→20:03Z),
> pulled the latency metric and watched it ramp 0 → 7,559s → 0, then checked throughput and saw it pinned at ~16 jobs/s.
> So the queue was saturated: a scheduler burst exceeded the 5-worker drain capacity.

Right:

> The alert was right. One of the Meeting Assistant job queues got buried for about two hours on June 26. I checked the
> timing in PagerDuty and the metrics to see why: jobs piled up faster than its 5 workers could clear them.
>
> It's a config fix, not code. PR #95771 lets the queue add workers when it backs up instead of being stuck at 5. Still
> open: smoothing the job spikes, and PagerDuty paging the wrong team.

Verdict first. One line on how you know. Fix. Stop.
