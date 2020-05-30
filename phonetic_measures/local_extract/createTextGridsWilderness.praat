# createWildernessTextGrids.praat
# Convert .lab files into TextGrids with two tiers
# Tier one is the phone tier
# Tier two is the utterance tier (cannot be publicly released)
# Written by Eleanor Chodroff
# 23 November 2019

# add the header "file sentence" to transcription.txt before running script
# convert transcription.txt into true tab-separated file
# replace # header with "end sth phone" on all lab files and call them .lab.tmp
# folders named by languageID should be in master_dir$
# wav files should be in master_dir$ + 'languageID'/aligned/wav/
# lab files should be in master_dir$ + 'languageID'/aligned/lab/

master_dir$ = "/Users/xxx/create-textgrids/"
Create Strings as directory list: "languages", master_dir$ + "*"
nDirs = Get number of strings

for i from 1 to nDirs
	selectObject: "Strings languages"
	lang_dir$ = Get string: i
	transcript_file$ = master_dir$ + lang_dir$ + "/aligned/etc/transcript.txt"
	Read Table from tab-separated file: transcript_file$
	Rename: "transcript"
	phone_dir$ = master_dir$ + lang_dir$ + "/aligned/lab/"
	wav_dir$ = master_dir$ + lang_dir$ + "/aligned/wav/"
	Create Strings as file list: "files", phone_dir$ + "*.lab.tmp"
	nFiles = Get number of strings
	for j from 1 to nFiles
		@createTextGrid
		@addTranscript
		if sentence$ != "NA"
			@addSegments
			selectObject: "TextGrid " + basename$
			Save as text file: wav_dir$ + basename$ + ".TextGrid"
		endif
		select all
		minusObject: "Strings languages"
		minusObject: "Strings files"
		minusObject: "Table transcript"
		Remove
	endfor
	#pauseScript: "done one lang"
endfor 


procedure createTextGrid
	selectObject: "Strings files"
	filename$ = Get string: j
	basename$ = filename$ - ".lab.tmp"
	Read from file: wav_dir$ + basename$ + ".wav"
	To TextGrid: "phone sent", ""
endproc

procedure addTranscript
	selectObject: "Table transcript"
	rowNum$ = Search column: "file", basename$
	spaceIsWhere = index(rowNum$, " ")
	rowNum$ = left$(rowNum$, spaceIsWhere)
	if number(rowNum$) < 1
		sentence$ = "NA"
		appendInfoLine: basename$
	else
		sentence$ = Get value: number(rowNum$), "sentence"
	endif
	selectObject: "TextGrid " + basename$
	Set interval text: 2, 1, sentence$
endproc

procedure addSegments
	Read Table from whitespace-separated file: phone_dir$ + basename$ + ".lab.tmp"
	nRows = Get number of rows
	for k from 1 to nRows
		selectObject: "Table " + basename$ + "_lab"
		phone$ = Get value: k, "phone"
		end = Get value: k, "end"
		selectObject: "TextGrid " + basename$
		if k != nRows
			Insert boundary: 1, end
		endif
		Set interval text: 1, k, phone$
	endfor
	selectObject: "Table " + basename$ + "_lab"
	Remove
endproc
		
		
	
	
	

