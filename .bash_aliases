#!/bin/bash
# IMPORTANT: if this is giving you weird errors remove all '' and '\t' characters

##### contains aliases, functions and optionally #####
##### path additions needed for all .bashrc files #####

##################### Misc: #######################

# TODO: put inside a .bash_profile (this is where all environment
# initialization is supposed to happen)
export USER_EMAIL=ddeighan@umassd.edu
#export PATH="$HOME/bin:$PATH"

export UMD_IP="134.88.5.42"
alias umd="ssh ddeighan@$UMD_IP"

############## general purpose aliases: ##############

## redefinitions:
# v Can't follow links rn, it would need to be `find $@ . -name $1`
alias find='find . -name'
alias clr='clear'
alias hst='history'
alias host='hostname'
alias watch='watch -n 1' # this checks status, which never takes too much cpu
alias cp='cp -r'
alias scp='scp -r' # usually if you're scping a directory you should zip first...

# makes default ping target google DNS server
ping() {
    if (($# < 2)); then
        ping 8.8.8.8
    else
        ping $@
    fi
}
alias ln='ln -s' # symbolic links are best, that's *why* they can point to dirs
# NOTE: not an alias but remember: `killall` over~ `pkill -9`

## unique commands:
alias mytop='top -u $USER'
alias sr='screen -r' # simple alternative to full function
alias sls='screen -ls'
alias fdif='git diff --no-index' # file diff (unrelated to git repos)
alias cd..='cd ..'
alias rld='. ~/.bashrc'

mkcd() {
  mkdir $1
  cd $1
}

# request interactive slurm shell
# -N := num nodes, -n := num cores
slurm-ishell() {
  srun $@ --pty bash
}
alias swatch-me='watch squeue -u $USER' # slurm watch me

##################### anaconda/pip: #####################

alias ci='conda install'
alias cui='conda uninstall'
alias ca='conda activate' # conda activate
alias cda='conda deactivate' # conda deactivate, needs this twice or undefined behaviour 11/7/18
alias cie='conda env create -f' # conda import env
alias cee='conda env export --no-builds >' # conda export env
alias cre='conda env remove -n' # conda remove env
alias cce='conda create -n' # conda create env 
alias cle='conda env list' # conda list env
alias cre='conda env remove -n' # conda remove env
alias cud='conda update -n base conda' # conda up-date
alias pud='pip install --upgrade pip' # pip up-date

##################### Git: #####################

alias gf='git fetch'
alias grb='git rebase'
alias gm='git merge'
alias gp='git push'
alias gpl='git pull'
ga() { # no args = update
    cmd="git add"
    if (($#==0)); then
        cmd="$cmd -u"
    fi
    $cmd $@
}
alias gl='git log'
alias gr='git reset'
# v Idea is: similar to 'gist' & still longer to spell than gs
alias gst='git status'
alias gs='git stash'
alias gsa='git stash apply'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'

alias gpf='git push -f' # unnecessary?
alias gca='git commit --amend'

alias gfrb="git fetch; git rebase" # when local branch is stale
alias fcon='grep -n ">>>"' # find git conflicts
alias hdif='git diff HEAD --' # diff with head (with no arg acts on entire repo)

# discard file/repo changes
# (with no args acts on entire repo)
gch() {
  if (( $# < 1 )); then
    git reset --hard
  else
    git checkout HEAD -- $@
  fi
}

# git view commit (changes)
gvc() {
    git diff $1~1 $1;
}

# git push new branch (for pushing new branches to origin)
gpnb() {
    branch_name=$(git branch | grep \* | cut -d ' ' -f2)
    git push --set-upstream origin $branch_name
}

# verified to work on 10/19/18, made sure that
# it doesn't continue if merging is required
grbp() {
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

############# General Purpose Functions: #############

# logs command output!
log() {
    # braces allow for piping of same output to multiple files
    { $@ 2> >(tee .err.log); } &> >(tee .out.log);
    echo; echo logged output to .err.log \& .out.log respectively;
}

zd() { # zip dir
    zip -r "$1".zip "$1"
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
  ln "$ARG2" "$1" # alias expands to use -s
  #ln -s "$ARG2" "$1"
}

############### Helpers: ###############

# tested on mac (verified to work May 1, 2020)
get_access_date() {
  d=$(stat "$1" | sed -n 's/^Access: [A-z]* \(.*\)$/\1/p')
  date -jf '%b %d %H:%M:%S %y' "$d" +%s
}

under_score_name() {
    name=$(echo "$1" | tr ' ' '_')
    mv "$1" $name
}

# where $1 is the real file name
# & $2 shared file link (from google)
# verified to work (1/4/19)
download_drive_file() {
  id=$(echo "$2" | sed 's/.*id=//')
	wget "https://drive.google.com/uc?authuser=0&id=${id}&export=download" -O $1
}

# note: doesn't work currently
# macro for help strings, must have defined 'usage' (help str)
alias if-h-then-usage='[ "$1" = "-h" ] && echo $usage'
