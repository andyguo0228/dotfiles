# Personal zsh configuration with Oh My Zsh

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export EZA_CONFIG_DIR="$HOME/.config/eza"

# PLUGINS
plugins=(git
         zsh-autosuggestions
         zsh-syntax-highlighting
         you-should-use
         zsh-bat
)

# Load Oh My Zsh if available
if [ -d "$ZSH" ]; then
    source $ZSH/oh-my-zsh.sh
fi

# ALIASES
alias python="python3"
alias pip="pip3"
alias ls="eza -al --icons"
alias profile="micro ~/.zshrc"
alias reload="source ~/.zshrc"

# Additional useful aliases (keeping some from original config)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Directory navigation
alias ~='cd ~'
alias dt='cd ~/Desktop'
alias ws='cd /workspaces'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Enable syntax highlighting if available (fallback for non-Oh My Zsh systems)
if [ ! -d "$ZSH" ] && [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Enable auto-suggestions if available (fallback for non-Oh My Zsh systems)
if [ ! -d "$ZSH" ] && [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Oh My Posh prompt configuration
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/kushal.omp.json')"
fi

# Load local customizations if they exist
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi