# Zeno OpenClaw Skill Kit

A zero-friction, community-ready kit for running Claude Code with OpenClaw using a reliable, plan-first workflow.

## Who this is for

- Human operators (English + Chinese)
- OpenClaw gateway/agents (machine-readable runbook via `CLAW.md`)
- Teams that want reproducible CC automation with callbacks and watchdog alerts

## What you get

- **Superpowers-aware dispatch skill** (`skill/superpowers-aware-dispatch`)
- **Async callback flow** (Stop/SessionEnd hooks)
- **Watchdog alerts** (timeout / stall / API error / non-zero exit)
- **AskUserQuestion guard** for unattended runs

## 3-minute onboarding

See:
- **Agent runbook:** `CLAW.md`
- **Human quickstart (EN):** `EXAMPLES.md`
- **中文快速上手：** `README.zh-CN.md` + `CLAW.zh-CN.md` + `EXAMPLES.zh-CN.md`

## Files

- `CLAW.md` / `CLAW.zh-CN.md` — for gateway agents
- `EXAMPLES.md` / `EXAMPLES.zh-CN.md` — three-stage command templates
- `config/` — operational scripts/snippets
- `skill/` — reusable OpenClaw skill

## Repository

- GitHub: https://github.com/ZenoWangzy/openclaw-cc-superpowers-kit

## License

MIT
