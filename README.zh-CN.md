# Zeno OpenClaw Skill Kit（中文）

这是一个面向社区的 **0门槛 OpenClaw + Claude Code 实战工具包**，强调：

- 先调研（brainstorm）
- 再计划（writing-plans）
- 再执行（executing-plans）
- 全程异步回调 + 异常看门狗

## 适用对象

- 人类用户（中英文都可）
- OpenClaw Gateway / Agent（通过 `CLAW.md` 指南）
- 需要稳定自动化执行 CC 任务的团队

## 你会得到什么

- Superpowers-aware dispatch skill
- 任务完成回调（Stop / SessionEnd）
- 异常告警（超时 / 卡住 / API错误 / 非0退出）
- 无人值守时阻断 AskUserQuestion

## 派发逻辑（关键）

- CC 任务发出去后按**异步模式**运行。
- Agent 侧以 **hook 回调优先**（`latest.json` / channel 通知）作为完成与状态信号。
- **不做高频轮询**；仅在回调异常、超时看门狗触发、或人工要求介入时，才手动排查状态。
- 这套模式可直接复用在 Windows OpenClaw Gateway（通过 `scripts/install.ps1` + `CLAW.zh-CN.md` 接入）。

## 3分钟接入

### 一键安装

- macOS/Linux：
```bash
bash scripts/install.sh
```
- Windows（PowerShell）：
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

然后：
- 给 Agent 看：`CLAW.md` / `CLAW.zh-CN.md`
- 人类命令模板：`EXAMPLES.md` / `EXAMPLES.zh-CN.md`

## 目录说明

- `CLAW.md` / `CLAW.zh-CN.md`：给 gateway agent 的运行手册
- `EXAMPLES.md` / `EXAMPLES.zh-CN.md`：三阶段命令模板
- `config/`：脚本与配置片段
- `skill/`：可复用 skill

仓库地址：
- https://github.com/ZenoWangzy/openclaw-cc-superpowers-kit
