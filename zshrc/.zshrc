# --- Zsh Configuration Start ---

# ==============================
# 1. Base Zsh Settings & Completion
# ==============================
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

# Zsh History Configuration (Uses portable ~)
HISTFILE=~/.history       
HISTSIZE=10000            
SAVEHIST=50000            
setopt inc_append_history 


# ==============================
# 2. External Tool Initialization & Keybindings
# ==============================

# Starship Prompt
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# Zoxide, Atuin, Direnv (Portable initializers)
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"

# Mise (Assumes mise executable is in the PATH from Homebrew/Nix setup)
eval "$(mise activate zsh)"

# FZF (Fuzzy Finder)
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zsh Autosuggestions (Uses portable 'brew --prefix')
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle

# VI Mode Keybindings
bindkey jj vi-cmd-mode
bindkey '^L' vi-forward-word 
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search


# ==============================
# 3. Path & Environment Variables (Exports)
# ==============================

# Core System Exports
export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"

# Go Path (Portable)
export GOPATH="$HOME/go"

# Nix Configuration (Uses portable $HOME)
export NIX_CONF_DIR="$HOME/.config/nix"
export PATH=/run/current-system/sw/bin:$PATH

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# ==============================
# 4. OS-SPECIFIC CONFIGURATION
# ==============================

if [[ "$(uname)" == "Darwin" ]]; then
    # --- macOS (nrdevs) ---
    export EDITOR="$(brew --prefix)/bin/nvim"
    
    # Homebrew path initialization
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # PATH cleanup for macOS (Uses portable $HOME and $GOPATH)
    export PATH="$(brew --prefix)/bin:$PATH"
    export PATH="$HOME/.vimpkg/bin:${GOPATH}/bin:$HOME/.cargo/bin:$PATH"

    # Aliases
    alias update='brew update && brew upgrade'
    notify_cmd="terminal-notifier -message" # Or osascript if preferred

elif [[ "$(uname)" == *"Linux"* ]]; then
    # --- Linux (Omarchy / nr-navys) ---
    export EDITOR="nvim" # Assumes nvim is in standard path
    
    # PATH cleanup for Linux (Using common paths for Omarchy)
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
    export PATH="$HOME/.vimpkg/bin:${GOPATH}/bin:$HOME/.cargo/bin:$PATH"
    
    # Aliases
    alias update='sudo pacman -Syu' # Use pacman update command
    notify_cmd="notify-send"
fi

# Ensure mise/asdf paths are checked first (Portable)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/share/omarchy/bin:$PATH"

# ==============================
# 5. TMUX Session Management Function & Alias
# (Uses the portable $notify_cmd)
# ==============================

new_tmux () {
  session_dir=$(zoxide query --list | fzf)
  session_name=$(basename "$session_dir")

  if tmux has-session -t $session_name 2>/dev/null; then
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

  if [ -n "$notification" ]; then
    $notify_cmd "$notification"
  fi
}

alias tm=new_tmux


# ==============================
# 6. Functions
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

	${ranger_cmd[@]} "$@"
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

# Git Identity Switching Function
gitid() {
  local name email
  local ID_TYPE="$1"

  case "$ID_TYPE" in
    work)
      # 🚨 WORK CREDENTIALS 🚨
      name="Nathan Rydel"
      email="nathan.rydel@navys.ai"
      ;;
    personal)
      # 🚨 PERSONAL CREDENTIALS 🚨
      name="NR Devs"
      email="nrdevs@personal.email" # Placeholder
      ;;
    *)
      echo "Error: Invalid ID type. Usage: gitid [work|personal]" >&2
      return 1
      ;;
  esac

  # Execute the local config commands
  git config user.name "$name"
  git config user.email "$email"

  # Confirmation
  echo "✅ Local Git identity set to '$ID_TYPE'."
  git config --local --list | grep user.
}


# ==============================
# 7. Aliases (Core Development Focused)
# ==============================

# --- General System & Tools ---
alias cl='clear'
alias la=tree
alias cat=bat
alias v="$HOME/.nix-profile/bin/nvim" # Uses portable $HOME
alias http="xh"
alias ci='code-insiders'

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Eza (Modern ls replacement)
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# --- Python Development Aliases (Optimized for uv) ---
alias venv='uv venv'                 
alias act='source venv/bin/activate' 
alias uvi='uv pip install -r requirements.txt' 
alias uva='uv pip install'           

# --- TypeScript/Node Development Aliases ---
alias pni='pnpm install'           
alias pnir='pnpm install -r'       
alias pna='pnpm add'               
alias pnd='pnpm dev'               
alias npmr='npm run'               
alias npi='npm install'            
alias tfw='tsc --watch'            

# --- Go Development Aliases ---
alias gof='go fmt ./...'
alias got='go test ./...'
alias gwb='go build ./...'

# --- Docker ---
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# --- Git Productivity Aliases (Switch-Optimized) ---
alias g='git'
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

# Modern Git Commands
alias gsw='git switch'             
alias gsn='git switch -c'          
alias grs='git restore'            

# --- Zsh Configuration End ---
