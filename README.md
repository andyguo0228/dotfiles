# Personal Dotfiles

A simple dotfiles repository for setting up personalized development environments, especially in GitHub Codespaces.

## Features

- **Oh My Zsh configuration** with carefully selected plugins for enhanced productivity
- **Modern terminal tools** including eza (better ls) and micro editor
- **Beautiful prompt** with Oh My Posh and Kushal theme
- **Enhanced shell experience** with auto-suggestions, syntax highlighting, and useful reminders
- **Git configuration** with useful aliases and VS Code integration
- **Directory colors** for better file type visualization
- **Automated installation** with comprehensive dependency management
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
- **Oh My Zsh** framework with essential plugins:
  - `git` - Git aliases and status information
  - `zsh-autosuggestions` - Command suggestions based on history
  - `zsh-syntax-highlighting` - Real-time syntax highlighting
  - `you-should-use` - Reminds you to use aliases you've defined
  - `zsh-bat` - Better cat command with syntax highlighting
- **Oh My Posh** prompt with beautiful Kushal theme
- **Modern aliases** using eza for enhanced file listing
- Useful shortcuts for Python development and file editing
- Directory navigation and git workflow shortcuts

### Git Configuration (.gitconfig)
- VS Code as default editor and merge tool
- Useful git aliases
- Pretty log formatting
- Color configuration
- Modern git defaults

### Directory Colors (.dircolors)
- Custom color scheme for file type visualization
- Enhanced file type color coding
- Archive and media file highlighting

### Scripts
- `install.sh` - Comprehensive installation script with dependency management
- `backup.sh` - Backup existing configurations before installation

### Modern Development Tools
- **eza** - Modern replacement for ls with icons and better formatting
- **micro** - User-friendly terminal text editor
- **oh-my-posh** - Cross-platform prompt engine for beautiful shell prompts

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
- `ls` - Enhanced file listing with eza (icons and colors)
- `ll` - Detailed file listing
- `python` / `pip` - Shortcuts to python3/pip3
- `profile` - Quick edit of .zshrc with micro editor
- `reload` - Reload shell configuration
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