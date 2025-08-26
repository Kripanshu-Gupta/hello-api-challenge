#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/helloapi"
SERVICE_NAME="helloapi"

# Ensure we have basic packages and Node.js (LTS)
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Create app directory
sudo mkdir -p "$APP_DIR"
sudo chown -R "$USER":"$USER" "$APP_DIR"

# Copy service file if present in current directory
if [ -f "./deploy/helloapi.service" ]; then
  sudo cp ./deploy/helloapi.service /etc/systemd/system/helloapi.service
fi

# Install dependencies
pushd "$APP_DIR" >/dev/null
if [ -f package.json ]; then
  npm ci --only=production || npm install --omit=dev
fi
popd >/dev/null

# Enable and restart service
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"
sudo systemctl status "$SERVICE_NAME" --no-pager -l || true