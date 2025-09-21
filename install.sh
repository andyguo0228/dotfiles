#!/bin/bash

# Dotfiles installer script
# This script sets up your dotfiles in a new environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Starting dotfiles installation...${NC}"

# Function to backup existing files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo -e "${YELLOW}Backing up existing $file to $file.backup${NC}"
        cp "$file" "$file.backup"
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        echo -e "${YELLOW}Removing existing symlink: $target${NC}"
        rm "$target"
    elif [ -f "$target" ]; then
        backup_file "$target"
        rm "$target"
    fi
    
    echo -e "${GREEN}Creating symlink: $target -> $source${NC}"
    ln -s "$source" "$target"
}

# Install zsh if not present
if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}Installing zsh...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v yum &> /dev/null; then
        sudo yum install -y zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        echo -e "${RED}Cannot install zsh automatically. Please install it manually.${NC}"
        exit 1
    fi
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh My Zsh plugins
echo -e "${YELLOW}Installing Oh My Zsh plugins...${NC}"

# Install zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting  
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install you-should-use
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use
fi

# Install zsh-bat
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-bat" ]; then
    git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-bat
fi

# Install additional tools
echo -e "${YELLOW}Installing additional tools...${NC}"

# Install eza (modern replacement for ls)
if ! command -v eza &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        # For Ubuntu/Debian - install from official repository
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update && sudo apt install -y eza 2>/dev/null || {
            # Fallback: try installing via cargo if available
            if command -v cargo &> /dev/null; then
                cargo install eza
            else
                echo -e "${RED}Could not install eza. You may need to install it manually.${NC}"
            fi
        }
    elif command -v brew &> /dev/null; then
        brew install eza
    elif command -v yum &> /dev/null; then
        # For RHEL/CentOS/Fedora, try cargo or manual installation
        if command -v cargo &> /dev/null; then
            cargo install eza
        else
            echo -e "${RED}Could not install eza automatically. Please install Rust/Cargo first or install eza manually.${NC}"
        fi
    fi
fi

# Install micro editor
if ! command -v micro &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y micro 2>/dev/null || {
            # Fallback: install via curl
            curl https://getmic.ro | bash
            sudo mv micro /usr/local/bin/
        }
    elif command -v brew &> /dev/null; then
        brew install micro
    elif command -v yum &> /dev/null; then
        sudo yum install -y micro 2>/dev/null || {
            # Fallback: install via curl
            curl https://getmic.ro | bash
            sudo mv micro /usr/local/bin/
        }
    else
        # Generic installation via curl
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/ 2>/dev/null || mv micro ~/bin/ 2>/dev/null || echo -e "${RED}Could not install micro. Please install it manually.${NC}"
    fi
fi

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        # Install via curl for Linux
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    elif command -v brew &> /dev/null; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
        # Generic installation
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh 2>/dev/null || {
            wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O ~/bin/oh-my-posh 2>/dev/null || {
                echo -e "${RED}Could not install oh-my-posh. Please install it manually.${NC}"
            }
        }
        sudo chmod +x /usr/local/bin/oh-my-posh 2>/dev/null || chmod +x ~/bin/oh-my-posh 2>/dev/null
    fi
fi

# Create eza config directory
echo -e "${YELLOW}Setting up eza configuration...${NC}"
mkdir -p "$HOME/.config/eza"

# Install fallback zsh plugins for systems without Oh My Zsh
echo -e "${YELLOW}Installing fallback zsh enhancements...${NC}"
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y zsh-syntax-highlighting zsh-autosuggestions 2>/dev/null || true
fi

# Create symlinks for dotfiles
echo -e "${GREEN}Setting up dotfiles...${NC}"
create_symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
create_symlink "$SCRIPT_DIR/.dircolors" "$HOME/.dircolors"

# Change default shell to zsh if not already set
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}Your current shell is $SHELL${NC}"
    echo -e "${YELLOW}To make zsh your default shell, run:${NC}"
    echo -e "  chsh -s $(which zsh)"
    echo -e "${YELLOW}This is handled automatically by devcontainer.json in Codespaces${NC}"
fi

# Update dircolors
if [ -f "$HOME/.dircolors" ]; then
    echo -e "${GREEN}Updating dircolors...${NC}"
    eval "$(dircolors ~/.dircolors)"
fi

echo -e "${GREEN}Dotfiles installation complete!${NC}"
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}Installed features:${NC}"
echo -e "${GREEN}- Oh My Zsh with custom plugins${NC}"
echo -e "${GREEN}- Modern file listing with eza${NC}"
echo -e "${GREEN}- Micro text editor${NC}"
echo -e "${GREEN}- Oh My Posh prompt with Kushal theme${NC}"
echo -e "${GREEN}- Enhanced shell aliases and functions${NC}"
echo -e "${GREEN}===================================${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
echo -e "${YELLOW}Don't forget to update your git config with your name and email:${NC}"
echo -e "  git config --global user.name 'Your Name'"
echo -e "  git config --global user.email 'your.email@example.com'"