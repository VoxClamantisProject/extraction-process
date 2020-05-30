#!/bin/bash
#$ -cwd
#$ -S /bin/bash

#calls qsub for each rec dir in textgrids
for X in textgrids2/*; do
    LANG=${X#textgrids2/} #removes prefix textgrids/ to get name
    echo $LANG
    qsub -N $LANG -o logs_sibs/$LANG.output.txt -e logs_sibs/$LANG.error.txt get_sibilants.sh $LANG
done
