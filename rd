#!/usr/bin/env bash

help(){
    name="$(basename "$0")"
    echo "$name: $name [-h]"
    echo "  Reads your clipboard aloud"
}

get-clip(){
    if test -n "$WAYLAND_DISPLAY"
    then
      if command -v wl-paste &>/dev/null
      then
        wl-paste
      else
        echo "wl-clipboard is not installed on wayland session" 1>&2
        exit 1
      fi
    elif test -n "$DISPLAY"
    then
      if command -v xclip &>/dev/null
      then
        xclip -o
      else
        echo "xclip is not installed on Xorg session" 1>&2
        exit 1
      fi
    elif command -v termux-clipboard-get &>/dev/null
    then
        termux-clipboard-get
    fi
}

while getopts ":h" o; do
    case "${o}" in
        h)
            help
            exit
            ;;
        *)
            echo "Unknown option"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
get-clip | gtts-cli -f- | mpv -
