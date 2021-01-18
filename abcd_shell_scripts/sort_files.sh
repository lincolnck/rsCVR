#!/bin/bash

for i in */*; do
    

    first_part=${i/NDAR*}
    x=${i/${first_part}}
    second_part=${x/s*}

    mkdir -p $second_part
    cp $i $second_part
done