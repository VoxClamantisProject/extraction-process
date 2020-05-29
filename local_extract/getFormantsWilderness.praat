# getFormantsWilderness.praat
# Get formants 1--4 at predefined points in the vowel: quartiles and deciles
# Get information about the file, vowel, and duration
# Written by Eleanor Chodroff
# 19 November 2019

# make sure the TextGrids and wav files have the same name and are in the languageID/aligned/wav directory

###################
# where are all the languageID folders located?
masterdir$ = "/Users/xxx/langs/"

# where should I write the file with the formants?
outfiledir$ = "/Users/xxx/formants/"
outfileExt$ = "_formants.csv"
sep$ = ","
###################

Create Strings as directory list: "langs", masterdir$ + "*"
nLangs = Get number of strings
pause
for k from 1 to nLangs
	selectObject: "Strings langs"
	lang$ = Get string: k
 	dir$ = masterdir$ + lang$ + "/aligned/wav/"
	outfile$ = outfiledir$ + lang$ + outfileExt$
	@createHeader
	
	Create Strings as file list: "files", dir$ + "*.TextGrid"
	nFiles = Get number of strings
	for i from 1 to nFiles
		@processFile
	endfor
	# pauseScript: "done one lang"
endfor

procedure createHeader 
	appendFile: outfile$, "file", sep$, "vowel", sep$, "prec", sep$, "foll", sep$
	appendFile: outfile$, "start", sep$, "end", sep$, "dur", sep$
	appendFile: outfile$, "f1_start", sep$, "f1_q1", sep$, "f1_mid", sep$, "f1_q3", sep$, "f1_end", sep$
	appendFile: outfile$, "f1_t0", sep$, "f1_t1", sep$, "f1_t2", sep$, "f1_t3", sep$, "f1_t4", sep$, "f1_t5", sep$, "f1_t6", sep$, "f1_t7", sep$, "f1_t8", sep$, "f1_t9", sep$, "f1_t10", sep$
	appendFile: outfile$, "f2_start", sep$, "f2_q1", sep$, "f2_mid", sep$, "f2_q3", sep$, "f2_end", sep$
	appendFile: outfile$, "f2_t0", sep$, "f2_t1", sep$, "f2_t2", sep$, "f2_t3", sep$, "f2_t4", sep$, "f2_t5", sep$, "f2_t6", sep$, "f2_t7", sep$, "f2_t8", sep$, "f2_t9", sep$, "f2_t10", sep$
	appendFile: outfile$, "f3_start", sep$, "f3_q1", sep$, "f3_mid", sep$, "f3_q3", sep$, "f3_end", sep$
	appendFile: outfile$, "f3_t0", sep$, "f3_t1", sep$, "f3_t2", sep$, "f3_t3", sep$, "f3_t4", sep$, "f3_t5", sep$, "f3_t6", sep$, "f3_t7", sep$, "f3_t8", sep$, "f3_t9", sep$, "f3_t10", sep$
	appendFile: outfile$, "f4_start", sep$, "f4_q1", sep$, "f4_mid", sep$, "f4_q3", sep$, "f4_end", sep$
	appendFile: outfile$, "f4_t0", sep$, "f4_t1", sep$, "f4_t2", sep$, "f4_t3", sep$, "f4_t4", sep$, "f4_t5", sep$, "f4_t6", sep$, "f4_t7", sep$, "f4_t8", sep$, "f4_t9", sep$, "f4_t10", newline$
endproc


procedure processFile 
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + basename$ + ".wav"

	# convert wav files to formant objects
	To Formant (burg): 0, 5, 5000, 0.025, 50

	# loop through TextGrid to find vowels
	selectObject: "TextGrid " + basename$
	nInt = Get number of intervals: 1
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 1, j
		# do stuff if label is a vowel
		if index_regex(label$, "^[@}{&AEIOUYQaeiouy123456789]")
			@getLabels
			@getTime
			@getFormants: 1
			@getFormants: 2
			@getFormants: 3
			@getFormants: 4
		endif
	endfor

	# pauseScript: "done one file"
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
	appendFile: outfile$, basename$, sep$, label$, sep$, prec$, sep$, foll$, sep$
endproc

procedure getTime
	start = Get start time of interval: 1, j
	end = Get end time of interval: 1, j
	dur = end - start
	appendFile: outfile$, start, sep$, end, sep$, dur, sep$ 
endproc	

procedure getFormants: formantNum
	selectObject: "Formant " + basename$

	# get formants at each quartile (including start and end)
	#f_start = Get value at time: formantNum, start, "hertz", "Linear"
	for f from 0 to 4
		f_time4 = Get value at time: formantNum, start + f*(dur/4), "hertz", "Linear"
		appendFile: outfile$, f_time4, sep$
	endfor

	# get formats at each decile 
	for t from 0 to 10
		f_timex = Get value at time: formantNum, start + t*(dur/10), "hertz", "Linear"
		if f_timex < 10
			appendFile: outfile$, f_timex, sep$
		else
			appendFile: outfile$, f_timex, newline$
		endif
	endfor

endproc
						
