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

# Install zsh plugins if available
echo -e "${YELLOW}Installing zsh enhancements...${NC}"
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y zsh-syntax-highlighting zsh-autosuggestions 2>/dev/null || true
fi

# Create symlinks for dotfiles
echo -e "${GREEN}Setting up dotfiles...${NC}"
create_symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
create_symlink "$SCRIPT_DIR/.dircolors" "$HOME/.dircolors"

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}Setting zsh as default shell...${NC}"
    if command -v chsh &> /dev/null; then
        chsh -s "$(which zsh)"
    else
        echo -e "${RED}Cannot change shell automatically. Run: chsh -s $(which zsh)${NC}"
    fi
fi

# Update dircolors
if [ -f "$HOME/.dircolors" ]; then
    echo -e "${GREEN}Updating dircolors...${NC}"
    eval "$(dircolors ~/.dircolors)"
fi

echo -e "${GREEN}Dotfiles installation complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
echo -e "${YELLOW}Don't forget to update your git config with your name and email:${NC}"
echo -e "  git config --global user.name 'Your Name'"
echo -e "  git config --global user.email 'your.email@example.com'"