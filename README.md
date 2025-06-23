# Personal Dotfiles

A simple dotfiles repository for setting up personalized development environments, especially in GitHub Codespaces.

## Features

- **Zsh configuration** with custom prompt, aliases, and history settings
- **Git configuration** with useful aliases and VS Code integration
- **Directory colors** for better file type visualization
- **Automated installation** with backup functionality
- **GitHub Codespaces integration** via devcontainer configuration

## Quick Start

### For GitHub Codespaces

1. Fork this repository
2. Create a new Codespace from your fork
3. The environment will be automatically configured via the devcontainer

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# (Optional) Backup existing dotfiles
./backup.sh

# Install dotfiles
./install.sh
```

## What's Included

### Shell Configuration (.zshrc)
- Custom prompt with colors
- Useful aliases for common commands
- Git aliases for faster workflow
- Directory navigation shortcuts
- History configuration with deduplication
- Auto-completion and syntax highlighting support

### Git Configuration (.gitconfig)
- VS Code as default editor and merge tool
- Useful git aliases
- Pretty log formatting
- Color configuration
- Modern git defaults

### Directory Colors (.dircolors)
- Custom color scheme for `ls` command
- File type color coding
- Archive and media file highlighting

### Scripts
- `install.sh` - Main installation script with dependency management
- `backup.sh` - Backup existing configurations before installation

### Devcontainer Configuration
- Automatic zsh setup in Codespaces
- Pre-installed development tools
- VS Code extensions and settings
- Post-creation command to run installation

## Customization

### Personal Git Configuration
After installation, update your git configuration:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Local Customizations
Create a `~/.zshrc.local` file for environment-specific customizations that won't be overwritten by updates.

## File Structure

```
.
├── .devcontainer/
│   └── devcontainer.json    # Codespaces configuration
├── .zshrc                   # Zsh shell configuration
├── .gitconfig              # Git configuration
├── .dircolors              # Directory color configuration
├── install.sh              # Installation script
├── backup.sh               # Backup script
└── README.md               # This file
```

## Usage Tips

### Useful Aliases Included
- `ll` - Detailed file listing
- `gs` - Git status
- `gc` - Git commit
- `..` - Go up one directory
- `ws` - Go to workspaces directory

### Custom Functions
- `mkcd directory` - Create and change to directory

## Contributing

Feel free to fork this repository and customize it for your own needs. This is designed to be a starting point for your personal dotfiles collection.

## License

This project is open source and available under the [MIT License](LICENSE).