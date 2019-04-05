export HOME="/c/Users/dwyer/Favorites"
export USER_EMAIL=ddeighan@umassd.edu

# export PATH="/c/Windows/System32:$PATH"
export PATH="/c/Users/dwyer/Anaconda3:$PATH"
export PATH="/c/Users/dwyer/Anaconda3/Scripts:$PATH"
export PATH="$HOME/Misc/bin:$PATH"

#. /c/Users/dwyer/Anaconda3/etc/profile.d/conda.sh
#conda activate

######################## ADDED FOR GW-ANALYSIS-DNN ########################
export GW_DNN_INSTALL_PATH="/c/Users/dwyer/Misc/Work/gw-analysis-dnn"
export GW_DNN_INSTALLED="TRUE"

# add scripts to path
export PATH="$GW_DNN_INSTALL_PATH/scripts:$PATH"
export PATH="$GW_DNN_INSTALL_PATH/scripts/bash_utils:$PATH"

# easy cd's that are made frequently
alias gw="cd $GW_DNN_INSTALL_PATH/scripts"
alias td="cd $GW_DNN_INSTALL_PATH/training_data"
alias cfg="cd $GW_DNN_INSTALL_PATH/configs"
alias timer="cd ~/Work/Java/'ActivityFocusTimer'"

export UMD_IP="134.88.5.42"
alias mit_cloud="ssh ddeighan@txe1-login.mit.edu"
alias ghpcc="ssh dd13d@ghpcc06.umassrc.org"
alias umd="ssh ddeighan@$UMD_IP"

###########################################################################

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

# windows specific stuff below:

to-win() {
    if (( $# != 1 )); then
        echo "usage: to-win unix-path > win-path"
        return 1
    fi

	ARG1=$1
	if [ "${ARG1:0:2}" = "/c" ]; then
		ARG1="C:${ARG1:2}" # start with windows-style C drive
    elif [ "${ARG1::1}" = "~" ]; then
        # most windows utilies dont accept '~'
        ARG1="$HOME${ARG1:1}"
    fi

	echo $ARG1 | tr '/' '\\' # return new path (translated)
}
export -f to-win

# now lives in .bash_aliases
to-nix() {
    if (( $# == 1 )) && [ "$1" != '-h' ]; then
	    ARG1="$1"
    elif [ "$1" = '-nc' ]; then
        ARG1="$2"
        if [ "${ARG1:0:2}" = "C:" ]; then
            ARG1="/c${ARG1:2}" # start with linux-style C drive
        fi
    else
        echo "usage: to-nix [-nc] 'win-path' (must be quoted) > nix-path"
        echo "note: -nc converts the 'C:' to unix style as well..."
        return 1
    fi

	echo $ARG1 | tr '\\' '/' # return new path (translated)
}
export -f to-nix

unalias ln # unalias ln='ln -s'
# verified to work 12/30/18
# makes symbolic links (NOTE: developer mode must be on!)
# NOTE: symbolic links appear to be the best kind there is
ln() {
    if [ "$1" = "-h" ] || (( $# == 0 )); then
		echo "usage: > ln target [link_name]"
		echo "note: dot (.) (or no) link_name means preserve target_name as link_name"
		echo "note: non-local link_name's aren't allowed"
        return 1
    fi
	
    if (( $# == 1 )); then
        link_name=. # this is behaviour of real ln
    else
        link_name="$2"
    fi

    link_base=$(basename "$link_name")
    if ! [ "$link_base" == "$link_name" ]; then
        echo "non-local link_names aren't supported, please cd to that directory first instead"
        return 1
    fi
    
    mklink_args=""
	if [ -d "$1" ]; then # if target is a directory
        mklink_args="/D"
    elif ! [ -e "$1" ]; then
        echo "target: \"$1\" doesn't exist..."
        return 1
    fi

	#dot (.) means preserve target name as link name
	if [ "$link_name" == "." ]; then
		link_name=$(basename "$1")
	fi
    
	target=$(to-win "$1")
	link_name=$(to-win "$link_name")
		
	# the actual windows command takes args in reverse order
	command="mklink $mklink_args \"$link_name\" \"$target\""
	out=$(cmd.exe /c "$command")
    echo $(to-nix "$out")
}
export -f ln

# for unblocking files from the internet
# use * to unblock multiple files (dont use directories)
# note this powershell functionality appears to be broken 11/19/18
unblock-files() {
    if (( $# < 1 )); then
        return 1
    fi
    
    for path in "$@"; do
        win_path=$(to-win-path "$path")
        powershell -Command "Unblock-File -Path \"$win_path\""
        echo executing: powershell -Command \"Unblock-File -Path \"$win_path\"\"
        # cmd="powershell -Command \"Unblock-File -Path \"$win_path\"\""; $cmd
        # echo cmd # TODO: does this work?
    done
}
export -f unblock-files


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

# TODO: fix! (doesn't work in git bash)
# cd to simplifed directory (relative to home links)
# cd "$(relpath-sym .)"
cd ~