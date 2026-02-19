$ErrorActionPreference = 'Stop'

$KitDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$HomeDir = [Environment]::GetFolderPath('UserProfile')
$ClaudeDir = Join-Path $HomeDir '.claude'
$HooksDir = Join-Path $ClaudeDir 'hooks'
$OpenClawWs = Join-Path $HomeDir '.openclaw\workspace'
$DispatchDir = Join-Path $OpenClawWs 'claude-code-dispatch-macos\scripts'

New-Item -ItemType Directory -Force -Path $HooksDir, $DispatchDir, (Join-Path $OpenClawWs 'skills') | Out-Null

Copy-Item -Force (Join-Path $KitDir 'config\dispatch-claude.sh') (Join-Path $DispatchDir 'dispatch-claude.sh')
Copy-Item -Force (Join-Path $KitDir 'config\watch-cc-task.sh') (Join-Path $DispatchDir 'watch-cc-task.sh')

$SkillTarget = Join-Path $OpenClawWs 'skills\superpowers-aware-dispatch'
if (Test-Path $SkillTarget) { Remove-Item -Recurse -Force $SkillTarget }
Copy-Item -Recurse -Force (Join-Path $KitDir 'skill\superpowers-aware-dispatch') $SkillTarget

$NotifyScript = Join-Path $HooksDir 'notify-openclaw-event.sh'
if (-not (Test-Path $NotifyScript)) {
@'
#!/usr/bin/env bash
set -euo pipefail
EVENT_NAME="${1:-claude_event}"
DETAIL="${2:-}"
CFG="$HOME/.openclaw/openclaw.json"
TOKEN=$(jq -r '.gateway.auth.token // empty' "$CFG" 2>/dev/null || true)
[[ -z "$TOKEN" ]] && exit 0
curl -sS -X POST "http://127.0.0.1:18789/api/cron/wake" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"CC alert: ${EVENT_NAME} ${DETAIL}\",\"mode\":\"now\"}" >/dev/null 2>&1 || true
'@ | Set-Content -Encoding UTF8 $NotifyScript
}

Write-Host 'Installed Zeno OpenClaw Skill Kit ✅'
Write-Host "- Dispatch: $DispatchDir\dispatch-claude.sh"
Write-Host "- Watchdog: $DispatchDir\watch-cc-task.sh"
Write-Host "- Skill: $SkillTarget"
Write-Host 'Note: merge config/claude-settings-snippet.json manually into ~/.claude/settings.json if needed.'
