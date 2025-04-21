#!/bin/bash

set -e

REPO_URL="https://github.com/kireevroi/gaia"
INSTALL_DIR="gaia"

# Optional version tag
VERSION=${1:-"master"}

# Fix for broken terminal state after piping (Ubuntu issue)
stty sane 2>/dev/null || true

echo "[INFO] Cloning Gaia setup scripts (branch/tag: $VERSION)..."
git clone --depth 1 --branch "$VERSION" "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[INFO] Making scripts executable..."
find modules -name '*.sh' -exec chmod +x {} \;
chmod +x setup.sh

echo "[INFO] Starting Gaia setup..."
./setup.sh

# To run:
# curl -s https://raw.githubusercontent.com/kireevroi/gaia/master/install.sh | bash
# Or with a tag:
# curl -s https://raw.githubusercontent.com/kireevroi/gaia/master/install.sh | bash -s -- v1.0.0