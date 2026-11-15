# -------------------------------------------------------------
# --- CONSOLIDATED Zsh Configuration (Optimized for macOS) ---
# -------------------------------------------------------------

# ==============================
# 1. Critical Initialization (Pre-Config)
# ==============================


# ==============================
# 2. Base Zsh Settings & Completion
# ==============================
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

# Zsh History Configuration
HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=50000
setopt inc_append_history

# ==============================
# 3. External Tool Initialization
# ==============================

# Starship Prompt
if command -v starship &> /dev/null; then
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
    eval "$(starship init zsh)"
fi

# Zoxide (Smart directory jumping)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Atuin (Optional, for advanced shell history synchronization/search)
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi

# Direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# FZF (Fuzzy Finder) Configuration
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# Zsh Autosuggestions (Kept in Homebrew per our split)
if command -v brew &> /dev/null && [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle

# ==============================
# 4. Keybindings
# ==============================

# VI Mode Keybindings
bindkey jj vi-cmd-mode
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# ==============================
# 5. Path & Environment Variables (Exports)
# ==============================

export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"

# --- Path Hierarchy (Order Matters!) ---
# 1. Local Bins
# 2. Homebrew (GUI Casks and fallback formulas)
# 3. System Paths
export PATH="$HOME/.local/share/omarchy/bin:$PATH"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Go & Rust & Vim Packages
export GOPATH="$HOME/go"
export GOBIN="${GOPATH}/bin"
export PATH="${GOPATH}/bin:$HOME/.cargo/bin:$HOME/.vimpkg/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Bun
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# Editor Configuration (Dynamic based on PATH)
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# ==============================
# 6. TMUX Session Management Function & Alias
# ==============================

new_tmux () {
    session_dir=$(zoxide query --list | fzf)
    session_name=$(basename "$session_dir")

    if tmux has-session -t "$session_name" 2>/dev/null; then
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "$session_name"
        else
            tmux attach -t "$session_name"
        fi
        notification="tmux attached to $session_name"
    else
        if [ -n "$TMUX" ]; then
            tmux new-session -d -c "$session_dir" -s "$session_name" && tmux switch-client -t "$session_name"
            notification="new tmux session INSIDE TMUX: $session_name"
        else
            tmux new-session -c "$session_dir" -s "$session_name"
            notification="new tmux session: $session_name"
        fi
    fi

    if [ -n "$notification" ] && command -v notify-send &> /dev/null; then
        notify-send "$notification"
    fi
}
alias tm=new_tmux

# ==============================
# 7. Functions
# ==============================

# Ranger File Manager Function
function ranger {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command
        ranger
        --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
    )
    "${ranger_cmd[@]}" "$@"

    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}
alias rr='ranger'

# Navigation Functions
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# ==============================
# 8. Aliases (Core Development Focused)
# ==============================

# --- General System & Tools ---
alias cl='clear'
alias la=tree
alias cat=bat
alias http="xh"
alias reload='source ~/dotfiles/zshrc/.zshrc'
alias ci='code-insiders'
alias clauded='claude --dangerously-skip-permissions'

# --- Core Editor Aliases (Fixed!) ---
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias n="nvim ."

# --- Navigation Dirs ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# --- Eza (Modern ls replacement) ---
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# --- Python Development Aliases (uv) ---
alias venv='uv venv'
alias act='source .venv/bin/activate'
alias uva='uv add'
alias uvd='uv dev'
alias uvs='uv sync --all-extras'
alias uvpi='uv pip install'
alias uvpr='uv pip install -r requirements.txt'

# --- TypeScript/Node Development Aliases ---
alias npmr='npm run'
alias npi='npm install'
alias tfw='tsc --watch'

# pnpm
alias pni='pnpm install'
alias pnir='pnpm install -r'
alias pna='pnpm add'
alias pnd='pnpm dev'

# Bun
alias b="bun"
alias bi="bun install"
alias ba="bun add"
alias bad="bun add -d"
alias brm="bun remove"
alias br="bun run"
alias bd="bun run dev"
alias bb="bun run build"
alias bx="bun x"

# --- Go Development Aliases ---
alias gof='go fmt ./...'
alias got='go test ./...'
alias gwb='go build ./...'

# --- Rust Development Aliases ---
alias c="cargo"
alias cb="cargo build"
alias cr="cargo run"
alias ct="cargo test"
alias ca="cargo add"
alias crm="cargo remove"
alias cw="cargo watch -x run" 

# --- Game Dev & C# Aliases ---
alias rider="open -a 'Rider'"
alias rd="rider ."
alias dn="dotnet"
alias dnb="dotnet build"
alias dnr="dotnet run"
alias uhub="open -a 'Unity Hub'"
alias ueditor="open '/Users/Shared/Epic Games/UE_5.4/Engine/Binaries/Mac/UnrealEditor.app'"

# --- Docker ---
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# --- Git Productivity Aliases ---
alias g='git'
alias gf='git fetch'
alias ga='git add -p'
alias gadd='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push origin HEAD'
alias gpu='git pull origin'
alias gst='git status'
alias glog='git log --graph --topo-order --pretty="%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N" --abbrev-commit'
alias gdiff="git diff"
alias gb='git branch'
alias gba='git branch -a'
alias gcoall='git checkout -- .'
alias gre='git reset'
alias grem='git remote'

# --- Modern Git Commands ---
alias gsw='git switch'
alias gsn='git switch -c'
alias grs='git restore'

# Mise: activate last so its tool paths win over PATH edits above
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi
