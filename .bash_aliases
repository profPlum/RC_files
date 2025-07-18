#!/bin/bash
# IMPORTANT: if this is giving you weird errors remove all '' and '\t' characters

##### Contains aliases, functions and optionally #####
##### path additions needed for all .bashrc files. #####

if [[ "$(which env_parallel 2>/dev/null)" ]]; then
    . `which env_parallel.bash` # setup env_parallel command
    env_parallel --session # must come first for proper usage! (so it knows what env to exclude)
    #alias parallel='env_parallel' # it's the same except a tad slower & exports the environment!! Totally worth it!
fi

#set -a 

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
#alias ls='ls -t --color=yes' # lighter version of ls
alias lsz='du -hs * .??*' # gives you accurate measurements of size for **local directories** (& files), ls only does files
alias grep='grep -ni'
grepO() { sed -En "s/^.*$1.*$/\1/p"; } # like grep -o but only prints the 1st capture group
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

benchmark() {
    N=$1
    for ((i=0; i<1000; i++)) {
        N=$((N+1))
    }
    echo $N
}

## map + exporting env VARIABLES ONLY, in practice this is all that's needed and much faster
#map() { (export $(compgen -v); \xargs -L1 bash -c "$1" _) ; }
#map1() { \xargs -n1 | map "$@" ; } 
#
## amap + exporting env VARIABLES ONLY, in practice this is all that's needed and much faster
#amap() { (export $(compgen -v); \xargs -L1 -P $(getconf _NPROCESSORS_ONLN) bash -c "$1" _) ; }
#amap1() { \xargs -n1 | amap "$@" ; }

# NOTE: lol I just realized that amap could've been written using a regular loop you'd just need to use `read` to get input lines (& thus get the multiple args per line)

# All the functionality and more of amap_env + being faster than even amap!!
# GOTCHA: the input arguments per line will have shell syntax evaluated which usually isn't a problem but w/e 
amap_for() {
    CMD="$1"
    cmd_f() { eval "$CMD"; }
    
    set +m # disable montior mode (reporting "done" bg processes)
    while read -r LINE; do
        eval cmd_f "$LINE" &
        # (( N>=N_CPUs*2 )) && wait -n # wait for first bg job to finish
    done
    wait
    set -m
}

map_for() {
  CMD="$1" # eval trick lets it take quoted args
  cmd_f() { eval "$CMD"; }
  while read -r LINE; do
      eval cmd_f "$LINE"
  done
}

# NOTE: these are the new versions of amap & map which are much faster than the old ones
alias map='map_for' # map is now a synonym for map_for
alias amap='amap_for' # amap is now a synonym for amap_for
alias amap1='\xargs -n1 | amap_for'
alias map1='\xargs -n1 | map_for'

## Verified to work (on CCR): 5/23/24
## NOTE: new version of amap which also inherets the entire shell-scope from the calling shell!
#amap_env() { (export $(compgen -v); \xargs -L1 -P $(getconf _NPROCESSORS_ONLN) bash -c "$(declare -f);""$1" _) ; }
## GOTCHA: actually this should be depreciated in favor of env_parallel which is a project that does everything you want and much more!
#map_env() { (export $(compgen -v); \xargs -L1 bash -c "$(declare -f);""$1" _) ; }

## these new versions works in environments where the text from declared functions is too much
amap_env() {
    (export $(compgen -v); # export variables
    set -a; source ~/.bash_aliases; set +a; # export functions
    \xargs -L1 -P $(getconf _NPROCESSORS_ONLN) $0 -c "$1" _) ;
}
#
## this works in environments where the text from declared functions is too much
#map_env() {
#    (export $(compgen -v); # export variables
#    set -a; source ~/.bash_aliases; set +a; # export functions
#    \xargs -L1 bash -c "$1" _) ; 
#}

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
    \find . -regextype posix-extended -type f -regex ".*\.(c|cpp|h|py|sh|R|yaml)" | amap 'flat_ws $1' 
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

# edits input to have zero padded ints
zero_pad() {
    N_ZERO_PAD=8
    (( $# > 0 )) && N_ZERO_PAD=$1
    sed -E ":r; s/(^|[^0-9])([0-9]{1,$((N_ZERO_PAD-1))})([^0-9]|$)/\10\2\3/g; t r"
}

zero_pad_files() {
    (\xargs -n1 | amap 'mv "$1" "$(zero_pad <<< $1)"') <<< "$@"
}

alias kill_kids='pkill -P $$'
alias jupyter2py='jupyter nbconvert --to script' #e.g. jupyter2py notebook.ipynb # (--> produces notebook.py)
alias rm_bad_lns='\find . -xtype l -delete' # deletes broken links

# Example usage: at_night log . some_job.sh
# Verified to work 7/4/24
export _NIGHT_TIME='today 23:00' # or 'tomorrow 00:00' (midnight)
alias at_night='sleep $(( $(date +%s -d "$_NIGHT_TIME") - $( date +%s ) )); '

alias no_numbers="sed -E 's|[0-9]+||g'"
alias unique="no_numbers | sort | uniq"

alias stop='return 0 || exit 0'
assert() { eval [[ "$@" ]] && echo Assert is False!! : "$@" && exit 2; } # requires subshell execution!
export -f assert

# NOTE: where $1 is the real file name, and $2 is the id from the url
download_drive_file_by_id() { wget --no-check-certificate "https://drive.google.com/uc?authuser=0&id=$2&export=download&confirm=yes" -O $1; }

# Verified to work 6/9/22, NOTE: replaces all occurrences of $2 with $3 in folder: $1
repl_strs_in_dir() { \find "$1" -type f | xargs sed -i'' "s|$2|$3|g"; }
repl() { # verified to work 9/6/23, EXAMPLE: repl old new *.txt
    cmd="s|$1|$2|g"
    shift; shift
    sed -i'' "$cmd" $@ #TODO: maybe add backup suffix?
    # NOTE: using sed -i'' is most general/compatible way to use sed across mac & linux
}

# maybe extra?
# simplified sed, takes $1 as pattern & $2 as replace
sd() { sed -E "s|$1|$2|g"; }

# Verified to work: 4/30/25
# USAGE: quote "let's quote this\!" --> 'let\\'s quote this\!'
quote()
{   
    local quoted=${@//\'/\'\\\'\'};
    printf "'%s'\n" "$quoted"
}

# USAGE: cat file | quote_lines
quote_lines() {
    while read -r LINE; do
        quote $LINE
    done
}

# All Verified to work: 4/30/45
under_score_name() { name=$(dirname "$@")/$(basename "$@" | tr ' ' '_'); [[ "${@}" -ef "$name" ]] || mv "${@}" "$name"; }
under_score_directory() { \ls -1 "$@" | quote_lines | amap 'under_score_name "$1"' ; } # non-recursive!
under_score_recursive() { \find . -not -path '*/.*' | sed '1d' | quote_lines | tac | map 'under_score_name "$1"'; } # dangerous!
# ^ idea here is find all non-hidden files, then exclude '.', then quote to fix apostrophes, then reverse the order & sequential map so that renaming top-level directories doesn't break other paths

# drops all but most recent N files/folders in a directory
keep_last_N_files() {
    n_keep=$1
    if (( $# > 1)); then
        dir="$2"
    else
        dir=.
    fi

    echo N=$n_keep, dir=$dir, pwd=$(pwd)

    files=$(\ls -1t "$dir")
    n_total=$(echo "$files" | wc -l)
    n_drop=$(( n_total-n_keep ))

    echo counted $n_total existing files!
    echo dropping $n_drop old files

    if ((n_total<=n_keep)); then
        echo nothing to do... exiting
        return 0 || exit 0
    fi
    
    files=$(echo "$files" | \tail -n $n_drop)
    echo files to drop:
    echo "$files"

    ## alternative to the loop
    #quote_lines <<< "$files" | amap_env 'rm -rf "$dir"/"$1"'

    while read -r file; do
        rm -rf "$dir"/"$file"
    done <<< "$files"
}

alias stop='return 0 || exit 0'
assert() { eval [[ "$@" ]] && echo Assert is False!! : "$@" && exit 2; } # requires subshell execution!
export -f assert

# NOTE: where $1 is the real file name, and $2 is the id from the url
download_drive_file_by_id() { wget --no-check-certificate "https://drive.google.com/uc?authuser=0&id=$2&export=download&confirm=yes" -O $1; }

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

# NOTE: request interactive slurm shell --> salloc cmd
alias swatch-me="watch \"squeue --me -S S --format='%.10i %.9P %.40j %.8T %.10M %.9l %.6D %.18R'\""
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
    auto_numeric_perturb() { sed -r 's/(--[A-z0-9-]+=| )([0-9.]+)( |$)/\1"$(rand_numeric_perturb \2)"\3/g'; } # handles --var=value and --var value cases
    _auto_flag_perturb() { sed -r 's/(--[A-z0-9-]+)( --|$)/"$(rand_factor_sample \1)"\2/g'; }
    auto_flag_perturb() { _auto_flag_perturb | _auto_flag_perturb; } # We x2 apply auto_flag_perturb b/c regex doesn't allow overlapping matches!!
    auto_bool_perturb() { sed -r 's/(True|False)/"$(rand_factor_sample True False)"/g'; }
    perturbed_cli=$(echo "$@" | auto_numeric_perturb | auto_flag_perturb | auto_bool_perturb)
    perturbed_cli="$(eval echo \"$perturbed_cli\")" # verified to handle string properly!! 10/31/23
    echo prev CLI args: "$@" >&2
    echo new CLI args: "$perturbed_cli" >&2
    echo "$perturbed_cli"
    auto_numeric_perturb() { sed -r 's/(--[A-z0-9-]+)[ =]([0-9.]+)/\1="$(rand_numeric_perturb \2)"/g'; }
} # P.S. Very nice property: as long as 0<NUM_PERTURB_SPREAD<1 can't convert 0 < float < 1 --> float > 1 

# Important for subshells/job scripts!
export -f auto_cli_perturb rand_factor_sample rand_numeric_perturb

#set +a
