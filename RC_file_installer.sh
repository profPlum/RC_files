#!/bin/bash

# verified to work (10/16/22)
# where $1 is the real file name & $2 "id" (extract manually) from shared Gdrive link
download_drive_file_by_id() {
	wget --no-check-certificate "https://drive.google.com/uc?authuser=0&id=$2&export=download&confirm=yes" -O $1
}

cd ~
rm .vimrc .inputrc .bash_aliases .Rprofile .condarc
download_drive_file_by_id .vimrc 1wVMJOmwGhZQ6s4Iey32_ePGQp4bYALvr
download_drive_file_by_id .Rprofile 1UXaTsbYH1rTNa_NXWGuGKs1DF4AMRNR9
download_drive_file_by_id .inputrc 1rR38HENhetGgdlPxTC5BGaIhiT1uyaDN
download_drive_file_by_id .bash_aliases 1_eFiLZHnRfGoKdStORoSKVXCybWdf7e6
download_drive_file_by_id .condarc 1RjHir3xAM3Yi6jIyFufwmRtqnSx1MGlu

. .bash_aliases