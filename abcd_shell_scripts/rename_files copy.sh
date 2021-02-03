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

# Consolidates all separate directories containing images for all subjects
# into one directory with the subject's name. 

for d in */; do
	# determines the subjects name (first part of title NDARIN...)
	subject_name=${d/_*}
	# makes a directory with that name
	mkdir -p $subject_name
	# moves all files located in any of the directories with that matching name
	# into the new directory
	a=1
	b=1
	c=1
	e=1
	g=1
	h=1
	case $d in 
		(*rsfMRI*) 
		newimg=$(printf "bold_%01d.img" "$a")
		newhdr=$(printf "bold_%01d.hdr" "$b")
		mv -n -- $d/*.img "$subject_name/$newimg"
		mv -n -- $d/*.hdr "$subject_name/$newhdr"
		while [[ -f "$subject_name/$newimg" ]]; do
			((a++))
			newimg=$(printf "bold_%01d.img" "$a")
			mv -n -- $d/*.img "$subject_name/$newimg"
		done
		while [[ -f "$subject_name/$newhdr" ]]; do
			((b++))
			newhdr=$(printf "bold_%01d.hdr" "$b")
			mv -n -- $d/*.hdr "$subject_name/$newhdr"
		done;;
		(*T1_*) 
		newimg=$(printf "T1_%01d.img" "$c")
		newhdr=$(printf "T1_%01d.hdr" "$e")
		mv -n -- $d/*.img "$subject_name/$newimg"
		mv -n -- $d/*.hdr "$subject_name/$newhdr"
		while [[ -f "$subject_name/$newimg" ]]; do
			((c++))
			newimg=$(printf "T1_%01d.img" "$c")
			mv -n -- $d/*.img "$subject_name/$newimg"
		done
		while [[ -f "$subject_name/$newhdr" ]]; do
			((e++))
			newhdr=$(printf "T1_%01d.hdr" "$e")
			mv -n -- $d/*.hdr "$subject_name/$newhdr"
		done;;
		(*T1-NORM*) 
		newimg=$(printf "T1_NORM_%01d.img" "$g")
		newhdr=$(printf "T1_NORM_%01d.hdr" "$h")
		mv -n -- $d/*.img "$subject_name/$newimg"
		mv -n -- $d/*.hdr "$subject_name/$newhdr"
		while [[ -f "$subject_name/$newimg" ]]; do
			((g++))
			newimg=$(printf "T1_NORM_%01d.img" "$g")
			mv -n -- $d/*.img "$subject_name/$newimg"
		done
		while [[ -f "$subject_name/$newhdr" ]]; do
			((h++))
			newhdr=$(printf "T1_NORM_%01d.hdr" "$h")
			mv -n -- $d/*.hdr "$subject_name/$newhdr"
		done;;
	esac
	# removes the original directory.
	rm -r $d
done

# renames the images for easier downstream processing.

# for d in */; do
# 	cd "$d"
# 	a=1
# 	for i in *fMRI*.*; do
# 		case $i in 
# 			(*.img) newimg=$(printf "bold_%01d.img" "$a");;
# 			(*.hdr) newimg=$(printf "bold_%01d.hdr" "$a");;
# 		esac
# 		mv -n -- "$i" "./$newimg"
# 		((a++))
# 	done
# 	b=1
# 	for j in *T1*.*; do
# 		case $j in 
# 			(*.img) newhdr=$(printf "T1_%01d.img" "$b");;
# 			(*.hdr) newhdr=$(printf "T1_%01d.hdr" "$b");;
# 		esac
# 		mv -n -- "$j" "./$newhdr"
# 		((b++))
# 	done
# 	cd ..
# done