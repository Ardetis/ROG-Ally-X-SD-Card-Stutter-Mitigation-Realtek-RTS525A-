#!/bin/bash

# SD-card keep-alive for ROG Ally X (Realtek RTS525A)
# Writes a 1-byte file every few seconds to prevent the controller/card
# from entering a faulty low-power state that causes stutter.

CARD_MOUNT="/run/media/$USER/EF8S5"     # Adjust if SD label changes
KEEPALIVE_FILE="$CARD_MOUNT/.sd_keepalive"
INTERVAL_SECONDS=3                      # 3 seconds required for stability

log() {
    printf '[sd_keepalive] %s\n' "$*" >&2
}

log "Starting SD keep-alive on $CARD_MOUNT (interval: ${INTERVAL_SECONDS}s)"

while true; do
    if [ -d "$CARD_MOUNT" ]; then
        # Write a single byte to keep the controller active
        printf . > "$KEEPALIVE_FILE" 2>/dev/null || log "Failed to write keepalive file"
    else
        log "Mount point not found: $CARD_MOUNT"
    fi
    sleep "$INTERVAL_SECONDS"
done
