#!/usr/bin/env bash
set -euo pipefail

TASK_NAME="$1"
PID="$2"
OUTPUT_FILE="$3"
EXIT_FILE="$4"
TIMEOUT_MIN="${5:-30}"
STALL_MIN="${6:-8}"
NOTIFY_BIN="${HOME}/.claude/hooks/notify-openclaw-event.sh"
PROGRESS_INTERVAL_SEC="${CC_PROGRESS_INTERVAL_SEC:-300}"

start_ts=$(date +%s)
last_notify_api_err=0
last_notify_progress=$start_ts

notify() {
  local evt="$1"
  local detail="$2"
  if [[ -x "$NOTIFY_BIN" ]]; then
    "$NOTIFY_BIN" "$evt" "$detail" || true
  fi
}

while true; do
  now=$(date +%s)
  elapsed=$((now - start_ts))

  # timeout guard
  if (( elapsed > TIMEOUT_MIN * 60 )); then
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
      sleep 1
      kill -9 "$PID" 2>/dev/null || true
    fi
    notify "cc_timeout" "task=${TASK_NAME} pid=${PID} elapsed=${elapsed}s"
    exit 0
  fi

  # process exited => check exit code and notify non-zero
  if ! kill -0 "$PID" 2>/dev/null; then
    if [[ -f "$EXIT_FILE" ]]; then
      ec=$(cat "$EXIT_FILE" 2>/dev/null || echo 1)
      if [[ "$ec" != "0" ]]; then
        notify "cc_exit_nonzero" "task=${TASK_NAME} exit=${ec}"
      fi
    else
      notify "cc_exit_unknown" "task=${TASK_NAME} pid=${PID}"
    fi
    exit 0
  fi

  # stall guard based on output mtime
  if [[ -f "$OUTPUT_FILE" ]]; then
    if stat -f %m "$OUTPUT_FILE" >/dev/null 2>&1; then
      mtime=$(stat -f %m "$OUTPUT_FILE")
    else
      mtime=$(stat -c %Y "$OUTPUT_FILE")
    fi
    idle=$((now - mtime))
    if (( idle > STALL_MIN * 60 )); then
      notify "cc_stall" "task=${TASK_NAME} idle=${idle}s"
      # don't spam; extend threshold window by bumping mtime reference via touch marker
      touch "$OUTPUT_FILE".watchdog-heartbeat 2>/dev/null || true
      sleep 60
    fi
  fi

  # API/network error pattern guard (best effort, notify at most once per 5 min)
  if [[ -f "$OUTPUT_FILE" ]]; then
    if grep -Eiq "unable to connect|timed out|timeout|ECONN|ENOTFOUND|429|5[0-9]{2}|api error|fetch failed" "$OUTPUT_FILE"; then
      if (( now - last_notify_api_err > 300 )); then
        last_notify_api_err=$now
        notify "cc_api_error" "task=${TASK_NAME} detected_in_output=1"
      fi
    fi
  fi

  # periodic heartbeat status (default every 5 min)
  if (( PROGRESS_INTERVAL_SEC > 0 )) && (( now - last_notify_progress >= PROGRESS_INTERVAL_SEC )); then
    last_notify_progress=$now
    idle_s="na"
    if [[ -f "$OUTPUT_FILE" ]]; then
      if stat -f %m "$OUTPUT_FILE" >/dev/null 2>&1; then
        mtime=$(stat -f %m "$OUTPUT_FILE")
      else
        mtime=$(stat -c %Y "$OUTPUT_FILE")
      fi
      idle_s=$((now - mtime))
    fi
    notify "cc_progress" "task=${TASK_NAME} pid=${PID} elapsed=${elapsed}s idle=${idle_s}s"
  fi

  sleep 20
done
