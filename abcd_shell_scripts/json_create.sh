#!/bin/bash

for d in */; do
	echo $PWD
	cd $d
	subdirname=${d%?}
	boldheader=*.hdr
	boldimg=*.img
	T1zip=*.zip
	echo "Creating .json file for subject: $d"
	jq -n '{userInput: {boldHdrFileName: $one, boldImgFileName: $two, multiatlasFileName: $three, TR: 3}, private: {SmoothFWHMmm: 8, cutfreq: 0.1164, brainMaskName: "BrainMask"}, Dir: {mainPath: "\($four)", outputFileName: "output", workDirFileName: "workspace", outPath: "\($four)/out"}}' \
	--arg one $boldheader \
	--arg two $boldimg \
	--arg three $T1zip \
	--arg four $PWD \
	--arg five $subdirname > rscvr_parameters.json 
	cd ..
done
