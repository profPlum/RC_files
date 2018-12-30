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
alias gw="cd $GW_DNN_INSTALL_PATH/scripts"
alias td="cd $GW_DNN_INSTALL_PATH/training_data"
alias cfg="cd $GW_DNN_INSTALL_PATH/configs"
 
####### general purpose aliases/functions: ####### 
 
alias fcon='grep -n ">>"' # find git conflicts
alias mytop='top -u $USER'
alias ca='source activate' # conda activate
alias cda='source deactivate; source deactivate' # conda deactivate, needs this twice or undefined behaviour 11/7/18
alias gch='git checkout HEAD -- ' # discard file changes
alias git-frb="git fetch; git rebase" # when local branch is stale
alias sr='screen -r' # simple alternative to full function
alias fdif='git diff --no-index' # file diff (unrelated to git repos)

zd() { # zip dir
    zip -r "$1".zip "$1"
}
export -f zd

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

# git push new branch (for pushing new branches to origin)
git-pnb()
{
    branch_name=$(git branch | grep \* | cut -d ' ' -f2)
    git push --set-upstream origin $branch_name
}
export -f git-pnb
 
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

########################################## 
 
# added by Anaconda3 installer 
#export PATH="$HOME/anaconda3/bin:$PATH" 
 
# for local executables/libs 
#export PATH="$HOME/bin:$PATH" 
#export LD_LIBRARY_PATH="$HOME/lib:$LD_LIBRARY_PATH" 
 
# for cuda (not needed in general) 
#export PATH="/usr/local/cuda-8.0/bin:$PATH" 
#export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH" 
#export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH" 
 
# for parallel models 
#export TF_MIN_GPU_MULTIPROCESSOR_COUNT=2 
