#!/bin/bash
# IMPORTANT: if this is giving you weird errors remove all '' and '\t' characters

##### contains aliases, functions and optionally #####
##### path additions needed for all .bashrc files #####

##################### Misc: #######################

# TODO: put inside a .bash_profile (this is where all environment
# initialization is supposed to happen)
export USER_EMAIL=ddeighan@umassd.edu
#export PATH="$HOME/bin:$PATH"

# for gnome desktop shortcuts
# IMPORTANT: the app command doesn't have access to env variables or ~
# workaround if these are necessary is to do bash -c "BASH_CMD"
# alias mkapp-sc='gnome-desktop-item-edit ~/Desktop --create-new'

# super fast shortcuts for gw-analysis-dnn
alias gw='cd $GW_DNN_INSTALL_PATH/scripts'
alias td='cd $GW_DNN_INSTALL_PATH/training_data'
alias cfg='cd $GW_DNN_INSTALL_PATH/configs'

export UMD_IP="134.88.5.42"
alias mit_cloud="ssh ddeighan@txe1-login.mit.edu"
alias ghpcc="ssh dd13d@ghpcc06.umassrc.org"
alias umd="ssh ddeighan@$UMD_IP"

############## general purpose aliases: ##############

alias fcon='grep -n "<<"' # find git conflicts
alias mytop='top -u $USER'
alias sr='screen -r' # simple alternative to full function
alias fdif='git diff --no-index' # file diff (unrelated to git repos)
alias cp='cp -r'
alias scp='scp -r' # not necessary if you scping a directory then you should zip first...
#alias ln='ln -s' # symbolic links are best
alias cd..='cd ..'
alias rld='. ~/.bashrc'
alias hst='hostname'

# request interactive slurm shell
alias slurm-ishell='srun -N 2 --ntasks-per-node 2 --pty bash'
alias swatch-me='watch squeue -u $USER' # slurm watch me

##################### anaconda/pip: #####################

alias ca='conda activate' # conda activate
alias cda='conda deactivate' # conda deactivate, needs this twice or undefined behaviour 11/7/18
alias cie='conda env create -f' # conda import env
alias cee='conda env export --no-builds >' # conda export env
alias cre='conda env remove -n' # conda remove env
alias cce='conda create -n'
alias cud='conda update -n base conda' # conda up-date
alias pud='pip install --upgrade pip' # pip up-date

##################### Git: #####################

alias gch='git checkout HEAD --' # discard file changes
alias gp='git push'
alias ga='git add'
alias gl='git log'
alias gr='git reset'
# v idea is: similar to 'gist' & still longer to spell than gs
alias gst='git status'
alias gs='git stash'
alias gsa='git stash apply'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias git-frb="git fetch; git rebase" # when local branch is stale

# git view commit (changes)
git-vc() {
    git diff $1~1 $1
}
export -f git-vc

# git push new branch (for pushing new branches to origin)
git-pnb() {
    branch_name=$(git branch | grep \* | cut -d ' ' -f2)
    git push --set-upstream origin $branch_name
}
export -f git-pnb

# verified to work on 10/19/18, made sure that
# it doesn't continue if merging is required
git-rbp() {
    echo "stashing changes"
    stash_msg="$(git stash)"

    # we don't continue if merging needs to happen
    needs_merge=$(echo $stash_msg | grep -i 'needs merge')
    if [ "$needs_merge" != "" ]; then
        echo error: $stash_msg
        return 1 # this value needs to be positive
    fi

    # back 10 incase of rebases
    git reset --hard HEAD~10
    git pull

    # if there were local changes that
    # were stashed then reapply them
    no_local_changes=$(echo $stash_msg | grep -i 'No local changes to save')
    if [ "$no_local_changes" = "" ]; then
        echo "reapplying stash"
        git stash pop
    fi
}
export -f git-rbp

# diff with head
hdif() {
    if (( $# == 1 )); then
        ARG1=$1
    else
        ARG1=.
    fi
    git diff HEAD -- $ARG1
}
export -f hdif

############# General Purpose Functions: #############

# logs command output!
log() {
    # braces allow for piping of same output to multiple files
    {$@ 2> >(tee .err.log)} &> >(tee .out.log)
    echo; echo logged output to .err.log \& .out.log respectively
}
export -f log

zd() { # zip dir
    zip -r "$1".zip "$1"
}
export -f zd

# Easy extract, maybe unneeded?
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       rar x $1       ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# verified to work 10/19/18
mv-ln() {
	if (( $# < 2 )); then
		echo "usage: > mv-ln source destination"
		echo "moves something and links old path to destination"
		return 1
	fi

	if [ -d "$2" ]; then
		ARG2="$2"/$(basename "$1")
	else
		ARG2="$2"
	fi

	echo "moving \"$1\" to \"$2\""
	mv "$1" "$ARG2"
	ln -s "$ARG2" "$1"
	#ln "$ARG2" "$1" # alias expands to use -s
}
export -f mv-ln

############### Helpers: ###############

# where $1 is the real file name
# & $2 is the 'file id' (from shared url)
# verified to work (3/2/18)
download_drive_file() {
	wget "https://drive.google.com/uc?authuser=0&id=$2&export=download" -O $1
}

# *getopt counterpart* that gets
# remaining positional args by index
# USAGE: getarg 1 $@
getarg() {
    #no need to decrease because it is offset
    #by the positional index arg itself! lol
    index=$1 # $(( $1-1 ))

    echo ${@:$OPTIND+$index:1}
}
export -f getarg
# ^ based off this: https://stackoverflow.com/questions/11742996/shell-script-is-mixing-getopts-with-positional-parameters-possible

# note: doesn't work currently
# macro for help strings, must have defined 'usage' (help str)
alias if-h-then-usage='[ "$1" = "-h" ] && echo $usage'
