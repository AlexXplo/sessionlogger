#!/bin/bash

# sessionlogger.sh - Tracker de activitate în shell
# Loghează timpul activ, comenzile rulate, directoarele vizitate

SESSION_START=$(date +%s)
SESSION_DATE=$(date +%Y-%m-%d)
LOG_DIR="$HOME/.sessionlogs"
LOG_FILE="$LOG_DIR/$SESSION_DATE.log"
IDLE_TIMEOUT=300  # secunde de inactivitate până consideră pauză

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

echo "🔴 [SessionLogger] Tracking started at $(date)" | tee -a "$LOG_FILE"
echo "-------------------------------------------" >> "$LOG_FILE"

# Hook în shell: loghează fiecare comandă rulată
export PROMPT_COMMAND='
  if [[ $BASH_COMMAND != $LAST_LOGGED_CMD ]]; then
    CURRENT_TIME=$(date +%s)
    if [[ -z "$LAST_CMD_TIME" ]]; then
        LAST_CMD_TIME=$CURRENT_TIME
    fi
    DIFF=$((CURRENT_TIME - LAST_CMD_TIME))
    if [[ $DIFF -ge $IDLE_TIMEOUT ]]; then
        echo "🟡 Idle for $((DIFF / 60)) min" >> "'$LOG_FILE'"
    fi
    echo "[📍 $(pwd)] → $BASH_COMMAND" >> "'$LOG_FILE'"
    LAST_LOGGED_CMD="$BASH_COMMAND"
    LAST_CMD_TIME=$CURRENT_TIME
  fi'

# La ieșirea din shell
trap cleanup EXIT

cleanup() {
    SESSION_END=$(date +%s)
    DURATION=$((SESSION_END - SESSION_START))
    MINUTES=$((DURATION / 60))
    echo "🔚 [SessionLogger] Închis la $(date), durată: $MINUTES minute" >> "$LOG_FILE"
}

# Interactiv: anunță userul
echo "📊 [SessionLogger] Rulează. Tot ce faci în terminal va fi logat în $LOG_FILE"
