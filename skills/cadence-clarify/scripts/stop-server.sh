#!/usr/bin/env bash
# Stop the Dev Cadence visual companion server and clean up
# Usage: stop-server.sh <session_dir>
#
# Kills the server process. Only deletes ephemeral sessions created
# without --project-dir. Persistent project directories are kept so
# mockups can be reviewed later.

SESSION_DIR="$1"

if [[ -z "$SESSION_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"
SERVER_INSTANCE_ID_FILE="${STATE_DIR}/server-instance-id"

is_safe_server_pid() {
  local pid="$1"
  local expected_id=""
  local command_line=""

  if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  if [[ ! -f "$SERVER_INSTANCE_ID_FILE" ]]; then
    return 1
  fi

  expected_id="$(tr -d '\r\n' < "$SERVER_INSTANCE_ID_FILE")"
  if [[ ! "$expected_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    return 1
  fi

  command_line="$(ps -ww -o command= -p "$pid" 2>/dev/null || true)"
  [[ "$command_line" == *"server.cjs"* && "$command_line" == *"--dev-cadence-visual-server-id=${expected_id}"* ]]
}

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")

  if ! is_safe_server_pid "$pid"; then
    rm -f "$PID_FILE"
    echo '{"status": "stale_pid"}'
    exit 0
  fi

  # Try to stop gracefully, fallback to force if still alive
  kill "$pid" 2>/dev/null || true

  # Wait for graceful shutdown (up to ~2s)
  for i in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # If still running, escalate to SIGKILL
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true

    # Give SIGKILL a moment to take effect
    sleep 0.1
  fi

  if kill -0 "$pid" 2>/dev/null; then
    echo '{"status": "failed", "error": "process still running"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # Only delete ephemeral sessions created by start-server.sh without --project-dir.
  if [[ "$SESSION_DIR" == /tmp/dev-cadence-visual-companion-* ]]; then
    rm -rf "$SESSION_DIR"
  fi
  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
