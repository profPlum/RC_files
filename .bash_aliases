#!/bin/bash
# IMPORTANT: if this is giving you weird errors remove all '' and '\t' characters

##### Contains aliases, functions and optionally #####
##### path additions needed for all .bashrc files. #####

if [[ "$(which env_parallel 2>/dev/null)" ]]; then
    . `which env_parallel.bash` # setup env_parallel command
    env_parallel --session # must come first for proper usage! (so it knows what env to exclude)
    #alias parallel='env_parallel' # it's the same except a tad slower & exports the environment!! Totally worth it!
fi

##################### Redefinitions: #########################

# NOTE: not an alias but remember: `killall` over~ `pkill -9`
# v Can't follow links rn, it would need to be `find $@ . -name $1`
alias find='find . -name'
alias bc='bc -l' # loads math library & enables floating point arithemtic
alias clr='clear'
alias hst='history'
#alias host='hostname' # actually host is already a useful DNS command, keep it as-is
alias duh='du -shc *' # simple command shows how much space your directories take up
alias watch='watch -n 1' # this checks status, which never takes too much cpu
alias cp='cp -r'
alias scp='scp -r' # usually if you're scping a directory you should zip first...
alias rsync='rsync -r --update --compress --progress' # rsync seems to be better than scp, and it works without compression
alias ls='ls -ltrh --color=yes' # sort results with most recently modified first!
alias lsz='du -hs * .??*' # gives you accurate measurements of size for **local directories** (& files), ls only does files
alias grep='grep -ni'
alias ln='ln -s' # symbolic links are best, that's *why* they can point to dirs
alias ssh='ssh -q'
alias vi='vim'
unalias cd 2> /dev/null
cdv() { cd "$1"; ls; }
alias cd='cdv'
alias unexpand='unexpand -t 4'
alias expand='expand -t 4'
alias tail='tail -n 30'
alias head='head -n 30'
N_CPUs="$(getconf _NPROCESSORS_ONLN)" # gets number of cpus on mac & linux!
alias xargs="xargs -n1 -P$(getconf _NPROCESSORS_ONLN)" # xargs is useful but new amap is likely more useful 
# ^ NOTE: -n1 means 1 arg per new call (quote aware), -PN means use N parallel processes,
# also you can override any defaults just by specifying them again!
# GOTCHA: apparently xargs doesn't work by default with bash functions?? Use new amap instead! 

# IMPORTANT: entirety of amap_f could be replaced by this one-liner!!
amap() { \xargs -L1 -P $(getconf _NPROCESSORS_ONLN) bash -c "$1" _; }
# It requires passing one string command argument and passing inputs line by line
# For strings which should be split up you could do echo $ARGS | xargs -n$N_PER | amap_f 'cmd1 $1 | cmd2 $2 # etc...'

# Verified to work (on CCR): 5/23/24
# NOTE: new version of amap which also inherets the entire shell-scope from the calling shell!
amap_env() { (export $(compgen -v); \xargs -L1 -P $(getconf _NPROCESSORS_ONLN) bash -c "$(declare -f);""$1" _) ; }
# GOTCHA: actually this should be depreciated in favor of env_parallel which is a project that does everything you want and much more!

# IMPORTANT: amap is the most GENERAL method for launch multi-node jobs on arbitrary job scheduler systems
# Example xargs usage (1-node usage):
# echo 1 2 3 | xargs -n1 echo (-n1 is optional since baked into alias)
# Example amap multi-node usage (on slurm):
# echo 1 2 3 | xargs -n1 srun -n 1 python some_script.py (-n1 is optional since baked into alias)

# simplify tar to zip/unzip interface
tar-zd() {
    if ! [[ -d "$1" ]]; then
        echo Requires directory argument! >&2
        return 1
    fi
    tar -cvaf "$1".tar.gz "$1"/*
}
tar-unzip() {
    if ! [[ "$1" =~ .*\.tar\.gz ]]; then
        echo Requires *.tar.gz file! >&2
        return 1
    fi
    tar -xvf "$1"
}

##################### Anaconda/Pip: #####################

# use drop-in replacement when appropriate!
if [ "$(which mamba 2>/dev/null)" ]; then
    alias conda='mamba'
    echo Note: we are aliasing conda=mamba b/c mamba exists. >&2
else
    echo Warning: mamba not found!! >&2
fi

alias ci='conda install'
alias cui='conda uninstall'
alias ca='conda activate' # conda activate
alias cda='conda deactivate' # conda deactivate, needs this twice or undefined behaviour 11/7/18
alias cie='conda env create -f' # conda import env
alias cee='conda env export --no-builds >' # conda export env
alias cre='conda env remove -n' # conda remove env
alias cce='conda create -n' # conda create env 
#alias ccp='conda create --name myclone --clone myenv
# ^ remember to use --clone NAME when you want to clone one

alias cle='conda env list' # conda list env
alias cre='conda env remove -n' # conda remove env
alias cud='conda update -n base conda' # conda up-date
alias pud='pip install --upgrade pip' # pip up-date

##################### Git: #####################

git config --global rerere.enabled 1
git config --global rerere.autoupdate true
[ $(which vim) ] && git config --global core.editor "vim"
git config --global core.filemode false # prevents "file mode changes" from clogging git status

# Very useful! Clears all meta data & output bloat that accumulates in jupyter notebooks
alias clean_jupyter='jupyter nbconvert --ClearOutputPreprocessor.enabled=True --ClearMetadataPreprocessor.enabled=True --to=notebook --inplace'

# removes extra white space from auto-indent to avoid annoying git modifications
flat_ws() {
    sed -Ei'' 's|\s+$||g' "$@"
}
flat_code_ws() {
    #NOTE: the leading backlash is needed to avoid using the alias
    echo flattening whitespace
    \find . -regextype posix-extended -type f -regex ".*\.(c|cpp|h|py|sh|R|yaml)" | amap_env 'flat_ws $1' 
    echo done!
}

alias gf='git fetch'
alias grb='git rebase'
alias gm='git merge'
alias gp='git push'
alias gpl='git pull'
ga() { # no args = update
    cmd="git add"
    #flat_code_ws # flatten whitespace
    if (($#==0)); then
        cmd="$cmd -u"
    fi
    $cmd $@ # git add
}
alias gl='git log'
alias gr='git reset'
# v Idea is: similar to 'gist' & still longer to spell than gs
alias gst='git status'
alias gs='git stash'
alias gsa='git stash apply'
#alias gc='git commit'
gc() {
    root="$(git rev-parse --show-toplevel)"
    \cd "$root"
    flat_ws $(git diff --name-only --cached | \grep -E ".*\.(c|cpp|h|py|sh|R|yaml)$")
    git add $(git diff --name-only --cached)    
    \cd -
    git commit
}

alias gco='git checkout'
alias gb='git branch'

alias gpf='git push -f' # unnecessary?
alias gca='git commit --amend'

alias gfrb="git fetch; git rebase" # when local branch is stale
alias fcon='grep -n ">>>>"' # find git conflicts
alias hdif='git diff HEAD --' # diff with head (with no arg acts on entire repo)
# IMPORTANT: hdif > stash.patch, create a PATCH FILE from local changes! --> then do: `git apply stash.patch` 

# discard file/repo changes
# (with no args acts on entire repo)
gch() {
    if (( $# < 1 )); then
        #git reset --hard
        echo Not supported to wipe an entire directory, use gs \(git stash\) instead
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
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo branch name: $branch_name
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

############# General Purpose & Unique Commands: #############
##############################################################

alias kill_kids='pkill -P $$'
alias jupyter2py='jupyter nbconvert --to script' #e.g. jupyter2py notebook.ipynb # (--> produces notebook.py)
alias rm_bad_lns='\find . -xtype l -delete' # deletes broken links

# Example usage: at_night log . some_job.sh
# Verified to work 7/4/24
export _NIGHT_TIME='today 23:00' # or 'tomorrow 00:00' (midnight)
alias at_night='sleep $(( $(date +%s -d "$_NIGHT_TIME") - $( date +%s ) )); '

alias no_numbers="sed -E 's|[0-9]+||g'"
alias unique="no_numbers | sort | uniq"

# drops all but most recent N files/folders in a directory
keep_last_N_files() {
    dir=$1
    n_keep=$2

    echo dir=$dir, N=$n_keep, pwd=$(pwd)

    files=$(/bin/ls -t $dir)
    n_total=$(echo $files | wc -w)
    n_drop=$(( n_total-n_keep ))

    echo counted $n_total existing files!
    echo dropping $n_drop old files

    if ((n_total<=n_keep)); then
        echo nothing to do... exiting
        return 0 || exit 0
    fi
    
    \cd $dir
    files=$(echo $files | tr ' ' '\n' | tail -n $n_drop)
    echo files to drop:
    echo $files | tr ' ' '\n'

    # remove all old files 
    /bin/rm -rf $files 2> /dev/null
    \cd - > /dev/null
}

alias stop='return 0 || exit 0'
assert() { eval [[ "$@" ]] && echo Assert is False!! : "$@" && exit 2; } # requires subshell execution!
export -f assert

# NOTE: where $1 is the real file name, and $2 is the id from the url
download_drive_file_by_id() { wget --no-check-certificate "https://drive.google.com/uc?authuser=0&id=$2&export=download&confirm=yes" -O $1; }
under_score_name() { name=$(echo "$1" | tr ' ' '_'); mv "$1" $name; }

# verified to work 6/9/22, NOTE: replaces all occurrences of $2 with $3 in folder: $1
repl_strs_in_dir() { \find "$1" -type f | xargs sed -i'' "s|$2|$3|g"; }
repl() { # verified to work 9/6/23, EXAMPLE: repl old new *.txt
    cmd="s|$1|$2|g"
    shift; shift
    sed -i'' "$cmd" $@ #TODO: maybe add backup suffix?
    # NOTE: using sed -i'' is most general/compatible way to use sed across mac & linux
}

# simplified sed, takes $1 as pattern & $2 as replace
sd() { xargs -0 echo | sed "s|$1|$2|g"; }

# IMPORTANT: xargs is the most GENERAL method for launch multi-node jobs on arbitrary job scheduler systems
# Example xargs usage (1-node usage):
# echo 1 2 3 | xargs echo
# Example amap multi-node usage (on slurm):
# echo 1 2 3 | xargs srun -n 1 python some_script.py

mb() { mv "$1" "${1}.${RANDOM}.bak"; } # mb=make backup! (moves original file)

# NOTE: `reset` is also useful for fixing undefined state
alias rld='. ~/.bashrc'
alias pdb='python -m pdb'
alias jn='jupyter notebook --no-browser'
alias jl='jupyter lab --no-browser'
alias mytop='top -u $USER'
alias sr='screen -r' # simple alternative to full function
alias sls='screen -ls'
alias fdif='git diff --no-index' # file diff (unrelated to git repos)
alias cd..='cd ..'
mkcd() { mkdir $1; cd $1; }
zd() { zip -r "$1".zip "$1"; } # zip dir

# request interactive slurm shell
# -N := num nodes, -n := num cores
slurm-ishell() { srun $@ --pty bash; }
alias swatch-me="watch \"squeue --me --format='%.10i %.9P %.40j %.8T %.10M %.9l %.6D %.18R'\""
# slurm watch me + better formatting (tested better formatting on CCR 10/11/23)

# logs command output!
log() {
    # braces allow for piping of same output to multiple files
    { "$@" 2> >(tee .err.log); } &> >(tee .out.log);
    echo; echo logged output to .err.log \& .out.log respectively;
}

# verified to work 6/10/22
swap() {
    if [ $# -lt 2 ]; then
        echo ERROR: you must pass 2 fn args to swap!
        return 1
    fi
    tmp_fn="$1-$RANDOM"
    mv "$1" "$tmp_fn"
    mv "$2" "$1"
    mv "$tmp_fn" "$2"
    echo Swapped: "$1 <==> $2"
}

# verified to work 10/19/18
mv-ln() {
    if (( $# != 2 )); then
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
    /bin/ln -s "$ARG2" "$1"
}

# tested on mac (verified to work May 1, 2020)
get_access_date() {
    d=$(stat "$1" | sed -n 's/^Access: [A-z]* \(.*\)$/\1/p')
    date -jf '%b %d %H:%M:%S %y' "$d" +%s
}

under_score_name() { name=$(echo "$1" | tr ' ' '_'); mv "$1" $name; }

# split input args (string) on characters (e.g. 12 --> 1 2)
str_split() { echo "$@" | fold -w1 | xargs -n 5000 echo; } 
str_concat() { echo "$@" | sed -r 's| ||g'; }

# Verified to work: 11/10/23
# This function builds a regex pattern which matches 
# integers between 0-$1 (inclusive/exclusive like python range())
_regex_number_range() { x=$(seq $1 $2 | tr '\n' '|'); echo "(?<![0-9eE.-])(?:${x%%|$2|})(?![0-9eE.])"; }
regex_number_range() {
    start=0
    if (($#==2)); then
        start=$1; shift
    fi
    echo $(_regex_number_range $start $1)
}


rev() { # like R function, reverses order of arguments
    for (( i=$#;i>0;i-- )); do
        echo "${!i}"
    done
}

# simple tool much like in R
# but 0 padding between repeats,
# e.g. `echo rep 50 =` --> =======...
rep0() {
    i=0; _N=$1; shift
    output=
    while ((i++ < _N)); do
        output="$output""$@"
    done
    echo "$output"
}
 
# simple tool much like in R
# e.g. `map rand_numeric_perturb $(rep 1000 2)`,
# echo $(rep 5 "'1 2 3'") --> '1 2 3' '1 2 3'...
rep() {
    _N=$1; shift;
    ret=$(rep0 $((_N-1)) "'$@' ")"'$@'"
    echo "$ret"
}

############## CLI arg perturb: ##############
# NOTE: This is a bash adaptation of rand_CLI_arg_perturb.py.
# Idea is to use on python CLI call for rand Hparam search on HPC.
# Then use some other logging functionality + R to find best Hparams.

# Adds slight pertubation to numeric CLI arg e.g.
# "... --some-hparam=$(rand_numeric_perturb 3.14) ..."
# Verified to work on 10/30/23 (with ks.test & old/new systems)
NUM_PERTURB_SPREAD=0.3 # Awesome property: as long as 0<NUM_PERTURB_SPREAD<1 can't convert 0 < float < 1 --> float > 1
rand_numeric_perturb() {
    N=4096 # granularity of random coefficient
    scale="scale=16;" # precision of floating point ops
    min=$(echo "$scale l($1)*(1-$NUM_PERTURB_SPREAD)" | bc -l)
    max=$(echo "$scale l($1)*(1+$NUM_PERTURB_SPREAD)" | bc -l)
    runif="($((RANDOM % N))/$N)" # random coefficient between 0 & 1
    bc_cmd="$scale e(($max - $min) * $runif + $min)"
    perturbed_number=$(echo "$bc_cmd" | bc -l)
 
    # truncate to int if original argument is also an int
    ! [[ "$1" =~ \. ]] && perturbed_number="${perturbed_number%%.*}"
    echo $perturbed_number
} # P.S. NOTE: final form of perturbed arg is arg^(NUM_PERTURB_SPREAD*(2*(R~U(0,1))-1)+1)

# Very useful for True/False & various other categorical args
# e.g. cmd --env=$(rand_factor_sample $env_names), or
# $(rand_factor_sample --enable-flag) --> --enable-flag or nothing!
rand_factor_sample() {
    N=$#; (( $# < 2 && N++ ))
    factor_array=( "$@" )
    sample_id=$(($RANDOM % $N))
    echo ${factor_array[$sample_id]}
}

# Verified to work 10/31/23
# Automatically perturbs given (valid) CLI args, e.g. for Hparam search!
# IMPORTANT: works on everything EXCEPT abitrary categorial arugments,
# those must be handled manually with rand_factor_sample() (above)
auto_cli_perturb() {
    auto_numeric_perturb() { sed -r 's/(--[A-z0-9-]+)[ =]([0-9.]+)/\1="$(rand_numeric_perturb \2)"/g'; }
    _auto_flag_perturb() { sed -r 's/(--[A-z0-9-]+)( --|$)/"$(rand_factor_sample \1)"\2/g'; }
    auto_flag_perturb() { _auto_flag_perturb | _auto_flag_perturb; } # We x2 apply auto_flag_perturb b/c regex doesn't allow overlapping matches!!
    auto_bool_perturb() { sed -r 's/(True|False)/"$(rand_factor_sample True False)"/g'; }
    perturbed_cli=$(echo "$@" | auto_numeric_perturb | auto_flag_perturb | auto_bool_perturb)
    perturbed_cli="$(eval echo \"$perturbed_cli\")" # verified to handle string properly!! 10/31/23
    echo prev CLI args: "$@" >&2
    echo new CLI args: "$perturbed_cli" >&2
    echo "$perturbed_cli"
} # P.S. Very nice property: as long as 0<NUM_PERTURB_SPREAD<1 can't convert 0 < float < 1 --> float > 1 

# Important for subshells/job scripts!
export -f auto_cli_perturb rand_factor_sample rand_numeric_perturb

################ Deprecated: ################

#amap() { # NOTE: like xargs you pass the inputs as stdin, but specify static cmd in front!
#    [[ $N_PER ]] || N_PER=1 # you can pass N_PER env var to set `xargs -n` (i.e. num args one cmd consumes)
#    export -f $1 2> /dev/null # export it (Dynamically!) if it's a function
#    bash_cmd="$@ "'"$@"' # apparently storing cmd in a var is needed to pass multiple args to cmd
#    xargs -n $N_PER -P $(getconf _NPROCESSORS_ONLN) bash -c "$bash_cmd" _
#    # also we set -P to the number of cores avaiable on the computer
#} # PS: apparenlty amap parallel & blocking! perfect

### TODO: replace amap once stable!
## NOTE: N_PER inferred automatically!
## A variant of amap that requires cmd is passed as string with $1 $2 etc... var placement args
## Example usage: echo1() { echo "$@"; }; seq 1 4 | amap_f 'echo1 1st: $1 2nd: $2' # str cmd is essential!! 
#amap_f() { # NOTE: like xargs you pass the inputs as stdin, but specify static cmd in front!
#    #[[ $N_PER ]] || N_PER=1 # you can pass N_PER env var to set `xargs -n` (i.e. num args one cmd consumes)
#    N_PER=$(echo "$1" | \grep -o -E '\$[0-9]+' | wc -l) # count position arg uses
#    export -f $1 2> /dev/null # export it (Dynamically!) if it's a function
#    bash_cmd="$@ " #'"$@"' # apparently storing cmd in a var is needed to pass multiple args to cmd
#    if ((!$N_PER)); then 
#        N_PER=1
#        bash_cmd="$@ "'"$1"'
#    fi
#    xargs -L 1 -P $(getconf _NPROCESSORS_ONLN) bash -c "$bash_cmd" _
#    #xargs -n $N_PER -P $(getconf _NPROCESSORS_ONLN) bash -c "$bash_cmd" _
#    # also we set -P to the number of cores avaiable on the computer
#} # PS: apparenlty amap parallel & blocking! perfect


## Verified to work 4/18/24
#amap_f() {
#    args=($1)
#    echo ${args[0]}
#    export -f ${args[0]}
#    func_source="func() { $1; }"
#    echo func_source: $func_source
#    eval "func() { $1; }"       
#    amap func
#}

#stop() {
#    echo '############################ NOTE: ##################################'
#    echo It seems impossible to make a true "stop command" \(all your options failed\),
#    echo instead do this: type "return 0 || exit 0" in your script.
#    echo Or for even more simplicity consider just using "return 0",
#    echo since usually that will work \(in just about all cases except mpirun\).
#    echo '#####################################################################'
#    sleep 300
#}

### NOTE: much easier than a bash loop!! e.g.: map echo 1 2 3 
#map_() { cmd="$1"; shift; for x in "$@"; do eval "$cmd $x"; done; }
#map_tuple() { eval map_ "$@"; } # experimental version of map that should be able to inline subshell expansion e.g.: map_tuple echo $(rep 2 '1 2') --> (matrix) "1 2"\n"1 2"
##map() { map_tuple "$@" } # map_tuple idea taken from here (they claim its dangerous): https://superuser.com/questions/1529226/get-bash-to-respect-quotes-when-word-splitting-subshell-output#
###  TODO: if it works add asynchronous version!


#amap() { # asynchronous version of map!
#    echo "MPIRUN_CMD: $MPIRUN_CMD"
#    echo "MPIRUN_CMD can be e.g. 'srun -n 1' (slurm multi-node execution), or '' (empty, default 1 node execution)"
#    echo ALSO, recall: a common use case is to 'wait' after this call, for all processes to finish
#    cmd="$MPIRUN_CMD $1"; shift; for x in "$@"; do eval "$cmd $x" & done
#} # NOTE: we used to put the for loop in a subshell why is that?? is it still important?

#export -f amap map map_tuple

#STOP="eval 'return 0 || exit 0'"
#export STOP

# covers sub-shell & local shell (e.g. source & . test.sh) exit cases
#stop_cmd() { # example usage: $(stop_cmd)
#    echo "return 0 2>/dev/null"
#    echo "exit 0"
#}
#export -f stop_cmd
#alias stop='$(stop_cmd)' # this only works when you source .bashrc
# stop code: just use return 0 (since you usually do the . for executing scripts)
#stop='$(stop_cmd)'
#export stop
#stop='return 0 2>/dev/null'$'\n'' exit 0'

## where $1 is the real file name
## & $2 shared file link (from google)
## verified to work (1/4/19)
#download_drive_file() {
#    id=$(echo "$2" | sed 's/.*id=//')
#    wget "https://drive.google.com/uc?authuser=0&id=${id}&export=download" -O $1
#}

## note: doesn't work currently
## macro for help strings, must have defined 'usage' (help str)
#alias if-h-then-usage='[ "$1" = "-h" ] && echo $usage'

# NOTE: this workaround causes its own special case bug..., reverting to simpler version...
#log() {
#    # Before there were special cases where log would pass ITS OWN positional
#    # arguments as the positional arguments to a script it would run 
#    # (e.g. when no actual positional args were passed).
#    all_args="$@" # NOTE: this still passes correct positional arguments fine
#    echo $all_args
#    set -- # removes all positional arguments
#
#    # braces allow for piping of same output to multiple files
#    { $all_args 2> >(tee .err.log); } &> >(tee .out.log);
#    echo; echo logged output to .err.log \& .out.log respectively;
#}

# makes default ping target google DNS server
#ping() {
#    if (($# < 2)); then
#        ping 8.8.8.8
#    else
#        ping $@
#    fi
#}

#rld() { # faster reload implementation
#   . ~/.bashrc
#   source ~/.profile &
#   source ~/.bash_profile &
#}
#alias rld='. ~/.profile; . ~/.bash_profile; . ~/.bashrc'
