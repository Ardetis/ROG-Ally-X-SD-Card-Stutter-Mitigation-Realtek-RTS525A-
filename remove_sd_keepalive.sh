#!/bin/bash
set -e

SERVICE_NAME="sd-keepalive.service"
SERVICE_PATH="$HOME/.config/systemd/user/$SERVICE_NAME"
SCRIPT_PATH="$HOME/.local/bin/sd_keepalive.sh"

echo "Stopping SD keep-alive service..."
systemctl --user stop "$SERVICE_NAME" || true

echo "Disabling SD keep-alive service..."
systemctl --user disable "$SERVICE_NAME" || true

echo "Reloading systemd daemon..."
systemctl --user daemon-reload

# Remove service file
if [ -f "$SERVICE_PATH" ]; then
    echo "Removing service file: $SERVICE_PATH"
    rm "$SERVICE_PATH"
else
    echo "Service file not found: $SERVICE_PATH"
fi

# Remove script
if [ -f "$SCRIPT_PATH" ]; then
    echo "Removing keep-alive script: $SCRIPT_PATH"
    rm "$SCRIPT_PATH"
else
    echo "Keep-alive script not found: $SCRIPT_PATH"
fi

echo "SD keep-alive has been fully removed."
echo "You can verify with: systemctl --user status sd-keepalive.service"
