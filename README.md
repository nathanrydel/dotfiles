# dotfiles

Config for zsh, tmux, Neovim (LazyVim), Ghostty and Zellij. Used on macOS, with Linux (Omarchy) fallbacks in a few places.

## Setup

```sh
git clone git@github.com:nathanrydel/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` creates these symlinks. It is safe to re-run. It never overwrites a real file: if something is already in the way, it prints `SKIP` and exits non-zero, so you can move that file and run it again.

| Link | Points to |
|---|---|
| `~/.config/nvim` | `nvim/` |
| `~/.config/tmux` | `tmux/` |
| `~/.config/ghostty` | `ghostty/` |
| `~/.config/zellij` | `zellij/` |
| `~/.zshrc` | `zshrc/.zshrc` |

## After linking

- **Neovim:** open `nvim`. lazy.nvim installs the plugins pinned in `nvim/lazy-lock.json`.
- **tmux:** install [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`, start tmux, then press `prefix I` (prefix is `Ctrl-a`).
- **zsh:** the tools it hooks into are optional and load only if installed: starship, zoxide, atuin, direnv, fzf, fd, eza, bat, mise, zsh-autosuggestions.

## Updating

- Neovim plugins: run `:Lazy update`, then commit `nvim/lazy-lock.json`.
- tmux plugins: `prefix U`.
