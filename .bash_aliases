#!/bin/bash
# IMPORTANT: if this is giving you weird errors remove all '\r' and '\t' characters
 
##### contains aliases, functions and optionally ##### 
 
##### path additions needed for all .bashrc files ##### 
# to use do mv .bash_aliases.txt .bash_aliases; then 
# if not present add this to your .bashrc file: 
# if [ -f ~/.bash_aliases ]; then
    # . ~/.bash_aliases
# fi
 
# super fast shortcuts for gw-analysis-dnn
alias gw='cd $GW_DNN_INSTALL_PATH/scripts'
alias td='cd $GW_DNN_INSTALL_PATH/training_data'
alias cfg='cd $GW_DNN_INSTALL_PATH/configs'

# TODO: put inside a .bash_profile (this is where all environment
# initialization is supposed to happen)
export USER_EMAIL=ddeighan@umassd.edu
export PATH="$HOME/bin:$PATH"
 
############## general purpose aliases: ##############
 
alias fcon='grep -n ">>"' # find git conflicts
alias mytop='top -u $USER'
alias gch='git checkout HEAD --' # discard file changes
alias git-frb="git fetch; git rebase" # when local branch is stale
alias sr='screen -r' # simple alternative to full function
alias fdif='git diff --no-index' # file diff (unrelated to git repos)
alias cp='cp -r'
alias scp='scp -r'
alias ln='ln -s' # symbolic links are best

################# anaconda: ##################### 

alias ca='conda activate' # conda activate
alias cda='conda deactivate' # conda deactivate, needs this twice or undefined behaviour 11/7/18
alias cie='conda env create -f' # conda import env
alias cee='conda env export' # conda export env

##################### Ubuntu: #######################

# for gnome desktop shortcuts
# IMPORTANT: the app command doesn't have access to env variables or ~
# workaround if these are necessary is to do bash -c "BASH_CMD"
alias mkapp-sc='gnome-desktop-item-edit ~/Desktop --create-new'

# this makes ctrl+arrow skip over words...
# doesn't go in inputrc for some reason: https://askubuntu.com/questions/162247/why-does-ctrl-left-arrow-not-skip-words/288530
# NOTE: git bash needs it in inputrc so it is there aswell...
bind '"\e[1;5D" backward-word'
bind '"\e[1;5C" forward-word'

############# General Purpose Functions: #############

# note: doesn't work currently
# macro for help strings, must have defined 'usage' (help str)
alias if-h-then-usage='if [ "$1" = "-h" ]; then; echo $usage; fi'

# git view commit changes
git-vcc() {
    git diff $1~1 $1
}
export -f git-vcc

zd() { # zip dir
    zip -r "$1".zip "$1"
}
export -f zd

# Easy extract
extract () {
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
    
    git reset --hard HEAD~1
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
	#ln -s "$ARG2" "$1"
	ln "$ARG2" "$1" # alias expands to use -s
}
export -f mv-ln

# verified to work, 10/31/18 <- bugs found since
# screen reattach, never makes recursive screens 
# sr() {
    ## if this works the function ends here 
    # out="$(screen -r $@)"
 
    ## if we aren't attached to a screen & none exist then make one 
    ## =~ means equals regex expression (only available in [[]]) 
    # if [[ "$out" =~ "^There is no screen to be resumed" ]]; then
        # screen
    # fi
 
    # quotes to perserve newlines 
    # echo "$out" 
# } 
# export -f sr 

# for parallel models 
#export TF_MIN_GPU_MULTIPROCESSOR_COUNT=2 
