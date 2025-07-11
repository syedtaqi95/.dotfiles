# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Bash git prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi

# Cargo (Rust)
[ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"

# Starship prompt
[ -s "$HOME/.cargo/bin/starship" ] && eval "$(starship init bash)"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Poetry
export PATH="/home/syed/.local/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/syed/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Add Go to the path
if [ -d "/usr/local/go/bin" ]; then
    PATH="/usr/local/go/bin:$PATH"
fi

# Add GOPATH to path
[ -d "$(go env GOPATH)/bin" ] && PATH="$PATH:$(go env GOPATH)/bin"

# Neovim
export PATH="$PATH:/opt/nvim-linux64/bin"

export VISUAL=nvim
export EDITOR=$VISUAL

# Tab completions
# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB:menu-complete'
# And Shift-Tab should cycle backwards
bind '"\e[Z": menu-complete-backward'
# Display a list of the matching files
bind "set show-all-if-ambiguous on"
# Perform partial (common) completion on the first Tab press, only start
# cycling full results on the second Tab press (from bash version 5)
bind "set menu-complete-display-prefix on"

if [ -f "$HOME/.rover/env" ]; then
    source "$HOME/.rover/env"
fi

# Graphite
if command -v gt >/dev/null 2>&1; then
    ###-begin-gt-completions-###
    #
    # yargs command completion script
    #
    # Installation: gt completion >> ~/.bashrc
    #    or gt completion >> ~/.bash_profile on OSX.
    #
    _gt_yargs_completions() {
        local cur_word args type_list

        cur_word="${COMP_WORDS[COMP_CWORD]}"
        args=("${COMP_WORDS[@]}")

        # ask yargs to generate completions.
        type_list=$(gt --get-yargs-completions "${args[@]}")

        COMPREPLY=($(compgen -W "${type_list}" -- ${cur_word}))

        # if no match was found, fall back to filename completion
        if [ ${#COMPREPLY[@]} -eq 0 ]; then
            COMPREPLY=()
        fi

        return 0
    }

    complete -o bashdefault -o default -F _gt_yargs_completions gt
    ###-end-gt-completions-###
fi

# uv bash completions (if installed)
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion bash)"
fi

# uvx bash completions (if installed)
if command -v uvx >/dev/null 2>&1; then
    eval "$(uvx --generate-shell-completion bash)"
fi

# tmux magic

tmux() {
  # only intercept "tmux new" or "tmux new-session"
  if [[ "$1" == "new" || "$1" == "new-session" ]]; then
    local subcmd="$1"; shift

    # derive session name from current dir
    local session="${PWD##*/}"

    # if user passed -s or --session-name anywhere, just forward
    for arg in "$@"; do
      if [[ "$arg" == "-s" || "$arg" == "--session-name" ]]; then
        command tmux "$subcmd" "$@"
        return
      fi
    done

    # otherwise attach or create
    if command tmux has-session -t "$session" 2>/dev/null; then
      command tmux attach-session -t "$session"
    else
      command tmux new-session -s "$session" "$@"
    fi
  else
    # any other tmux command → passthrough
    command tmux "$@"
  fi
}

