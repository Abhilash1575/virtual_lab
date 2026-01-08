#!/usr/bin/env bash
set -e

# ===============================
# Virtual Embedded Lab Installer
# Entry Script (Multi-OS)
# ===============================

REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(eval echo "~$REAL_USER")"

echo "Installing for user: $REAL_USER"
echo "Home directory     : $HOME_DIR"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

if [ ! -f /etc/os-release ]; then
    echo "❌ Cannot detect OS"
    exit 1
fi

. /etc/os-release

echo "Detected OS: $NAME ($ID)"
echo ""

case "$ID" in
    ubuntu|debian|raspbian|linuxmint|pop|elementary)
        bash "$INSTALL_DIR/install-apt.sh"
        ;;
    *)
        echo "❌ Unsupported OS: $ID"
        exit 1
        ;;
esac

echo ""
echo "✅ All done!"
