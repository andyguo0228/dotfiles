#!/bin/bash

# Backup script for existing dotfiles
# Run this before installing to save your current configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backup directory
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}Creating backup directory: $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

# Files to backup
FILES=(
    ".zshrc"
    ".bashrc"
    ".gitconfig"
    ".dircolors"
    ".profile"
    ".bash_profile"
    ".zsh_history"
    ".bash_history"
)

# Backup files if they exist
for file in "${FILES[@]}"; do
    if [ -f "$HOME/$file" ]; then
        echo -e "${YELLOW}Backing up $file${NC}"
        cp "$HOME/$file" "$BACKUP_DIR/"
    fi
done

# Backup directories if they exist
DIRS=(
    ".ssh"
    ".config/git"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$HOME/$dir" ]; then
        echo -e "${YELLOW}Backing up directory $dir${NC}"
        cp -r "$HOME/$dir" "$BACKUP_DIR/"
    fi
done

echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${GREEN}Your files have been backed up to: $BACKUP_DIR${NC}"
echo -e "${YELLOW}You can restore any file by copying it back from the backup directory.${NC}"