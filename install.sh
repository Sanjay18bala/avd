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
  cp "$(dirname "$0")/avd-completion.sh" "$INSTALL_DIR/avd-completion.sh"
else
  curl -fsSL "$REPO_RAW/avd" -o "$INSTALL_DIR/avd"
  curl -fsSL "$REPO_RAW/avd-completion.sh" -o "$INSTALL_DIR/avd-completion.sh"
fi
chmod +x "$INSTALL_DIR/avd"

echo "avd installed to $INSTALL_DIR/avd"

completion_line="source \"$INSTALL_DIR/avd-completion.sh\""
case "${SHELL:-}" in
  */zsh) rc_file="$HOME/.zshrc" ;;
  */bash) rc_file="$HOME/.bashrc" ;;
  *) rc_file="" ;;
esac

if [[ -n "$rc_file" ]]; then
  if [[ -f "$rc_file" ]] && grep -qF "avd-completion.sh" "$rc_file"; then
    :
  else
    printf '\n# avd tab completion\n%s\n' "$completion_line" >> "$rc_file"
    echo "Added tab completion to $rc_file (restart your terminal to use it)"
  fi
else
  echo "For tab completion, add this to your shell rc file:"
  echo "  $completion_line"
fi

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo ""
    echo "$INSTALL_DIR is not on your PATH. Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

echo "Done. Try: avd -v \"<video url>\""
