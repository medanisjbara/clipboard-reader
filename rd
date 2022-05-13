#!/usr/bin/env bash

if test -n "$WAYLAND_DISPLAY"
then
  if command -v wl-paste &>/dev/null
  then
    clip="$(wl-paste)"
  else
    echo "wl-clipboard is not installed on wayland session"
    exit 1
  fi
elif test -n "$DISPLAY"
then
  if command -v xclip &>/dev/null
  then
    clip="$(xclip -o)"
  else
    echo "xclip is not installed on Xorg session"
    exit 1
  fi
elif command -v termux-clipboard-get &>/dev/null
then
    clip="$(termux-clipboard-get)"
fi

echo "$clip" | gtts-cli -f- | mpv -
