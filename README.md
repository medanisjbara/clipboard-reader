# Clipboard Reader
## Description
A simple script that reads aloud your clipboard
## Dependencies
The dependency list is constantly changing, and since I am personally a fan of "Working with what I have" I am trying to make my script more and more undependent from any dependencies.  

In other words, I would like to make it use some sort of a fallback mechanism if something is not available. If `w3m` isn't installed, the script will use `curl` and `less` to get the content of the page.  

And so on and so forth. This makes it easy for someone who just wants to copy the script and just starts using it, as well as for people who wants to use it to it's full potential by integrating it with keyboard shortcuts on their WM or DE. (I personally think it gives a good boost to productivity).  

I am mainly doing this as a challange for myself (someone who is learning how to do bash scripting).  

With that said, This makes it hard for me to layout dependencies the right way, since there are some which are nessesairy, some which are optional, and some which can be replaced with other dependencies that serves the same functionality.  

### Required dependencies
*So to use the script you need to have at least one package in each of the following categories installed and working:*
#### Text to speech engine
* [gTTS](https://github.com/pndurette/gTTS)
```
pip install gtts
```
#### Clipboard interface
* [xclip](https://github.com/astrand/xclip) if you are on xorg
* [wl-clipboard](https://github.com/bugaevc/wl-clipboard) if you are on wayland
* termux-clipboard-get from [termux-api](https://github.com/termux/termux-api) if you are on android.

### Optional dependencies (for extra features)
*Those are the dependencies that you will want to have if you want more out of this script:*
#### Pager (for web pages conversion to plain text)
*To be able to use the `-g` option which allows you to read a page by just copying it's url.*
* [w3m](https://github.com/tats/w3m)
#### Editor
*if you want to use the `-e` option to edit before reading.*
* [vipe](https://linux.die.net/man/1/vipe) is for now the implementation that I am using. It is part of `moreutils` which is available on all distros (as far as I know).
// I am planning (in the future) to make use of the `EDITOR` environment variable instead, since it seems like most people do not use `vipe`.
#### Binary Block Editor
Also known as [bbe](https://github.com/hdorio/bbe), See issue [#1](https://github.com/medanisjbara/clipboard-reader/issues/1). Not neccesairely needed for `-u` but recommended.

## Installation
```
git clone https://github.com/medanisjbara/clipboard-reader/
cd clipboard-reader
sudo install rd /usr/local/bin
```
## Usage
Use `rd -h` to get the following help for all the options.
```
rd: rd [-h] [-g] [-l lang]
  Reads your clipboard aloud
  OPTIONS
      -h      Show this help message
      -g      If the content of the clipboard is a URL, the script will
              grab and read the associated output
      -l      language to use, example: en, fr ..
      -e      edit what's being read before reading it
      -u      unicode characters only, and remove \xa0
              use this if you're experiencing errors
```
To start using the script, just copy a paragraph and execute the script. It will grab whatever is on your clipboard and read it aloud. Other options might include.
* `-u` to fix issues that gTTS might have with some characters.
* `-l` if what you're reading is not english (this gets passed as it is to gTTS)
* `-e` to edit before reading (requires `vipe`)
* `-g` to grab the content of a URL, this is useful when you're reading a webpage (just copy the url and execute the script)
* `-h` if you forget any of the above.
