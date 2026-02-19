#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
HOOKS_DIR="${CLAUDE_DIR}/hooks"
OPENCLAW_WS="${HOME}/.openclaw/workspace"
DISPATCH_DIR="${OPENCLAW_WS}/claude-code-dispatch-macos/scripts"

mkdir -p "${HOOKS_DIR}" "${DISPATCH_DIR}" "${OPENCLAW_WS}/skills"

# Install dispatch/watchdog scripts
cp -f "${KIT_DIR}/config/dispatch-claude.sh" "${DISPATCH_DIR}/dispatch-claude.sh"
cp -f "${KIT_DIR}/config/watch-cc-task.sh" "${DISPATCH_DIR}/watch-cc-task.sh"
chmod +x "${DISPATCH_DIR}/dispatch-claude.sh" "${DISPATCH_DIR}/watch-cc-task.sh"

# Install skill
rm -rf "${OPENCLAW_WS}/skills/superpowers-aware-dispatch"
cp -R "${KIT_DIR}/skill/superpowers-aware-dispatch" "${OPENCLAW_WS}/skills/superpowers-aware-dispatch"

# Ensure notify script exists (best effort)
if [[ ! -f "${HOOKS_DIR}/notify-openclaw-event.sh" ]]; then
cat > "${HOOKS_DIR}/notify-openclaw-event.sh" <<'EOF'
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
EOF
chmod +x "${HOOKS_DIR}/notify-openclaw-event.sh"
fi

# Merge minimal hook settings snippet if jq available
SETTINGS_JSON="${CLAUDE_DIR}/settings.json"
if command -v jq >/dev/null 2>&1; then
  if [[ ! -f "${SETTINGS_JSON}" ]]; then
    echo '{"hooks":{}}' > "${SETTINGS_JSON}"
  fi
  TMP=$(mktemp)
  jq '.hooks = (.hooks // {})' "${SETTINGS_JSON}" > "$TMP" && mv "$TMP" "${SETTINGS_JSON}"

  # Add AskUserQuestion block hook
  if ! jq -e '.hooks.PreToolUse // [] | any(.matcher == "tool == \"AskUserQuestion\"")' "${SETTINGS_JSON}" >/dev/null; then
    TMP=$(mktemp)
    jq '.hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher":"tool == \"AskUserQuestion\"","hooks":[{"type":"command","command":"~/.claude/hooks/notify-openclaw-event.sh ask_user_question blocked; echo \"[Hook] BLOCKED AskUserQuestion for automation\" >&2; exit 1"}],"description":"Block AskUserQuestion in unattended automation and wake OpenClaw"}])' "${SETTINGS_JSON}" > "$TMP" && mv "$TMP" "${SETTINGS_JSON}"
  fi
fi

echo "Installed Zeno OpenClaw Skill Kit ✅"
echo "- Dispatch: ${DISPATCH_DIR}/dispatch-claude.sh"
echo "- Watchdog: ${DISPATCH_DIR}/watch-cc-task.sh"
echo "- Skill: ${OPENCLAW_WS}/skills/superpowers-aware-dispatch"
