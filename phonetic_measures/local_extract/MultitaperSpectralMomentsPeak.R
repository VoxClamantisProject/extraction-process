# Multitaper Spectral Analysis on Sound Segments
# Created by Colin Wilson and Eleanor Chodroff
# 2014, 2016
# Last updated: Jul 7 2020

# This script reads in a series of sound extracts (set up here for sibilant extracts) and takes the
# following measures over the middle 50% of the extract (.wav) using a multitaper spectrum:
# COG (M1), spectral peak, 
# spectral peak between 3k7k (i.e., FreqM for alveolar sibilants), spectral peak btw 2k and 6k (FreqM for postalveolar sibilants),
# spectral variance (M2), skewness (M3), kurtosis (M4)

# For each directory of sound extracts, an output file is created with the above measures called DIRECTORYsibilants.csv

# For any further use of this script, PLEASE CITE:
# Chodroff, E., & Wilson, C. (2014). Burst spectrum as a cue for the stop voicing contrast in American English. The Journal of the Acoustical Society of America, 136(5), 2762-2772.

# ASSUMPTIONS OF THIS SCRIPT:
# - there is a directory with sibilant extracts with .wav extensions (mydir)

#################
### CHANGE ME ###
#################
mydir <- '/Users/Eleanor/xxx/extracts/' # main directory with sub-folders of sound extracts
outdir <- '/Users/Eleanor/Desktop/' # output directory for text file
SAMPLE_RATE <- 16000 # sampling rate of extracts

NW_TIME_BANDWIDTH <- 4 # time-bandwidth parameter for multitaper spectrum (nw)
K_TAPERS <- 8 # number of tapers for multitaper spectrum (k)

outfile <- 'sibilants.csv' # extension to add to the output file (if you change csv, you'll need to change code below) 

################
### LET'S GO ###
################

require(tuneR)
require(multitaper)

#################
### FUNCTIONS ###
#################

# location can be "beg", "mid", or "end"
getPortion <- function(frici, n_samples, fraction, location) {
        percent_samples <- fraction * n_samples
        if (location == "mid") {
        	edges <- (n_samples - percent_samples)/2
        	start <- round(edges)
        	end <- round(n_samples - edges)
        } else if (location == "end") {
			start <- n_samples - percent_samples
			end <- n_samples
		} else if (location == "beg") {
			start <- 1
			end <- percent_samples
		}
        frici <- frici[start:end]
        return(frici)
}

getSpectrum <- function(frici) {
	xi <- ts(attributes(frici)$left, frequency = SAMPLE_RATE)
    mti <- spec.mtm(xi, nw = NW_TIME_BANDWIDTH, k = K_TAPERS, plot = FALSE)
    	return(mti)
}

getSpectralMoments <- function(mti) {
    # cog
	cogi <- mti$freq %*% (mti$spec / sum(mti$spec))
    
    # variance
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^2 })
    spectral.vari <- X %*% Y
    
    # skewness
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^3 })
    skewi <- X %*% Y
    skewi <- skewi / spectral.vari^(3/2)
    
    # kurtosis
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^4 })
    kurti <- X %*% Y
    kurti <- (kurti / spectral.vari^2) - 3
    
    spectralMoments <- c(cogi, spectral.vari, skewi, kurti)
    return(spectralMoments)
}

getSpectralPeak <- function(mti) {
	peakamp <- max(mti$spec)
    loc <- which(mti$spec == peakamp)
    peaki <- mti$freq[loc]
    return(peaki)
}

getSpectralPeakAmp <- function(mti) {
	peakamp <- max(mti$spec)
}

getMidPeak <-function(mti, lowFreq, highFreq) {
	lowend <- which(abs(mti$freq - lowFreq) == min(abs(mti$freq - lowFreq)))
    highend <- which(abs(mti$freq - highFreq) == min(abs(mti$freq - highFreq)))
    peakamp <- max(mti$spec[lowend:highend])
    loc <- which(mti$spec[lowend:highend] == peakamp)
    midPeaki <- mti$freq[lowend:highend][loc]
    return(midPeaki)
}

##################
### FILE LOOPS ###
##################
  	# create list of files and create empty vectors for each measure
    files <- list.files(mydir, pattern = "*.wav")
    cogs <- rep(NA, length(files))
    peaks <- rep(NA, length(files))
    peakamps <- rep(NA, length(files))
    peaks3k7k <- rep(NA, length(files))
    peaks2k6k <- rep(NA, length(files))
    specvars <- rep(NA, length(files))
    skews <- rep(NA, length(files))
    kurts <- rep(NA, length(files))
    
for (i in 1:length(files)) {
	fi <- files[i]
	frici <- readWave(paste(mydir,fi,sep = "/"))
	frici <- normalize(frici)
	n_samples <- length(frici)
        
	frici <- getPortion(frici, n_samples, 0.5, "mid") # get middle 50% of fricative
	mti <- getSpectrum(frici) # get spectrum
        
    spectralMomentsi <- getSpectralMoments(mti)
    cogs[i] <- spectralMomentsi[1] # get spectral COG
    specvars[i] <- spectralMomentsi[2] # get spectral variance
    skews[i] <- spectralMomentsi[3] # get spectral skewness
    kurts[i] <- spectralMomentsi[4] # get spectral kurtosis
        
	peaks[i] <- getSpectralPeak(mti) # get spectral peak
	peakamps[i] <- getSpectralPeakAmp(mti) # get amplitude of spectral peak
	peaks3k7k[i] <- getMidPeak(mti, 3000, 7000) # get peak frequency between 3k and 7k (Koenig et al., 2013)
	peaks2k6k[i] <- getMidPeak(mti, 2000, 6000) # get peak frequency between 2k and 6k (Koenig et al., 2013)
}

# set up output file
measures <- data.frame(stim = files, cog = cogs, peak = peaks, peakamp = peakamps, peak3k7k = peaks3k7k, peak2k6k = peaks2k6k, spectral.var = specvars, skew = skews, kurtosis = kurts)


# save output
write.csv(measures, paste0(outdir, outfile), row.names = F, quote = F)

###########
### END ###
###########


