#!/bin/bash

# verified to work (10/16/22)
# where $1 is the real file name & $2 "id" (extract manually) from shared Gdrive link
download_drive_file_by_id() {
	wget --no-check-certificate "https://drive.google.com/uc?authuser=0&id=$2&export=download&confirm=yes" -O $1
}

cd ~
rm .vimrc .inputrc .bash_aliases .Rprofile .condarc
download_drive_file_by_id .vimrc 1PnBMvrwFeAnI5asaI7ndYGxd6mDGszx5
download_drive_file_by_id .Rprofile 14Txp18eXWK5Oia0csYtbH9TYtMinP_sN
download_drive_file_by_id .inputrc 1b7vHr68vqCliHY-4mHFGlrImrNKbZbCZ
download_drive_file_by_id .bash_aliases 1Ra27BW-S40xy00xzSkxW4Hzpcf31IPsY
download_drive_file_by_id .condarc 14JU5hRNZvXC3QJjkzYSSslpo4J9m07Kk

. .bash_aliases