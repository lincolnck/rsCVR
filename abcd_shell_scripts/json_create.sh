#!/bin/bash

#************************************************#
#                   xyz.sh                       #
#           written by Bozo Bozeman              #
#                July 05, 2001                   #
#                                                #
#           Clean up project files.              #
#************************************************#

# E_BADDIR=85                       # No such directory.
# projectdir=/home/bozo/projects    # Directory to clean up.

# --------------------------------------------------------- #
# cleanup_pfiles ()                                         #
# Removes all files in designated directory.                #
# Parameter: $target_directory                              #
# Returns: 0 on success, $E_BADDIR if something went wrong. #
# --------------------------------------------------------- #

for d in $1/*/; do
	echo $PWD
	echo $d
	cd $d
	subdirname=${d%?}
	boldheader=*.hdr
	boldimg=*.img
	c02trace=*.txt
	T1zip=*.zip
	echo "Creating .json file for subject: $d"
	jq -n '{userInput: {boldHdrFileName: $one, boldImgFileName: $two, co2TraceFileName: $three, multiatlasFileName: $four, sample_rate_co2: 100, TR: 0.72}, private: {SmoothFWHMmm: 8, cutfreq: 0.1164, brainMaskName: "BrainMask"}, Dir: {mainPath: "\($five)", outputFileName: "output", workDirFileName: "workspace", outPath: "\($five)/out"}}' \
	--arg one $boldheader \
	--arg two $boldimg \
	--arg three $c02trace \
	--arg four $T1zip \
	--arg five $PWD \
	--arg six $subdirname > rscvr_parameters.json 
	cd ..
done
