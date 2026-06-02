#!/bin/bash
set -e

COMPOSE_URL="https://raw.githubusercontent.com/airfieldcam/pi/main/docker-compose.yml"
INSTALL_DIR="$HOME/airfieldcam"

echo ""
echo "  ╔═══════════════════════════════════╗"
echo "  ║     AirfieldCam Pi Installer      ║"
echo "  ╚═══════════════════════════════════╝"
echo ""

# ── Check we're on a Raspberry Pi ────────────────────────────────
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo "  ✗ This installer is intended for Raspberry Pi only."
    exit 1
fi
echo "  ✓ Raspberry Pi detected"

# ── Check for internet connectivity ──────────────────────────────
if ! curl -fsSL --max-time 5 https://hub.docker.com > /dev/null 2>&1; then
    echo "  ✗ No internet connection detected. Please connect and try again."
    exit 1
fi
echo "  ✓ Internet connection OK"

# ── Install Docker ────────────────────────────────────────────────
if command -v docker &> /dev/null; then
    echo "  ✓ Docker already installed"
else
    echo "  → Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "  ✓ Docker installed"
fi

# ── Install Docker Compose plugin ────────────────────────────────
if sudo docker compose version &> /dev/null; then
    echo "  ✓ Docker Compose already installed"
else
    echo "  → Installing Docker Compose plugin..."
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    ARCH=$(uname -m)
    if [ "$ARCH" = "armv7l" ]; then
        COMPOSE_ARCH="armv7"
    else
        COMPOSE_ARCH="aarch64"
    fi
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${COMPOSE_ARCH}" \
        -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    echo "  ✓ Docker Compose installed"
fi

# ── Create install directory ──────────────────────────────────────
mkdir -p "$INSTALL_DIR/config"
cd "$INSTALL_DIR"
echo "  ✓ Install directory: $INSTALL_DIR"

# ── Download docker-compose.yml ───────────────────────────────────
echo "  → Downloading configuration..."
curl -fsSL "$COMPOSE_URL" -o docker-compose.yml
echo "  ✓ Configuration downloaded"

# ── Generate Flask secret ─────────────────────────────────────────
if [ ! -f .env ]; then
    FLASK_SECRET=$(cat /proc/sys/kernel/random/uuid | tr -d '-')$(cat /proc/sys/kernel/random/uuid | tr -d '-')
    echo "FLASK_SECRET=$FLASK_SECRET" > .env
    echo "  ✓ Security key generated"
fi

# ── Pull images ───────────────────────────────────────────────────
echo "  → Pulling AirfieldCam images (this may take a few minutes)..."
sudo docker compose pull
echo "  ✓ Images downloaded"

# ── Start services ────────────────────────────────────────────────
echo "  → Starting services..."
sudo docker compose up -d
echo "  ✓ Services started"

# ── Get IP address ────────────────────────────────────────────────
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║         AirfieldCam installed successfully!       ║"
echo "  ╠═══════════════════════════════════════════════════╣"
echo "  ║                                                   ║"
echo "  ║  Open your browser and go to:                     ║"
echo "  ║                                                   ║"
echo "  ║    http://$IP:8080                    ║"
echo "  ║                                                   ║"
echo "  ║  You will be asked to set a password on           ║"
echo "  ║  first visit.                                     ║"
echo "  ║                                                   ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""
