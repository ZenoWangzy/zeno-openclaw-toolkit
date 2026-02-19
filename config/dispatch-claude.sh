#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/.openclaw/workspace/claude-code-dispatch-macos"
DATA_DIR="${BASE_DIR}/data"
META_FILE="${DATA_DIR}/task-meta.json"
TASK_OUTPUT="${DATA_DIR}/task-output.txt"
TASK_EXIT="${DATA_DIR}/task-exit-code.txt"
WATCHDOG_SCRIPT="${BASE_DIR}/scripts/watch-cc-task.sh"
CLAUDE_BIN_DEFAULT="${HOME}/.local/bin/claude"

mkdir -p "$DATA_DIR"

PROMPT=""
TASK_NAME="adhoc-$(date +%s)"
WORKDIR="$(pwd)"
CALLBACK_CHANNEL="discord"
CALLBACK_TARGET="853303202236858379"
CALLBACK_ACCOUNT=""
PERMISSION_MODE="bypassPermissions"
ALLOWED_TOOLS=""
AGENT_TEAMS=0
TEAMMATE_MODE="auto"
MODEL=""
CLAUDE_BIN="${CLAUDE_BIN:-$CLAUDE_BIN_DEFAULT}"
TIMEOUT_MIN="${CC_TIMEOUT_MIN:-30}"
STALL_MIN="${CC_STALL_MIN:-8}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prompt) PROMPT="$2"; shift 2;;
    -n|--name) TASK_NAME="$2"; shift 2;;
    -w|--workdir) WORKDIR="$2"; shift 2;;
    --channel) CALLBACK_CHANNEL="$2"; shift 2;;
    --target) CALLBACK_TARGET="$2"; shift 2;;
    --account) CALLBACK_ACCOUNT="$2"; shift 2;;
    --permission-mode) PERMISSION_MODE="$2"; shift 2;;
    --allowed-tools) ALLOWED_TOOLS="$2"; shift 2;;
    --agent-teams) AGENT_TEAMS=1; shift;;
    --teammate-mode) TEAMMATE_MODE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --claude-bin) CLAUDE_BIN="$2"; shift 2;;
    --timeout-min) TIMEOUT_MIN="$2"; shift 2;;
    --stall-min) STALL_MIN="$2"; shift 2;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "--prompt is required"
  exit 1
fi

if [[ ! -x "$CLAUDE_BIN" ]]; then
  if command -v claude >/dev/null 2>&1; then
    CLAUDE_BIN="$(command -v claude)"
  else
    echo "Claude binary not found. expected: $CLAUDE_BIN"
    exit 1
  fi
fi

jq -n \
  --arg task "$TASK_NAME" \
  --arg prompt "$PROMPT" \
  --arg wd "$WORKDIR" \
  --arg ts "$(date -Iseconds)" \
  --arg ch "$CALLBACK_CHANNEL" \
  --arg tg "$CALLBACK_TARGET" \
  --arg acc "$CALLBACK_ACCOUNT" \
  '{task_name:$task,prompt:$prompt,workdir:$wd,started_at:$ts,callback:{channel:$ch,target:$tg,account:$acc},status:"running"}' > "$META_FILE"

: > "$TASK_OUTPUT"
: > "$TASK_EXIT"

CMD=("$CLAUDE_BIN" -p "$PROMPT" --permission-mode "$PERMISSION_MODE")
if [[ -n "$ALLOWED_TOOLS" ]]; then
  CMD+=(--allowedTools "$ALLOWED_TOOLS")
fi
if [[ "$AGENT_TEAMS" -eq 1 ]]; then
  export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
  CMD+=(--teammate-mode "$TEAMMATE_MODE")
fi
if [[ -n "$MODEL" ]]; then
  export ANTHROPIC_MODEL="$MODEL"
fi

echo "Dispatching Claude task: $TASK_NAME"
echo "Claude bin: $CLAUDE_BIN"
echo "Workdir: $WORKDIR"

ohup bash -lc "cd $(printf '%q' "$WORKDIR") && $(printf '%q ' "${CMD[@]}") 2>&1 | tee $(printf '%q' "$TASK_OUTPUT"); ec=\${PIPESTATUS[0]}; echo \$ec > $(printf '%q' "$TASK_EXIT"); exit \$ec" >/dev/null 2>&1 &
PID=$!

# Watchdog for timeout/stall/api-error/non-zero exit notifications
if [[ -x "$WATCHDOG_SCRIPT" ]]; then
  nohup bash "$WATCHDOG_SCRIPT" "$TASK_NAME" "$PID" "$TASK_OUTPUT" "$TASK_EXIT" "$TIMEOUT_MIN" "$STALL_MIN" >/dev/null 2>&1 &
fi

echo "Started PID=$PID"
echo "Meta: $META_FILE"
echo "Output: $TASK_OUTPUT"
echo "Exit: $TASK_EXIT"
echo "Watchdog: timeout=${TIMEOUT_MIN}m stall=${STALL_MIN}m"
