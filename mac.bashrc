#!/bin/bash
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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

## If this is an xterm set the title to user@host:dir
#icase "$TERM" in xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;; *)
#    ;;
#esac
####################################################################

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

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

sed() { # turn off mac OS BS related to sed
    if [[ $1 == -i ]]; then
        shift
        /usr/bin/sed -i'' $@
    else
        /usr/bin/sed "$@"
    fi
}

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

############# MY STUFF #############

export PATH="/Users/dwyerdeighan/miniforge3/condabin:$PATH"
export PATH="$PATH:/Users/dwyerdeighan/Library/Python/3.8/bin"

alias stat='stat -x'
alias pip='python3 -m pip'
alias python='python3'
alias dt='cd ~/Desktop'
alias dl='cd ~/Downloads'
alias docs='cd ~/Documents'

###################### MSBAI STUFF ######################

# AirForce HPC settings:
# NOTE: AFRL HPC password is webpasswordI (with an ! for special, & I as incremented index for 'password updates') e.g. X!password1, X!password2, etc...
# NOTE: to access kshell is not necessary, just use `init_kerberos; [warhawk/blackbird/mustang]` (verified to work 10/6/22)
export KRB5_TRACE=/dev/stdout
export KRB5_CONFIG=/etc/krb5.conf
alias init_kerberos='pkinit dfire; kinit dfire'
alias warhawk='ssh dfire@warhawk.afrl.hpc.mil # login with kerberized ssh'
alias mustang='ssh dfire@mustang.afrl.hpc.mil # login with kerberized ssh'
alias blackbird='ssh dfire@blackbird.afrl.hpc.mil # login with kerberized ssh'
#export PATH="/usr/local/krb5/bin:$PATH"  # for kerberos (Airforce HPC) 
#:/usr/local/ossh/bin:$PATH" # for kerberos (Airforce HPC)

GUI_HOST="deep-learning-12c85r1a100-dwyer-0-vm"
#SCP_HOST='ddeighan@54.80.143.98'
#GPU_HOST="ludwig-training-k80-6-of-10"
#MYGPU_HOST="ludwig-training-k80-dwyer-20220202"
#
#GCLOUD_HOST=$MYGPU_HOST
#GCLOUD_USER=$USER # not necessarily true always
#start-gcloud() {
#    echo $'NOTE: Once started use: \'ssh GCLOUD_HOST\' to connect!\n'
#    
#    # we need to store this cmd as a string because apparently aliases produce strange errors in this context
#    start_gcloud_cmd="gcloud beta compute instances start $GCLOUD_HOST"
#    $start_gcloud_cmd # we run it redundantly here to show output & to ensure it really is started (it often takes 2 or more tries...)
#    IP="$($start_gcloud_cmd 2>&1 | grep -i 'external IP')" # isolate line that shows external IP address
#    IP="${IP##*IP is }" # removes: "[...] External IP is " to isolate IP
#
#    # This is entire host configuration for GCLOUD_HOST, EXCEPT the IP address which is updated dynamically 
#    GCLOUD_HOST_CFG_STR=$'Host GCLOUD_HOST\n\tIdentityFile ~/.ssh/google_compute_engine\n\tUser '"$GCLOUD_USER"$'\n\tGSSAPIAuthentication no\n\tGSSAPIDelegateCredentials yes'
#    echo "$GCLOUD_HOST_CFG_STR" > ~/.ssh/gcloud_host_cfg
#    echo $'\tHostName '"$IP" >> ~/.ssh/gcloud_host_cfg
#    # This host config is loading with an Include statement in main ssh 'config'
#
#    # Install gcloud_host_cfg into main .ssh config (if needed) 
#    #include_cmd="$(grep "Include gcloud_host_cfg" ~/.ssh/config)"
#    #[ "$include_cmd"="" ] & echo "Include gcloud_host_cfg" >> ~/.ssh/config
#}
#
#alias ssh-gc='ssh GCLOUD_HOST -L 8888:127.0.0.1:8888 -L 6006:127.0.0.1:6006'
#
# Your personal GPU server in case Anton keeps using the 6-of-10 ludwig server
#alias start-mygpu='gcloud compute instances start "$MYGPU_HOST" --zone "us-central1-c" --project "automl-training-env-poc"'
#alias mygpu='gcloud compute ssh "$MYGPU_HOST" --zone "us-central1-c" --project "automl-training-env-poc" -- -L 6007:127.0.0.1:6007 -L 8888:127.0.0.1:8888 -X'
#alias scp-mygpu='gcloud compute scp --zone "us-central1-c" --project "automl-training-env-poc"'
#
## start-gui & start-gpu have been trimmed down likely same could be done for gpu & gui commands below
#alias gui='gcloud compute ssh "$GUI_HOST" --zone "us-central1-c" --project "software-experience-capture"  -- -E /dev/null -L 8888:127.0.0.1:8888 -L 5901:localhost:5901 -X'
#alias gpu='gcloud compute ssh "$GPU_HOST" --zone "us-central1-c" --project "automl-training-env-poc" -- -E /dev/null -L 8888:127.0.0.1:8888 -L 6006:127.0.0.1:6006'
##alias start-gui-vnc='gui "export DISPLAY=:1; vncserver -geometry 1920x1080 -xstartup ~/.vnc/xstartup :1 -passwd ~/.vnc/passwd"' # this is in bashrc so just use `gui`
#alias start-gpu='gcloud compute instances start "$GPU_HOST" --zone "us-central1-c" --project "automl-training-env-poc"' # start then dispatch vnc server commmand (then connect via mac screenshare)
#alias scp-gpu='gcloud compute scp --zone "us-central1-c" --project "automl-training-env-poc"'
#alias start-gui='gcloud compute instances start "$GUI_HOST" --zone "us-central1-c" --project "software-experience-capture"' #; start-gui-vnc'
#alias scp-gui='gcloud compute scp --zone "us-central1-c" --project "software-experience-capture"'
#
#GPU8_HOST='ludwig-training-k80x8'
#alias gpu8='gcloud compute ssh --zone "us-central1-c" "$GPU8_HOST" --project "automl-training-env-poc" --ssh-flag="-L 8888:127.0.0.1:8888 -L 8889:127.0.0.1:8889"'
#alias start-gpu8='gcloud compute instances start --zone "us-central1-c" "$GPU8_HOST" --project "automl-training-env-poc"'
#alias scp-gpu8='gcloud compute scp --zone "us-central1-c" --project "automl-training-env-poc"'
#
OLCF_FRONTIER='frontier.olcf.ornl.gov'
OLCF_SUMMIT='summit.olcf.ornl.gov'
OLCF_ANDES='andes.ccs.ornl.gov'
OLCF_HOME='home.ccs.ornl.gov'
OLCF_DTN='dtn.ccs.ornl.gov'

alias frontier="ssh dwyerfire@$OLCF_FRONTIER"
alias summit="ssh dwyerfire@$OLCF_SUMMIT"
alias andes="ssh dwyerfire@$OLCF_ANDES" # andes is for pre/post processing
alias dtn_olcf="ssh dwyerfire@$OLCF_DTN" # data transfer nodes
alias home_olcf="ssh dwyerfire@$OLCF_HOME" # Run Tmux/Screen Sessions

# NOTE: this node has nothing to do with AHAB... just a mistaken name
AWS_HOST='ubuntu@dwyer-train-gpu.defitrade.guru'
alias aws="ssh $AWS_HOST -L 8888:127.0.0.1:8888 -L 6006:127.0.0.1:6006 -X"

####################### UB STUFF: #######################

alias pp='cd ~/Desktop/post-processing/chrest/' # Post-Processing
alias ctdf='cd ~/CLionProjects/ablate/ablateInputs/chemTabDiffusionFlame' # ChemTab Inputs
alias ablate='cd ~/CLionProjects/ablate'

clang-format-inplace() {
    clang-format $1 > "$1.formatted"
    mv "$1.formatted" $1
}

FAWKES_HOST='dwyerdei@fawkes.cse.buffalo.edu'
BU_HOST='dwyerdei@catesby.cse.buffalo.edu'
CCR_HOST='dwyerdei@vortex.ccr.buffalo.edu'
#CCR_HOST='dwyerdei@vortex-future.ccr.buffalo.edu' # TODO: switch to this eventually... right now doesn't support interactive debugging

ALL_LISTENING_PORTS='-L 7860:127.0.0.1:7860 -L 6006:127.0.0.1:6006 -L 6007:127.0.0.1:6007 -L 6008:127.0.0.1:6008 -L 8888:127.0.0.1:8888 -L 8889:127.0.0.1:8889 -L 8890:127.0.0.1:8890 -L 8891:127.0.0.1:8891 -L 8892:127.0.0.1:8892 -L 8893:127.0.0.1:8893'

alias fawkes="ssh $FAWKES_HOST -X $ALL_LISTENING_PORTS -L 8080:127.0.0.1:8080" 
alias bu="ssh $BU_HOST -X $ALL_LISTENING_PORTS" 
alias ccr="ssh $CCR_HOST -X" # -L 6006:127.0.0.1:6006" # -L 8888:127.0.0.1:8888 -L 8889:127.0.0.1:8889 -L 8890:127.0.0.1:8890"

alias cclean='rm -rf CMakeCache.txt CMakeFiles _deps Makefile'
alias date='gdate'

#########################################################
# UPDATE: Actually turns out bracketed paste mode is really important & seems to be working now 10/23/23
#printf "\e[?2004l" # turns off bracketed paste mode which is broken nonsense
eval $(ssh-agent -s)
# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
. `which env_parallel.bash`
