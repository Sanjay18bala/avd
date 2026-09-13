#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/Sanjay18bala/avd/main"
INSTALL_DIR="$HOME/.local/bin"

echo "Installing avd..."

ensure_yt_dlp() {
  if command -v yt-dlp >/dev/null 2>&1; then
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    brew install yt-dlp
  else
    if ! command -v pip3 >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y python3-pip
    fi
    pip3 install --user -U yt-dlp
  fi
}

ensure_ffmpeg() {
  if command -v ffmpeg >/dev/null 2>&1; then
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    brew install ffmpeg
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y ffmpeg
  else
    echo "warning: could not auto-install ffmpeg. Install it manually (e.g. via your system package manager), then re-run this script." >&2
  fi
}

ensure_yt_dlp
ensure_ffmpeg

mkdir -p "$INSTALL_DIR"

if [[ -f "$(dirname "$0")/avd" ]]; then
  cp "$(dirname "$0")/avd" "$INSTALL_DIR/avd"
else
  curl -fsSL "$REPO_RAW/avd" -o "$INSTALL_DIR/avd"
fi
chmod +x "$INSTALL_DIR/avd"

echo "avd installed to $INSTALL_DIR/avd"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo ""
    echo "$INSTALL_DIR is not on your PATH. Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

echo "Done. Try: avd -v \"<video url>\""
