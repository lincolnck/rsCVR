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

for d in */; do
	cd "$d"
	a=1
	for i in *.img; do
		newimg=$(printf "bold_%01d.img" "$a")
		mv -i -- "$i" "./$newimg"
		# echo $newimg
		((a++))
	done
	b=1
	for j in *.hdr; do
		newhdr=$(printf "bold_%01d.hdr" "$b")
		mv -i -- "$j" "./$newhdr"
		((b++))
	done
	cd ..
done