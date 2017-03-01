#!/usr/bin/Rscript

## import optparse library
suppressPackageStartupMessages(library("optparse"))

## specify our desired options in a list
## by default OptionParser will add an help option equivalent to
## make_option(c("-h", "--help"), action="store_true", default=FALSE,
## help="Show this help message and exit")
option_list <- list(
   make_option(c("-i", "--inputData"), 
               help="Full path to the input NMR spectra data, required."),
   make_option(c("-o", "--output"), 
               help="[Export BATMAN results to your specified folder, defaults to current working directory.]", 
               default = getwd()),
   make_option(c("-p", "--batOptions"), 
               help="[BATMAN options, default available internally]"),
   make_option(c("-u", "--multiData"), 
               help="[User's metabolites template, defaults to an internal template.]"),
   make_option(c("-l", "--metaList"), 
               help="[List of wanted metabolites, defaults to an internal metabolites list.]")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
parser <- OptionParser(option_list=option_list)
opt <- parse_args(parser)

## Run BATMAN
library(batman)
bm<-batman(txtFile=opt$inputData, batmanOptions=opt$batOptions, multiDataUser=opt$multiData, metaList=opt$metaList,  runBATMANDir=opt$output)
## Create link to simplify results obtention for tools like 
## Galaxy.
resultsDir<-paste(opt$output,"results",sep="/")
file.remove(resultsDir)
file.symlink(bm$output,resultsDir)