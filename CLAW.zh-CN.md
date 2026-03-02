# CLAW.zh-CN.md（给 OpenClaw Gateway Agent）

用于编排 Claude Code 任务的标准手册。

## 目标

用严格三阶段保证稳定性：
1. brainstorming（只调研）
2. writing-plans（只写计划）
3. executing-plans（按计划执行）

## 3分钟接入

1）放置通知脚本：
- `~/.claude/hooks/notify-openclaw-event.sh`

2）将配置片段合并到 Claude 设置：
- `config/claude-settings-snippet.json` -> `~/.claude/settings.json`

3）确保脚本可执行：
```bash
chmod +x config/dispatch-claude.sh config/watch-cc-task.sh skill/superpowers-aware-dispatch/scripts/dispatch-superpowers.sh
```

## 执行策略

- 发给 CC 的 prompt 一律英文。
- 无人值守任务必须阻断 `AskUserQuestion`。
- 通过 `ASSUMPTION:` 继续推进，不要无限等待采访。
- 仅做最小可回滚改动。
- 任务派发后按异步运行，优先等待 hook 回调（`latest.json`/channel 通知），避免高频轮询。
- 看门狗默认每 5 分钟发送一次 `cc_progress` 状态，确保用户可见中间进展。
- 仅在回调异常、看门狗告警或人工要求介入时，才手动查状态。

## 标准流程

### 阶段1：只做 Brainstorm
- Prompt 必须写明“只调研，不执行修复”。
- 必须产出：`discord-brainstorm.md`（或指定调研文件）。

### 阶段2：只做 Plan
- 基于已确认调研结果写计划。
- 必须产出：`*.plan.md`。

### 阶段3：只做 Execute
- 仅按已批准计划执行。
- 必须包含验证证据与回滚步骤。

## 看门狗要求

`config/watch-cc-task.sh` 需要在以下场景通知 OpenClaw：
- 超时
- 长时间无输出（stall）
- API/网络错误关键词
- 进程非0退出

## 失败规则

只要要求的报告文件缺失，就视为失败。
