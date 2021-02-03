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

for d in $1/; do
	cd $d
	for sub_d in */; do
		cd $sub_d
		echo ${sub_d%/}"_mpr.zip"
		zip -r ${sub_d%/}"_mpr.zip" . -x ".*" -x "__MACOSX"
		echo "Successfully zipped $sub_d"
		cd ..
	done
	cd ..
done

echo "FINISHED ZIPPING!"
