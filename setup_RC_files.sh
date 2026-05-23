#!/bin/bash

# Git alternative to the RC_file_installer.sh
# * NEW INSTALL: git clone https://github.com/profPlum/RC_files.git ~/.RC_files; . ~/.RC_files/setup_RC_files.sh
# * auto-updates once installed
# * installs repo into ~/.RC_files
# * can be used on mac to setup RC file links (but still requires manual mac.bashrc link)
# * GOTCHA: major weakness is that it requires explicit commits also it can cause automatic accidental git conflicts
# P.S. If you were to fully embrace this appraoch you could remove it from google drive which removes some of the special cases...

# This is the directory of this bash script!
source_dir=$(dirname "$(realpath $BASH_SOURCE)") # Verified to work: 5/21/26
source_dir_relative="${source_dir##$HOME/}" # (relative to home) for simpler/less verbose links

# simplify relative path EVEN FURTHER (create ~/.RC_files sym link if possible for short readable paths)
[[ ! -e ~/.RC_files ]] && \ln -s "$source_dir_relative" ~/.RC_files
[[ "$(realpath ~/.RC_files)" == "$source_dir" ]] && source_dir_relative=".RC_files"

# Technically: assumes no space in RC file names (but easy to add more!)
RC_file_list=".vimrc .inputrc .condarc .bash_aliases .Rprofile"

# NOTE: hard links won't work because file indentity changes due to Git and/or GDrive
for RC_file in $RC_file_list; do
    echo installing: $RC_file
    rm ~/$RC_file
    \ln -s "$source_dir_relative/$RC_file" ~
done

if [[ "$(uname)" == Darwin ]]; then
    echo mac detected! installing mac.bashrc...
    rm ~/.bashrc
    \ln -s "$source_dir_relative/mac.bashrc" ~/.bashrc
fi

echo installing auto-update to .bashrc...
\sed '/echo Updating \.RC_files/d' ~/.bashrc > /tmp/.bashrc_clean
cat /tmp/.bashrc_clean > ~/.bashrc # delete any previous auto-update line(s)
echo "(echo Updating .RC_files...; \\cd '$source_dir'; git pull) >&2 # keep RC_files up to date" >> ~/.bashrc

source ~/.bash_aliases # import bash aliases for immediate use
