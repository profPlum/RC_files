# IMPORTANT: if this is giving you weird errors remove all '\r' and '\t' characters

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

# IMPORTANT: if this is giving you weird errors remove all '\r' and '\t' characters
######################## ADDED FOR GW-ANALYSIS-DNN ########################
export GW_DNN_INSTALL_PATH="/root/gw-analysis-dnn"
export USER_EMAIL=ddeighan@umassd.edu
export GW_DNN_INSTALLED="TRUE"

# add scripts to path
export PATH="$GW_DNN_INSTALL_PATH/scripts:$PATH"
export PATH="$GW_DNN_INSTALL_PATH/scripts/bash_utils:$PATH"

# easy cd's that are made frequently
alias gw="cd $GW_DNN_INSTALL_PATH/scripts"
alias td="cd $GW_DNN_INSTALL_PATH/training_data"
alias cfg="cd $GW_DNN_INSTALL_PATH/configs"
alias cbcex="cd $GW_DNN_INSTALL_PATH/pycbc_data/example1"
alias p2="source activate python27-lal-new"

# doesn't work with virtual environments
# (do we really need these paths?)
# needed(?) for cudnn
export PATH="$HOME/anaconda3/bin:$PATH" # appears to be necessary for source activate ...
export PATH="$HOME/anaconda3:$PATH" # needed for windows anaconda
export CPATH="$HOME/anaconda3/include:$CPATH"
export LIBRARY_PATH="$HOME/anaconda3/lib$LIBRARY_PATH"
export LD_LIBRARY_PATH="$HOME/anaconda3/lib:$LD_LIBRARY_PATH"

# uncomment if you want to modify gwsurrogate or gwtools
#export PYTHONPATH="$HOME/gwtools/gwtools:$PYTHONPATH"
#export PYTHONPATH="$HOME/gwsurrogate/gwsurrogate:$PYTHONPATH"
#export PYTHONPATH="$HOME/gwsurrogate:$PYTHONPATH"
###########################################################################


export PATH="$HOME/bin:$PATH"

export NIX_ROOT_IN_WINDOWS='C:/Users/dwyer/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc/LocalState/rootfs'


# converts a linux path to the corresponding path in the global windows file system
to-win-path() {
    # default path is local dir
    if (( $# == 0 )); then
        ARG1=$(realpath '.')
    else
        ARG1=$(realpath $1)
    fi
    
    # if we are alread in the windows file system
    # then we just need to start the path with 'C:'
    # (this is also required because C: drive isn't
    # mounted in the actual files system)
    if [ "${ARG1:0:6}" = "/mnt/c" ]; then
        echo "C:${ARG1:6}" | tr '/' '\\'
    else
        echo $NIX_ROOT_IN_WINDOWS$ARG1 | tr '/' '\\'
    fi
}
export -f to-win-path

alias explorer_here='explorer.exe $(to-win-path)'
. /mnt/c/Users/dwyer/anaconda3-linux/etc/profile.d/conda.sh
conda activate
