# EXAMPLES (Three-Stage Templates)

## Stage 1 — Brainstorm

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Brainstorming only. Investigate <problem>. Do not apply fixes. Write findings to /path/to/<name>-brainstorm.md and end with READY_FOR_PLAN." \
  --name "<name>-brainstorm" \
  --workdir "/path/to/workspace" \
  --mode auto
```

## Stage 2 — Writing Plans

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Writing-plans only. Based on /path/to/<name>-brainstorm.md, produce /path/to/<name>.plan.md with checkpoints, validation, and rollback. Do not execute changes." \
  --name "<name>-plan" \
  --workdir "/path/to/workspace" \
  --mode semi-auto
```

## Stage 3 — Executing Plans

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Executing-plans only. Execute /path/to/<name>.plan.md with minimal reversible changes. Validate with status/log evidence and write /path/to/<name>-report.md." \
  --name "<name>-execute" \
  --workdir "/path/to/workspace" \
  --mode auto \
  --agent-teams
```

## Recommended operator flow

1. Wait callback from Stage 1, review brainstorm file.
2. Approve Stage 2.
3. Review plan, approve Stage 3.
4. Check final report + rollback section.
