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

for i in */*; do
    

    first_part=${i/NDAR*}
    x=${i/${first_part}}
    second_part=${x/s*}

    mkdir -p $second_part
    cp $i $second_part
done