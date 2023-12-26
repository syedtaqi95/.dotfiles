#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

create_symlink() {
    local source=$1
    local target=$2

    if [ ! -f "$source" ]; then
        echo "Source file does not exist: $source"
        exit 1
    fi

    if [ -e "$target" ]; then
        echo "Target already exists, backing up: $target.bak"
        mv "$target" "${target}.bak"
    fi

    mkdir -p "$(dirname "$target")"
    ln -nfs "$source" "$target"
    echo "Symlink created: $target -> $source"

    if [ -e "${target}.bak" ]; then
        rm "${target}.bak"
    fi

}

# Neovim
echo "Setting up Neovim..."
SOURCE="$SCRIPT_DIR/init.lua"
TARGET="$HOME/.config/nvim/init.lua"
create_symlink "$SOURCE" "$TARGET"

# Tmux
echo
echo "Setting up tmux..."
SOURCE="$SCRIPT_DIR/.tmux.conf"
TARGET="$HOME/.tmux.conf"
create_symlink "$SOURCE" "$TARGET"

# Git config
echo
echo "Applying git config..."
SOURCE="$SCRIPT_DIR/.gitconfig"
TARGET="$HOME/.gitconfig"
create_symlink "$SOURCE" "$TARGET"





