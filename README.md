# OpenClaw CC Superpowers Kit

A reusable **skill + config kit** for OpenClaw bots that dispatch Claude Code tasks with:

- Superpowers workflow (`brainstorming -> writing-plans -> executing-plans`)
- Async completion callbacks (Stop/SessionEnd hook)
- Watchdog alerts (timeout / stall / API error / non-zero exit)
- AskUserQuestion blocking for unattended automation

## What to call this

Use this term:

- **OpenClaw skill kit** (recommended)

It includes both a skill and operational scripts/config.

## Contents

- `skill/superpowers-aware-dispatch/` — Skill definition and prompt template
- `config/dispatch-claude.sh` — Claude dispatch runner
- `config/watch-cc-task.sh` — Watchdog monitor

## Core methodology

1. Run **brainstorming** first (research only)
2. Review brainstorming result with human
3. Run **writing-plans**
4. Review/approve plan
5. Run **executing-plans**

For unattended mode:
- do not block on interviews
- proceed with explicit assumptions (`ASSUMPTION:`)
- notify on any abnormal state

## Integration notes for OpenClaw

You also need a notifier script in Claude hooks (example path):

- `~/.claude/hooks/notify-openclaw-event.sh`

And a PreToolUse rule blocking `AskUserQuestion` for automation tasks.

## License

MIT
