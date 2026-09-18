# .zshrc - Kali-Land Interactive Zsh Configuration

# Environment setup
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt AUTO_CD

# Use Starship prompt config if present
if [ -f "$HOME/.config/starship/starship.toml" ]; then
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
fi

# Initialize Starship prompt engine
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# Load Zsh plugins (Autosuggestions & Syntax Highlighting)
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Useful Aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias cls='clear'
alias doctor='~/.local/bin/doctor.sh || ./bootstrap/doctor.sh'

# Launch Fastfetch header on interactive login shell if available
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null && [ -z "${FASTFETCH_SHOWN:-}" ]; then
    export FASTFETCH_SHOWN=1
    fastfetch --logo kali
fi
