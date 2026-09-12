#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

rm -f "$INSTALL_DIR/avd" "$INSTALL_DIR/avd-completion.sh"

case "${SHELL:-}" in
  */zsh) rc_file="$HOME/.zshrc" ;;
  */bash) rc_file="$HOME/.bashrc" ;;
  *) rc_file="" ;;
esac

if [[ -n "$rc_file" && -f "$rc_file" ]] && grep -qF "avd-completion.sh" "$rc_file"; then
  sed -i.bak '/# avd tab completion/,+1d' "$rc_file"
  rm -f "$rc_file.bak"
  echo "Removed tab completion from $rc_file (restart your terminal for it to take effect)"
fi

echo "avd uninstalled."
