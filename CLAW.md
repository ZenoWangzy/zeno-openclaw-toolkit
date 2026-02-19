# CLAW.md (for OpenClaw Gateway Agents)

Use this runbook when orchestrating Claude Code tasks.

## Goal

Reliable CC automation with strict phases:
1. brainstorming
2. writing-plans
3. executing-plans

## 3-Minute Setup

1) Put notifier hook at:
- `~/.claude/hooks/notify-openclaw-event.sh`

2) Merge snippet:
- `config/claude-settings-snippet.json` into `~/.claude/settings.json`

3) Ensure scripts are executable:
```bash
chmod +x config/dispatch-claude.sh config/watch-cc-task.sh skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh
```

## Execution Policy

- Prompt to CC must be in **English**.
- For unattended runs, block `AskUserQuestion`.
- Use assumptions instead of blocking interviews.
- Keep edits minimal and reversible.

## Standard Orchestration

### Stage 1 — Brainstorm only
- Dispatch with task text clearly saying "brainstorming only, no fixes".
- Required output file: `discord-brainstorm.md` (or task-specific brainstorm file).

### Stage 2 — Plan only
- Dispatch with approved brainstorm context.
- Required output file: `*.plan.md`.

### Stage 3 — Execute only
- Dispatch with approved plan.
- Require validation evidence and rollback notes.

## Watchdog Expectations

`config/watch-cc-task.sh` must notify OpenClaw on:
- timeout
- stall (no output change)
- API/network error patterns
- non-zero process exit

## Fail Rules

Treat as failure if any required report file is missing.

## Suggested Defaults

- timeout: 30 min
- stall: 8 min
- callback target: owner DM
