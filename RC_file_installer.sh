#!/bin/bash

# where $1 is the real file name
# & $2 shared file link (from google)
# verified to work (1/4/19)
download_drive_file() {
  id=$(echo "$2" | sed 's/.*id=//')
	wget "https://drive.google.com/uc?authuser=0&id=${id}&export=download" -O $1
}

cd ~
rm .vimrc .inputrc .bash_aliases
download_drive_file .vimrc https://drive.google.com/open?id=1FrWomBkJyPxDfe40dvjluA15o3VoFNgt
download_drive_file .inputrc https://drive.google.com/open?id=1b7vHr68vqCliHY-4mHFGlrImrNKbZbCZ
download_drive_file .bash_aliases https://drive.google.com/open?id=1Ra27BW-S40xy00xzSkxW4Hzpcf31IPsY

. .bash_aliases

# strict enough? (+ buggy)
#if ["$(grep '.bash_aliases' .bashrc)"=""]; then
#  echo "if [ -f ~/.bash_aliases ]; then" >> .bashrc
#  echo ". ~/.bash_aliases" >> .bashrc
#  echo 'fi' >> .bashrc
#fi

# strict enough? (buggy)
#if [ -f .bash_profile ] && [ "$(grep '.bashrc' .bash_profile)"="" ]; then
#  echo 'if [ -f ~/.bashrc ]; then' >> .bash_profile
#  echo '. ~/.bashrc' >> .bash_profile
#  echo 'fi' >> .bash_profile
#fi
