# ------------------------------------------------------------------------------
# ZSH CONFIGURATION
#
# This file is loaded when an interactive Zsh session starts.
# It sources helper files and sets up the shell environment.
# ------------------------------------------------------------------------------

# ZShell settings for Rithm (Author: Joel Burton <joel@rithmschool.com>)
# Stop here if we're not an interactive shell (e.g., when running scripts)
if [ -z "$PS1" ]; then return; fi


# --- ZSH SETTINGS & OPTIONS ---
# General Zsh options and behaviors.

# Autoload and initialize completion.
# The '-u' flag suppresses the "insecure directories" prompt now that permissions
# have been fixed via 'compaudit | xargs chmod g-w,o-w'.
autoload -Uz compinit
compinit -u
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion.

setopt histverify              # Confirm history editing with a prompt.
setopt correct                 # Offer to correct misspelled commands.
setopt interactive_comments    # Allow comments (lines starting with '#') in the interactive shell.

# Bind a key to open the current command in an external editor (Ctrl-X, Ctrl-E).
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line


# --- SOURCING FILES ---
# Load external Zsh configuration files.

# Rithm School configuration files
source ~/.zprompt.zsh
source ~/.zrithm.zsh

# Bun shell completions
# This must be sourced *after* 'compinit' is run above for 'compdef' to be available.
[ -s "/Users/nrdevs/.bun/_bun" ] && source "/Users/nrdevs/.bun/_bun"


# --- PATH & ENVIRONMENT VARIABLES ---
# Set up necessary paths for various tools and applications.

# Golang
export PATH=$PATH:/Users/nrdevs/go/bin
export GOBIN=$HOME/go/bin

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/nrdevs/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# --- PROMPT CUSTOMIZATION (VCS_INFO) ---
# Configure the appearance of your shell prompt, including Git status.

autoload -Uz vcs_info
precmd() { vcs_info }
setopt prompt_subst

# Prompt format: [VCS Status][Path] [Return Code Status]
PROMPT='%F{75}${vcs_info_msg_0_}%f%2~ %(?.%F{208}%#%f.%K{208}%F{232}%#%f%k) '

# VCS Info styling
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{9}*%f'   # Unstaged changes in red
zstyle ':vcs_info:*' stagedstr '%F{178}+%f'   # Staged changes in gold/yellow
zstyle ':vcs_info:git:*' formats '%b%u%c '    # Format: [branch][unstaged][staged]

# Prepend username and machine if on SSH or different user.
if [[ $LOGNAME != $USERNAME ]] || [[ $SSH_CLIENT ]]; then
  PROMPT="%F{9}%n@%m%f $PROMPT"
fi


# --- ALIASES & FUNCTIONS ---
# Create convenient shortcuts and custom commands.

# Aliases for Rithm School (Node configuration)
alias node="node --experimental-detect-module"
export RITHM_NODE_FLAG="--experimental-detect-module"

# General aliases
alias ipython="ipython3"
# Excludes common development cruft from 'tree' output
alias tree="tree --noreport -CA -I '__pycache__|node_modules|venv'"
alias pstree="pstree -U"
alias ls="ls -F"
# Zipping files for submission, excluding common dev folders
alias zipsubmit='zip -x "*/__pycache__/*" -x "*/node_modules/*" -x "*/.git/*"'

# Fix the system clock on WSL
alias clockfix="sudo sntp -sS -4 pool.ntp.org"

# Use 'fd' or 'fdfind' consistently.
if ! which fdfind > /dev/null; then alias fdfind="fd"; fi

# Use 'bat' or 'batcat' consistently.
if ! which batcat > /dev/null; then alias batcat="bat"; fi

# A short convenience function for creating and entering a directory.
function take() {
  mkdir -p "$1" && cd "$1" || return
}

# Start/restart PostgreSQL on different operating systems.
# The missing closing braces/statements were added here to fix the parse error.
function pg_restart() {
  os="${(L)$(uname -a)}"
  if [[ -f /.dockerenv ]]; then
    echo "Running under docker; attempting 'sudo service postgresql start'"
    sudo service postgresql start
  fi
}
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
