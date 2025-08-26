#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/helloapi"

sudo mkdir -p "$APP_DIR"
sudo chown -R "$USER":"$USER" "$APP_DIR"

# Sync code from uploaded workspace (current directory) into APP_DIR
rsync -a --delete --exclude '.git' --exclude '.github' --exclude 'node_modules' ./ "$APP_DIR"/

# Install only production deps
pushd "$APP_DIR" >/dev/null
npm ci --only=production || npm install --omit=dev
popd >/dev/null

# Reload service
sudo systemctl daemon-reload
sudo systemctl restart helloapi