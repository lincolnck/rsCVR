#!/bin/bash

#************************************************#
#     consolidate_dirs.sh                        #
#     written by Lincoln Kartchner               #
#     January 28, 2021                           #
#                                                #
#     Consolidates directories.                  #
#************************************************#

E_BADDIR=85      # No such directory.
projectdir=$1    # Directory to clean up.

# --------------------------------------------------------- #
# cons_dirs ()                                              #
# Consolidates all images (rsfMRI, T1, T1_NORM) for each    #
# subject into one directory named for that subject.        #
# Parameter: $projectdir, the directory containing the      #
# converted analyze images, yet to be sorted into           #
# individual subject directories.                           #
# Returns: 0 on success, $E_BADDIR if something went wrong. #
# --------------------------------------------------------- #


cons_dirs ()
{
  if [ ! -d "$projectdir" ]  # Test if target directory exists.
  then
    echo "$projectdir is not a directory."
    return "$E_BADDIR"
  fi
  for d in "$projectdir"/*; do
	subject_name=${d/_*}  
	mkdir -p "$subject_name"
	mv -v $d/* "$subject_name"
	rm -r $d
	done
  return 0   # Success.
}  

cons_dirs $projectdir
