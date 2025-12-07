#!/bin/bash
set -e

# Installer for SD Card Keep-Alive (ROG Ally X – Realtek RTS525A)

# 1. Ensure directories exist
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"

# 2. Copy keep-alive script into ~/.local/bin
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/sd_keepalive.sh" "$HOME/.local/bin/sd_keepalive.sh"
chmod +x "$HOME/.local/bin/sd_keepalive.sh"

# 3. Create the systemd user service
cat > "$HOME/.config/systemd/user/sd-keepalive.service" << 'EOF'
[Unit]
Description=SD Card Keep-Alive Service for Realtek RTS525A
After=default.target

[Service]
Type=simple
ExecStart=%h/.local/bin/sd_keepalive.sh
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

# 4. Enable and start the service
systemctl --user daemon-reload
systemctl --user enable --now sd-keepalive.service

echo "SD keep-alive service installed and started."
echo "Check status with: systemctl --user status sd-keepalive.service"
echo "Stop/disable with: systemctl --user stop sd-keepalive.service && systemctl --user disable sd-keepalive.service"
