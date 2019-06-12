#generic win .bashrc file additions
#NOTE: requires NIX_ROOT_IN_WIN & WIN_ROOT_IN_NIX set appropriately

# converts a linux path to the corresponding path in the global windows file system
to-win() {
    if (( $# != 1 )); then
        echo "usage: to-win unix-path > win-path"
        return 1
    fi

	ARG1=$(realpath $1)
	
    #if we are already in the windows file system
    #then we just need to start the path with 'C:'
    if [[ "$ARG1" =~ ^$WIN_ROOT_IN_NIX ]]; then
		ARG1="${ARG1#$WIN_ROOT_IN_NIX}"
    else
        ARG1="$NIX_ROOT_IN_WINDOWS$ARG1"
    fi

	echo $ARG1 | tr '/' '\\' # return new path (translated)
}
export -f to-win

# converts win paths to nix paths
to-nix() {
    if (( $# == 1 )) && [ "$1" != '-h' ]; then
	    ARG1="$1"
    elif [ "$1" = '-nc' ]; then
        ARG1="$2"
        if [ "${ARG1:0:2}" = "C:" ]; then
            ARG1="$WIN_ROOT_IN_NIX${ARG1:2}" # start with linux-style C drive
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
	
    target="$1"
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
	if [ -d "$target" ]; then # if target is a directory
        mklink_args="/D"
    elif ! [ -e "$target" ]; then
        echo "target: \"$target\" doesn't exist..."
        return 1
    fi

	#dot (.) means preserve target name as link name
	if [ "$link_name" == "." ]; then
		link_name=$(basename "$target")
	fi
    
	target=$(to-win "$target")
	#link_name=$(to-win "$link_name") #already a local name
	
	# the actual windows command takes args in reverse order
	command="mklink $mklink_args \"$link_name\" \"$target\""
	echo $command
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
        win_path=$(to-win "$path")
        command="powershell.exe -Command \"Unblock-File -Path \\"$win_path\\"\""
        $command
        echo executing: $command
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
    for item in $(ls ~) .; do
            item="${item%@}"
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
	done
	echo $simplest_path
}
export -f relpath-sym

# cd to simplifed directory (relative to home links)
cd "$(relpath-sym .)"