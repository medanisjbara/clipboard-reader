#!/usr/bin/env bash

help(){
    name="$(basename "$0")"
    echo "$name: $name [-h] [-g]"
    echo "  Reads your clipboard aloud"
    echo "  OPTIONS"
    echo "      -h      Show this help message"
    echo "      -g      If the content of the clipboard is a URL, the script will"
    echo "              grab and read the associated output"
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

grab(){
    if ! w3m "$1"
    then
        echo "w3m failed with a non 0 exit status" 1>&2
    fi
}

clip="$(get-clip)"
while getopts "hg" o; do
    case "${o}" in
        h)
            help
            exit
            ;;
        g)
            grab_flag=true
            ;;
        *)
            echo "An error occured" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if test -n "$grab_flag"
then
    if echo "$clip" | grep -q "^http"
    then
        content="$(grab "$clip")"
        if [ -n "$content" ]
        then
            echo "$content" | gtts-cli -f- | mpv -
        else
            echo "Couldn't grab page content"
        fi
    else
        echo "$clip is not a valid URL"
    fi
else
    echo "$clip" | gtts-cli -f- | mpv -
fi
