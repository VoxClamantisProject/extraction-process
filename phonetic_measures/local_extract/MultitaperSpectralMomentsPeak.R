# Multitaper Spectral Analysis on Sound Segments
# Created by Colin Wilson and Eleanor Chodroff
# 2014, 2016
# Last updated: May 8 2020

# This script reads in a series of sound extracts (set up here for sibilant extracts) and takes the
# following measures over the middle 50% of the extract (.wav) using a multitaper spectrum:
# COG (M1), spectral peak, 
# spectral peak between 3k7k (i.e., FreqM for alveolar sibilants), spectral peak btw 2k and 6k (FreqM for postalveolar sibilants),
# spectral variance (M2), skewness (M3), kurtosis (M4)

# For each directory of sound extracts, an output file is created with the above measures called DIRECTORYsibilants.csv

# For any further use of this script, PLEASE CITE:
# Chodroff, E., & Wilson, C. (2014). Burst spectrum as a cue for the stop voicing contrast in American English. The Journal of the Acoustical Society of America, 136(5), 2762-2772.

# ASSUMPTIONS OF THIS SCRIPT:
# - there is a directory with two sub-directories: extracts (maindir) and sibmeasures (outdir) 
# - the extracts directory contains sub-directories (languages) containing sibilant extracts with .wav extensions
# - the extract filenames have the following structure ORIGFILENAME_SIBILANT*_00O*.wav 
# --- the original filename (ORIGFILENAME) can be pretty much anything, the sibilant (or segment label) can be in mixed case, and there can be any amount of numbers preceding the .wav extension (this corresponded to its interval number in the TextGrid). It is more likely than not that you will need to modify the regex at the end of this script to work for your data. 


#################
### CHANGE ME ###
#################

maindir <- '/Users/xxx/sibilants/extracts/' # main directory with sub-folders of sound extracts
outdir <- '/Users/xxx/sibilants/measures/' # output directory for text file
subdirs <- c("ASDFGH", "LKJHGF") # sub-directories within maindir that contain sibilant extracts (these corresponded to language IDs for us)
SAMPLE_RATE <- 16000 # sampling rate of extracts
NW_TIME_BANDWIDTH <- 4 # time-bandwidth parameter for multitaper spectrum (nw)
K_TAPERS <- 8 # number of tapers for multitaper spectrum (k)
OUTFILE_EXT <- 'sibilants.csv' # extension to add to the output file (if you change csv, you'll need to change code below) 

### HAVE YOU CHECKED THE REGEX AT THE END OF THE SCRIPT? ### 

################
### LET'S GO ###
################

require(tuneR)
require(multitaper)
require(stringr)

#################
### FUNCTIONS ###
#################

# location can be "beg", "mid", or "end"
getPortion <- function(frici, n_samples, fraction, location) {
        percent_samples <- fraction*n_samples
        if (location == "mid") {
        	edges <- (n_samples-percent_samples)/2
        	start <- round(edges)
        	end <- round(n_samples-edges)
        } else if (location == "end") {
			start <- n_samples-percent_samples
			end <- n_samples
		} else if (location == "beg") {
			start <- 1
			end <- percent_samples
		}
        frici <- frici[start:end]
        return(frici)
}

getSpectrum <- function(frici) {
	xi <- ts(attributes(frici)$left, frequency=SAMPLE_RATE);
    mti <- spec.mtm(xi, nw=NW_TIME_BANDWIDTH, k=K_TAPERS, plot=FALSE);
}

getCOG <- function(mti) {
	mti$freq %*% (mti$spec / sum(mti$spec))
}

getVar <- function(mti) {
	X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi,mti$freq,function(x,y) { (y-x)^2 })
    X %*% Y
}

getSkew <- function(mti, spectral.vari) {
	 X <- (mti$spec / sum(mti$spec))
     Y <- outer(cogi,mti$freq,function(x,y) { (y-x)^3 })
     skewi <- X %*% Y
     skewi / spectral.vari^(3/2)
}

getKurt <- function(mti, spectral.vari) {
	  X <- (mti$spec / sum(mti$spec))
      Y <- outer(cogi,mti$freq,function(x,y) { (y-x)^4 })
      kurti <- X %*% Y
      (kurti / spectral.vari^2) - 3
}

getSpectralPeak <- function(mti) {
	peakamp <- max(mti$spec)
    loc <- which(mti$spec == peakamp)
    mti$freq[loc]
}

getMidPeak <-function(mti, lowFreq, highFreq) {
	lowend <- which(abs(mti$freq-lowFreq)==min(abs(mti$freq-lowFreq)))
    highend <- which(abs(mti$freq-highFreq)==min(abs(mti$freq-highFreq)))
    peakamp <- max(mti$spec[lowend:highend])
    loc <- which(mti$spec[lowend:highend] == peakamp)
    mti$freq[lowend:highend][loc]
}

substrRight <- function(x, n){
    substr(x, nchar(x)-n+1, nchar(x))
    }
    
##################
### FILE LOOPS ###
##################

for (j in 1:length(subdirs)) {
    # location of sound extracts
    lang <- subdirs[j]
    mydir <- paste0(mainDir, lang)
    outfile <- paste(lang, OUTFILE_EXT, sep="_")

    # create list of files and create empty vectors for each measure
    files <- list.files(mydir, pattern="*.wav")
    cogs <- rep(NA, length(files))
    peaks <- rep(NA,length(files))
    peaks3k7k <- rep(NA,length(files))
    peaks2k6k <- rep(NA,length(files))
    specvars <- rep(NA,length(files))
    skews <- rep(NA,length(files))
    kurts <- rep(NA,length(files))
    
    for (i in 1:length(files)) {
        fi <- files[i];
        frici <- readWave(paste(mydir,fi,sep="/"));
        frici <- normalize(frici)
        n_samples <- length(frici)
        
        frici <- getPortion(frici, n_samples, 0.5, "mid") # get middle of fricative
        mti <- getSpectrum(frici) # get spectrum
        
        cogs[i] <- getCOG(mti) # get spectral COG
        specvars[i] <- getVar(mti) # get spectral variance
        skews[i] <- getSkew(mti, specvars[i]) # get spectral skewness
        kurts[i] <- getKurt(mti, specvars[i]) # get spectral kurtosis
        peaks[i] <- getSpectralPeak(mti) # get spectral peak
        peaks3k7k[i] <- getMidPeak(mti, 3000, 7000) # get peak frequency between 3k and 7k
        peaks2k6k[i] <- getMidPeak(mti, 2000, 6000) # get peak frequency between 2k and 6k 
        }

	# set up output file
    measures <- data.frame(stim=files, cog=cogs, peak=peaks, peak3k7k=peaks3k7k, peak2k6k=peaks2k6k, spectral.var=specvars, skew=skews, kurtosis=kurts)
    
	#################
	### CHANGE ME ###
	#################
 
	measures$lang <- lang
	measures$file <- gsub("_[a-zA-Z~\`\\]*_[0-9]*.wav", "", measures$stim)
	measures$file <- gsub("_[a-zA-Z]$", "", measures$file)
	measures$sib <- str_remove(measures$stim, measures$file)
	measures$sib <- gsub("_[0-9]*.wav", "", measures$sib)
	measures$sib <- gsub("^_", "", measures$sib)
	measures$trial <- str_remove(measures$stim, measures$file)
	measures$trial <- str_extract(measures$trial, "[0-9]+")
	measures$trial <- as.character(as.numeric(measures$trial))
	measures$stim <- NULL

	# save output
    write.csv(measures, paste0(outdir, outfile))
}

###########
### END ###
###########


