#!/usr/bin/env bash

help(){
    name="$(basename "$0")"
    echo "$name: $name [-h] [-g] [-l lang]"
    echo "  Reads your clipboard aloud"
    echo "  OPTIONS"
    echo "      -h      Show this help message"
    echo "      -g      If the content of the clipboard is a URL, the script will"
    echo "              grab and read the associated output"
    echo "      -l      language to use, example: en, fr .."
    echo "      -e      edit what's being read before reading it"
    echo "      -f      file to read or stdin if \"-\" is provided"
    echo "      -u      unicode characters only, and remove \\xa0"
    echo "              use this if you're experiencing errors"
}

get-clip(){
    if test -n "$file_flag"
    then
        if [ "$target_file" = "-" ]
        then
            get-stdin
        else
            handle "$target_file"
        fi
    elif test -n "$WAYLAND_DISPLAY"
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
        xclip -o -selection c
      else
        echo "xclip is not installed on Xorg session" 1>&2
        exit 1
      fi
    elif command -v termux-clipboard-get &>/dev/null
    then
        termux-clipboard-get
    else
        get-stdin
    fi
}

get-stdin(){
    if test -n "$grab_flag"
    then
        echo -n "Link: " >&2
        read -r url
        echo "$url"
    else
        cat
    fi
}

handle(){
    if [[ "$1" = *.epub ]]
    then
        if command -v epub2txt >&/dev/null
        then
            epub2txt "$1"
        else
            echo "epub2txt is not installed, cannot extract text" 1>&2
        fi
    elif [[ "$1" = *.pdf ]]
    then
        less "$1"
    else
        echo "Can't recognize file format, press \"n\" if the player doesn't start automatically" 1>&2
        less "$1"
    fi
}

grab(){
    if command -v w3m &>/dev/null
    then
        if ! w3m "$1"
        then
            echo "w3m failed with a non 0 exit status" 1>&2
        fi
    else
        curl "$1" > /tmp/temporary.html
        less /tmp/temporary.html
    fi
}

gtts(){
    if test -n "$lang"; then
        gtts-cli -l "$lang" "$@"
    else
        gtts-cli "$@"
    fi
} 

while getopts "hgl:ef:u" o; do
    case "${o}" in
        h)
            help
            exit
            ;;
        g)
            grab_flag=true
            ;;
        l)
            lang="$OPTARG"
            ;;
        e)
            edit_flag=true
            ;;
        f)
            file_flag=true
            target_file="$OPTARG"
            ;;
        u)
            utf8_flag=true
            ;;
        *)
            echo "An error occured" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

clip="$(get-clip)"

if test -n "$grab_flag"
then
    if echo "$clip" | grep -q "^http"
    then
        content="$(grab "$clip")"
        if [ -z "$content" ]
        then
            echo "Couldn't grab page content" 1>&2
        fi
    else
        echo "$clip is not a valid URL" 1>&2
    fi
else
    content="$clip"
fi

if test -n "$utf8_flag"
then
    if ! command -v bbe &>/dev/null
    then
        echo "bbe is not installed, please install it to do binary replacement properly" 1>&2
        echo "attempting to rely only on charset conversion, this might not be optimal" 1>&2
        bbe(){
            cat
        }
    fi
    cleaned="$(echo "$content" | bbe -e 's/\xa0//g')"
    content="$(echo "$cleaned" | iconv -f utf-8 -t utf-8 -c -)"
fi

if test -n "$edit_flag"
then
    if command -v vipe &>/dev/null
    then
        edited="$(echo "$content" | vipe)"
        content="$edited"
    else
        echo "vipe is not installed, Cannot edit" 1>&2
    fi
fi

echo "$content" | gtts -f- | mpv -
