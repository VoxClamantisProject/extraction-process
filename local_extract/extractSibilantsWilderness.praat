# extractSibilants.praat
# Extract s,z,S,Z and variants; exclude sil and ssil
# Get information about the file, duration, preceding and following phones
# Written by Eleanor Chodroff
# 2 December 2019

# make sure the TextGrids and wav files have the same name and are in the languageID/aligned/wav directory
# create sibilants folder with subdirectories for where to put the info and extracts 
# folders named by languageID should be in master_dir$
# wav files should be in master_dir$ + 'languageID'/aligned/wav/
# TextGrids files should be in master_dir$ + 'languageID'/aligned/wav/

###################
# where are all the languageID folders located?
masterdir$ = "/Users/xxx/ready_for_sibilants/"

# where should I write the file with the preliminary information?
outfiledir$ = "/Users/xxx/sibilants/info/"
outfileExt$ = "_sibInfo.csv"
sep$ = ","

# where should I save the sibilant extracts?
outdirinit$ = "/Users/xxx/sibilants/extracts/"
###################

Create Strings as directory list: "langs", masterdir$ + "*"
nLangs = Get number of strings
#pause
for k from 1 to nLangs
	selectObject: "Strings langs"
	lang$ = Get string: k
 	dir$ = masterdir$ + lang$ + "/aligned/wav/"
	outdir$ = outdirinit$ + lang$ + "/"
	outfile$ = outfiledir$ + lang$ + outfileExt$
	@createHeader
	
	Create Strings as file list: "files", dir$ + "*.TextGrid"
	nFiles = Get number of strings
	for i from 1 to nFiles
		@processFile
	endfor
	#pauseScript: "done one lang"
endfor

procedure createHeader 
	appendFile: outfile$, "file", sep$, "sib", sep$, "prec", sep$, "foll", sep$, "trial", sep$
	appendFile: outfile$, "start", sep$, "end", sep$, "dur", newline$
endproc

procedure processFile 
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + basename$ + ".wav"

	# loop through TextGrid to find sibilants
	selectObject: "TextGrid " + basename$
	nInt = Get number of intervals: 1
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 1, j
		# do stuff if label is a sibilant and not if a silence
		if index_regex(label$, "^[szSZ]") & !index_regex(label$, "ssil|sil")
			@getLabels
			@getTime
			@extractSibilant
		endif
	endfor

	#pauseScript: "done one file"
	# do some clean up
	select all
	minusObject: "Strings files"
	minusObject: "Strings langs"
	Remove
endproc

procedure getLabels
	if j > 1
		prec$ = Get label of interval: 1, j-1
	else
		prec$ = "NA"
	endif
	if j < nInt
		foll$ = Get label of interval: 1, j+1
	else
		foll$ = "NA"
	endif
	appendFile: outfile$, basename$, sep$, label$, sep$, prec$, sep$, foll$, sep$, string$(j), sep$
endproc

procedure getTime
	start = Get start time of interval: 1, j
	end = Get end time of interval: 1, j
	dur = end - start
	appendFile: outfile$, start, sep$, end, sep$, dur, newline$
endproc	

procedure extractSibilant
	selectObject: "Sound " + basename$
	Extract part: start, end, "rectangular", 1.0, "no"
	Save as WAV file: outdir$ + basename$ + "_" + label$ + "_" + string$(j) + ".wav"
	Remove
endproc
	
