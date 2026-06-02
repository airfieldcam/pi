#!/bin/bash
set -e

INSTALL_DIR="$HOME/airfieldcam"

echo ""
echo "  ╔═══════════════════════════════════╗"
echo "  ║     AirfieldCam Pi Updater        ║"
echo "  ╚═══════════════════════════════════╝"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo "  ✗ AirfieldCam installation not found at $INSTALL_DIR"
    echo "    Please run the installer first."
    exit 1
fi

cd "$INSTALL_DIR"

echo "  → Downloading latest configuration..."
curl -fsSL https://raw.githubusercontent.com/airfieldcam/pi/main/docker-compose.yml -o docker-compose.yml
echo "  ✓ Configuration updated"

echo "  → Pulling latest images..."
docker compose pull
echo "  ✓ Images updated"

echo "  → Restarting services..."
docker compose up -d
echo "  ✓ Services restarted"

echo ""
echo "  ✓ AirfieldCam updated successfully"
echo ""
