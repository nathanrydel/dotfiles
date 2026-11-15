#!/bin/sh
# Symlink configs into place. Safe to re-run; never overwrites an existing file.
set -eu

DOTFILES=$(cd "$(dirname "$0")" && pwd)
status=0

link() { # link <path in repo> <target>
  src="$DOTFILES/$1"
  dst="$2"
  if [ -e "$dst" ] && [ "$(realpath "$dst")" = "$(realpath "$src")" ]; then
    echo "ok    $dst"
  elif [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "SKIP  $dst already exists; move it away and re-run"
    status=1
  else
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "link  $dst -> $src"
  fi
}

link nvim         "$HOME/.config/nvim"
link tmux         "$HOME/.config/tmux"
link ghostty      "$HOME/.config/ghostty"
link zellij       "$HOME/.config/zellij"
link zshrc/.zshrc "$HOME/.zshrc"

exit $status
