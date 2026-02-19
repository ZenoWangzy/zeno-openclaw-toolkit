# EXAMPLES.zh-CN（三阶段模板）

## 阶段1：Brainstorm（只调研）

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Brainstorming only. Investigate <problem>. Do not apply fixes. Write findings to /path/to/<name>-brainstorm.md and end with READY_FOR_PLAN." \
  --name "<name>-brainstorm" \
  --workdir "/path/to/workspace" \
  --mode auto
```

## 阶段2：Writing Plans（只写计划）

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Writing-plans only. Based on /path/to/<name>-brainstorm.md, produce /path/to/<name>.plan.md with checkpoints, validation, and rollback. Do not execute changes." \
  --name "<name>-plan" \
  --workdir "/path/to/workspace" \
  --mode semi-auto
```

## 阶段3：Executing Plans（按计划执行）

```bash
bash skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh \
  --task "Executing-plans only. Execute /path/to/<name>.plan.md with minimal reversible changes. Validate with status/log evidence and write /path/to/<name>-report.md." \
  --name "<name>-execute" \
  --workdir "/path/to/workspace" \
  --mode auto \
  --agent-teams
```

## 推荐操作顺序

1. 等阶段1回调，先审阅 brainstorm。
2. 批准后再执行阶段2。
3. 审阅计划后再执行阶段3。
4. 最后检查 report 与 rollback 段落。
