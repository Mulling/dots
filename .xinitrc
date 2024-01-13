#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

[ -f "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"

pulseaudio --start &
slstatus &

export \
    PATH="$PATH:$HOME/dots/scripts/:$HOME/.local/bin" \
    CMAKE_EXPORT_COMPILE_COMMANDS=1 \
    _JAVA_AWT_WM_NONREPARENTING=1 # James Gosling at it again

[ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" 2>/dev/null

exec dwm >/dev/null 2>&1
