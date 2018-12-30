# we have a special home so we ignore all the nonsense folders
export HOME="/c/Users/dwyer/Favorites"
export USER_EMAIL=ddeighan@umassd.edu

export PATH="/c/Windows/System32:$PATH"
export PATH="/c/Users/dwyer/Anaconda3:$PATH"
export PATH="/c/Users/dwyer/Anaconda3/Scripts:$PATH"
export PATH="$HOME/Non-Syncing-Files/bin:$PATH"

#. /c/Users/dwyer/Anaconda3/etc/profile.d/conda.sh
#conda activate

######################## ADDED FOR GW-ANALYSIS-DNN ########################
export GW_DNN_INSTALL_PATH="/c/Users/dwyer/Desktop/Work/GW_Project/gw-analysis-dnn"
export GW_DNN_INSTALLED="TRUE"

# add scripts to path
export PATH="$GW_DNN_INSTALL_PATH/scripts:$PATH"
export PATH="$GW_DNN_INSTALL_PATH/scripts/bash_utils:$PATH"

# easy cd's that are made frequently
alias gw="cd $GW_DNN_INSTALL_PATH/scripts"
alias td="cd $GW_DNN_INSTALL_PATH/training_data"
alias cfg="cd $GW_DNN_INSTALL_PATH/configs"

export UMD_IP="134.88.5.42"
alias mit_cloud="ssh ddeighan@txe1-login.mit.edu"
alias ghpcc="ssh dd13d@ghpcc06.umassrc.org"
alias umd="ssh ddeighan@$UMD_IP"

# needed(?) for cuDNN
#export CPATH="$HOME/anaconda3/include:$CPATH"
#export LIBRARY_PATH="$HOME/anaconda3/lib$LIBRARY_PATH"
#export LD_LIBRARY_PATH="$HOME/anaconda3/lib:$LD_LIBRARY_PATH"
###########################################################################

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

# windows specific stuff below:

to-win-path() {
    if (( $# != 1 )); then
        echo "usage: > to-win-path unix-path"
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
export -f to-win-path

to-nix-path() {
    if (( $# == 1 )) && [ "$1" != '-h' ]; then
	    ARG1="$1"
        if [ "${ARG1:0:2}" = "C:" ]; then
            ARG1="/c${ARG1:2}" # start with linux-style C drive
        fi
    elif [ "$1" = '-wc' ]; then
        # we will preserve the windows style C drive
        # useful for dumping paths to programming strings
        ARG1=$2
    else
        echo "usage: > to-nix-path [-wc] 'win_path' (must be quoted)"
        echo "note: --wc converts slashes to unix style but"
        echo "maintains the 'C:' (if present), use this when coding"
        return 1
    fi

	echo $ARG1 | tr '\\' '/' # return new path (translated)
}
export -f to-nix-path

# verified to work 10/19/18
# todo: make linux port
# makes symbolic links (NOTE: developer mode must be on!)
# NOTE: symbolic links appear to be the best kind there is
mkln() {
    if (( $# != 2 )); then
		echo "usage: > mkln target link_name"
		echo "note: dot (.) for link_name means preserve target_name as link_name"
        echo "also relative targets are interpreted from link destination dir"
        return 1
    fi
	
    # link_name is link_path
	# link_prefix must be absolute
    link_prefix=$(dirname "$2")
    link_prefix=$(realpath "$link_prefix")
    link_name="$link_prefix"/$(basename "$2")
    
    if ! [ -e "$link_prefix" ]; then
        echo "link destination directory: \"$link_prefix\" does not exist"
        return 1
    fi
    
    # we use -q (quite) flag because target doesn't necessarily exist 'as-is'
    # relative to cwd and this makes realpath print an error to screen
    abs_target=$(realpath -q --no-symlinks "$1")
    if [ "$abs_target" = "$1" ]; then # if target is absolute already
        target_from_here="$1" # then do nothing
    else
        target_from_here="$link_prefix/$1" # else make it absolute
    fi
	
	# target_from_here=target relative to cwd (b4: it was relative to link destination)
    
    mklink_args=""
	if [ -d "$target_from_here" ]; then # if target is a directory
        mklink_args="/D"
    elif ! [ -e "$target_from_here" ]; then
        echo "target: \"$target_from_here\" doesn't exist..."
		echo "remember: relative targets are interpreted from link destination dir"
        return 1
    fi

	# dot means preserve target name as link name
    # NOTE: $(cmd) returns are automatically "quoted" for assignment,
	# apparently not in if statements tho so workaround below:
    link_base=$(basename "$link_name")
	if [ "$link_base" = "." ]; then
		link_name="$link_prefix"/$(basename "$1")
	fi
    
	target=$(to-win-path "$1")
	link_name=$(to-win-path "$link_name")
		
	# the actual windows command takes args in reverse order
	command="mklink $mklink_args \"$link_name\" \"$target\""
	out=$(cmd.exe /c "$command")
    echo $(to-nix-path "$out")
}
export -f mkln

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
	mkln "$ARG2" "$1"
}
export -f mv-ln

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

