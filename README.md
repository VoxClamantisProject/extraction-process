# extraction-process

This directory currently contains R and Praat scripts to extract the phonetic measures reported in our paper for vowels and sibilants. 

The directory phonetic_measures contains two subdirectories, local_extract and shell_extract. The scripts in local_extract are better suited for use on a local computer, and the scripts in shell_extract are better suited for use on a cluster and using a shell script with the appropriate arguments. 

## local_extract 
createTextGridsWilderness.praat: create phoneme-level TextGrid for each "utterance" in each language based on phoneme-level alignments

getFormantsWilderness.praat: extract F1--F4 from each quartile and decile of each vowel

extractSibilantsWilderness.praat: extract sibilant fricatives as wav files for further processing in MultitaperSpectralMomentsPeak.R

MultitaperSpectralMomentsPeak.R: process sibilant extracts to obtain spectral moments and peak measurements for each sibilant fricative

## shell_extract

getFormantsWilderness_shell.praat: see getFormantsWilderness.praat

get_all_formants.sh: runs getFormantsWilderness_shell.praat

MultitaperSpectralMomentsPeak_shell.R: see MultitaperSpectralMomentsPeak.R

get_all_sibilants.sh: runs MultitaperSpectralMomentsPeak_shell.R
