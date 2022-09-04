#!/usr/bin/env bash

cfg_file="$HOME/.config/$0.config"

help(){
  name="$(basename "$0")"
  echo "$name"
  echo "  Reads your clipboard aloud"
}
# Functions needed for gen_config
## Outputs the first existing command from the commands given as arguments
get_from(){
  for cmd in "$@"; do
    if command -v "$(echo "$cmd"|cut -d ' ' -f 1)" &>/dev/null; then
      echo "$cmd"
      break
    fi 
  done; unset cmd
}

# Outputs the command given as third argument if the two variables $1 and $2 are non zero strings
get_if(){
  if [ -n "$1" ]; then
    echo "$1"
  elif [ -n "$2" ]; then
    if command -v "$(echo "$3"|cut -d ' ' -f 1)" &>/dev/null; then
      echo "$3"
    fi
  fi
}

# Generates configuration
gen_config(){
  # Text to speech engine
  conf_tts="$(get_from 'gtts-cli -f-' 'espeak-ng --stdout' 'espeak --stdout')"

  # Clipboad grabber
  conf_clip_cmd="$(get_if "$conf_clip_cmd" "$use_stdin" stdin_grab")"
  conf_clip_cmd="$(get_if "$conf_clip_cmd" "$WAYLAND_DISPLAY" "wl-paste")"
  conf_clip_cmd="$(get_if "$conf_clip_cmd" "$DISPLAY" "xclip -o -selection c")"
  conf_clip_cmd="$(get_if "$conf_clip_cmd" "$TERMUX_VERSION" "termux-clipboard-get")"

  # Player
  conf_player="$(get_from 'mpv -')"

  # Running a check
  for conf in tts clip_cmd player; do
    if test -z "$(eval "echo \$conf_$conf")"; then
      echo "Seems like $conf is not set. Please install an appropriate command."
      echo "If you believe you have an appropriate command but $(basename "$0") is not"
      echo "detecting it please open an issue"
      echo
    fi
  done; unset conf
  export conf_tts conf_clip_cmd conf_player
}

# Gets the input from from stdin
stdin_grab(){
  if [ -n "$grab_flag" ]; then
    read -rp link:\  link; echo "$link"
  else
    cat
  fi
}

# The actual script
if [ -f "$cfg_file" ]; then
  # shellcheck source=/dev/null
  . "$cfg_file"
else
  gen_config
fi


for conf in clip_cmd tts player; do
  if [ -z  "$(eval "echo \$$conf")" ];then
    eval "$conf='$(eval "echo \$conf_$conf")'"
    if [ -z "$(eval "echo \$$conf")" ]; then
      echo "Cannot find $conf."
      echo "check $0 -h"
    fi 
  fi
done

# Feed clipboard content to a text to speech engine and feed its output to the prefered player
$clip_cmd | $tts | $player
