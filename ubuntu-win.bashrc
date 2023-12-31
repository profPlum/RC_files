# IMPORTANT: if this is giving you weird errors remove all '\r' and '\t' characters

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
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
    xterm-color|*-256color) color_prompt=yes;;
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

## manually disable, it's distracting
#color_prompt=no

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[0;35m\]\u@\h\[\033[00m\]:\[\033[1;33m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.


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


################################## MY STUFF ########################################
# IMPORTANT: if this is giving you weird errors remove all '\r' and '\t' characters

export GW_DNN_INSTALL_PATH=~/Documents/Work/GW-Project/gw-analysis-dnn
export USER_EMAIL=ddeighan@umassd.edu
export PATH="$HOME/bin:$PATH"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

alias conda='conda.exe'
alias python='python.exe'

#conda init
#cat /mnt/c/Users/dwyer/Miniconda3/etc/profile.d/conda.sh | tr '\r' ' ' > /mnt/c/Users/dwyer/Miniconda3/etc/profile.d/conda.sh
#. /mnt/c/Users/dwyer/Miniconda3/etc/profile.d/conda.sh
#conda activate

#export NIX_ROOT_IN_WINDOWS='C:/Users/dwyer/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc/LocalState/rootfs'
export NIX_ROOT_IN_WIN='C:/Users/dwyer/AppData/Local/Packages/CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc/LocalState/rootfs'
# ^ depends on the version...

# converts a linux path to the corresponding path in the global windows file system
to-win() {
    if (( $# != 1 )); then
        echo "usage: to-win unix-path > win-path"
        return 1
    fi

	ARG1=$(realpath $1)
	
    #if we are already in the windows file system
    #then we just need to start the path with 'C:'
    if [ "${ARG1:0:6}" = "/mnt/c" ]; then
		ARG1="C:${ARG1:6}"
    else
        ARG1=$NIX_ROOT_IN_WINDOWS$ARG1
    fi

	echo $ARG1 | tr '/' '\\' # return new path (translated)
}
export -f to-win

# converts win paths to nix paths
to-nix() {
    if (( $# == 1 )) && [ "$1" != '-h' ]; then
	    ARG1="$1"
    elif [ "$1" = '-nc' ]; then
        ARG1="$2"
        if [ "${ARG1:0:2}" = "C:" ]; then
            ARG1="/mnt/c${ARG1:2}" # start with linux-style C drive
        fi
    else
        echo "usage: to-nix [-nc] 'win-path' (must be quoted) > nix-path"
        echo "note: -nc converts the 'C:' to unix style as well..."
        return 1
    fi

	echo $ARG1 | tr '\\' '/' # return new path (translated)
}
export -f to-nix

alias exp='explorer.exe $(to-win .)'

# verified to work
get_path_depth() {
	counted_char=/
	res="${1//[^$counted_char]}"
	echo "${#res}"
	# technically should have a -1 because root has a '/'
}

# verified to work 3/26/19
# finds relative path with symbolic links in home dir
relpath-sym() {
	#usage='relpath-sym unsimplified-path > simplified_path'
    #if-h-then-usage

    simplest_path=$(realpath "$1")
	shortest_len=$(get_path_depth "$simplest_path")
	#echo path: $simplest_path
    #echo len: $shortest_len
    for item in $(ls ~); do
		if [ -d ~/$item ]; then
		    #echo item: $HOME/$item
            item="$item"/$(realpath --relative-to "$HOME/$item" "$1")
            item="${item%/.}" # deletes a trailing '/.' if it exists...
			#echo rel-item: $item
            len=$(get_path_depth "$item")
            #echo rel-item len: $len
            if (( len < shortest_len )); then
                #echo shorter!
                simplest_path=$HOME/"$item"
                shortest_len=$len
            fi
        fi
	done
	echo $simplest_path
}
export -f relpath-sym

# cd to simplifed directory (relative to home links)
if ! [ $(pwd) = ~ ]; then    
    cd "$(relpath-sym .)"
fi

# added by Anaconda3 2018.12 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/home/dwyer/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/home/dwyer/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/dwyer/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/home/dwyer/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
alias paper="cd /home/dwyer/GW-Project/DNN-high-mass/paper"
