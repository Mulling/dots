#!/bin/bash

[[ $- != *i* ]] && return

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx 1&>/dev/null 2>&1
fi

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

if [[ ${EUID} == 0 ]] ; then
    export PS1='\[\033[0;31m\][\h \[\033[0;32m\]\W\[\033[0;31m\]]#\[\033[00m\] '
else
    export PS1='\[\033[1;30m\]`[ \j -gt 0 ] && echo [\j]\ `\[\033[1;32m\]\W »\[\033[00m\] '
fi

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
    exec tmux >/dev/null 2>&1
fi

alias cp='cp -i'
alias df='df -h'
alias feh='feh -.'
alias free='free -m'
alias grep='rg --no-heading'
alias la='ls -a'
alias ll='ls -lagh'
alias ls='ls --color=auto'
alias more='echo no more, use less'
alias mpv='mpv --hwdec=auto'
alias mu=mupdf
alias pingle='ping 8.8.4.4'
alias poweroff='loginctl poweroff'
alias reboot='loginctl reboot'
alias rm='rm -i'
alias vim=nvim

case $TERM in
    st-256color )
        PROMPT_COMMAND='echo -ne "\033]0;"${PWD/#$HOME/\~}" - ST\007" && stty susp undef'
        ;;
    * )
        PROMPT_COMMAND='stty susp undef'
        ;;
esac

xhost +local:root > /dev/null 2>&1

shopt -s \
    checkwinsize \
    expand_aliases \
    histappend

MAKEFLAGS="-j$(nproc)"
PS0='$(stty susp ^z)'

export \
    BROWSER=brave \
    EDITOR=nvim \
    HISTCONTROL=ignoreboth \
    HISTIGNORE='fg' \
    LESSHISTFILE=/dev/null \
    LFS=/mnt/lfs \
    MAKEFLAGS \
    MANPAGER="less -R -Dd+g -Dd+r" \
    PS0 \
    TERMINAL=st

# hack
bind '"\C-z":"fg\015"'

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "/home/mulling/.ghcup/env" ] && source "/home/mulling/.ghcup/env"
