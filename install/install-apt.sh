#!/usr/bin/env bash
set -e

# ===============================
# APT Installer (Ubuntu + Pi OS)
# ===============================

REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(eval echo "~$REAL_USER")"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_DIR"

echo "========================================"
echo "Installing Virtual Embedded Lab"
echo "User: $REAL_USER"
echo "========================================"
echo ""

echo "Step 1: Updating system..."
sudo apt update
sudo apt upgrade -y

echo "Step 2: Installing system packages..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    avrdude \
    openocd \
    esptool \
    alsa-utils \
    libportaudio2 \
    ffmpeg \
    ustreamer

echo "Step 3: Creating Python virtual environment..."
if [ -d "venv" ]; then
    echo "Removing old venv (safety fix)"
    rm -rf venv
fi

python3 -m venv venv

VENV_PY="$PROJECT_DIR/venv/bin/python3"

echo "Step 4: Installing Python dependencies..."
"$VENV_PY" -m pip install --upgrade pip
"$VENV_PY" -m pip install -r requirements.txt

echo "Step 5: Creating directories..."
mkdir -p uploads default_fw static/sop

echo "Step 6: Installing systemd services..."
if [ -d "services" ]; then
    sudo cp services/*.service /etc/systemd/system/
    sudo chmod 644 /etc/systemd/system/*.service
else
    echo "❌ services directory missing"
    exit 1
fi

sudo systemctl daemon-reload
sudo systemctl enable vlabiisc.service audio_stream.service mjpg-streamer.service

echo "Step 7: Setting permissions..."
sudo usermod -aG dialout "$REAL_USER"

echo "Step 8: ALSA compatibility fix..."
sudo mkdir -p /tmp/vendor/share/alsa
sudo cp -r /usr/share/alsa/* /tmp/vendor/share/alsa/

echo ""
echo "========================================"
echo "✅ INSTALLATION SUCCESSFUL"
echo "========================================"
echo ""
echo "Reboot required:"
echo "  sudo reboot"
