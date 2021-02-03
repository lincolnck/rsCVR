#!/bin/bash

#************************************************#
#                   xyz.sh                       #
#           written by Bozo Bozeman              #
#                July 05, 2001                   #
#                                                #
#           Clean up project files.              #
#************************************************#

E_BADDIR=85                       # No such directory.
projectdir=/home/bozo/projects    # Directory to clean up.

# --------------------------------------------------------- #
# cleanup_pfiles ()                                         #
# Removes all files in designated directory.                #
# Parameter: $target_directory                              #
# Returns: 0 on success, $E_BADDIR if something went wrong. #
# --------------------------------------------------------- #

source_directory=$1
dest_directory=$2

for d in $1/; do
	cd $d
	echo $d
	for sub_d in */; do
		cd $sub_d
		subject_name=$(find . -maxdepth 1 -name '*.hdr' -exec basename {} \; | cut -c -12 | head -n 1)
		echo $subject_name # zip -r "mpr.zip" . -x ".*" -x "__MACOSX"
		if [ -d ${dest_directory}/${subject_name} ]
		then
			echo "Directory $dest_directory/$subject_name exists"
			# file_to_move=${subject_name}'.hdr'
			mv 'mpr.zip' ${dest_directory}/${subject_name}
		else
			echo "Directory $dest_directory/$subject_name doesn't exist"
		fi
		cd ..
	done
	cd ..
done

