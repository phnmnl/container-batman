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

#if(!("inputData" %in% names(opt))) {
#  print("no input argument given!")
#  print_help(parser)
#  q(status = 1,save = "no")
#}

## function of replacing "\" to "/" because "\" is interpreted as "\\" 
## parsing the arguments
replaceBSlash<-function(paths)
{
   # Path '\' in arguments will be read as '\\', needs to be replaced by '/'
   backslash <- grepl('\\\\',paths)
   sep <- if(backslash) '\\\\' else '/'
   tempPath <-as.list(strsplit(paths,sep)[[1]])
   if (backslash) {
      i<-1
      path<-paste(tempPath[1],"/",sep="")
      i<-2
      while (i<length(tempPath)) {
         path1temp<-paste(tempPath[i],"/", sep="")
         path<-paste(path,path1temp,sep="")
         i<-i+1
      }
     path1temp<-paste(tempPath[i], sep="")
     path<-paste(path,path1temp,sep="")
     newPath<-path
   } else {
     newPath<-paths
   }
}

#if (is.null(opt$inputData)) {
#  print("using default trial data set.")
#} else {
#  opt$inputData<-replaceBSlash(opt$inputData) 
#}
#if (is.null(opt$output)) {
#  print("using default output directory.")
#} else {
#  opt$output<-replaceBSlash(opt$output)
#}

## copy the options, metabolites template and list to the BATMAN
## input folder is the files are provided

#if ("batOptions" %in% names(opt)) {
#  opt$batOptions<-replaceBSlash(opt$batOptions)
#} else {
#  print("using default BATMAN options")
#}

#if ("multiData" %in% names(opt)) {
#  opt$multiData<-replaceBSlash(opt$multiData)
#} else {
#  print("using default BATMAN metabolites template")
#}

#if ("metaList" %in% names(opt)) {
#  opt$metaList<-replaceBSlash(opt$metaList)
#} else {
#  print("using default BATMAN metabolites list")
#}

#batmanInputDir<-paste(opt$output, "/runBATMAN/BatmanInput", sep="")
#dir.create(batmanInputDir,recursive = TRUE)
#if (dir.exists(batmanInputDir)) {
   # BATMAN expects file names with a defined name, but this is not 
   # something that we can guarantee if the user is providing the files.
   # So we make sure that files get the names that they need. This is inherited
   # bad design from BATMAN itself, this should be fixed down the line to
   # accept arguments instead of assuming names.
#   if (!is.null(opt$batOptions)) {
#      file.copy(opt$batOptions, batmanInputDir, overwrite = TRUE)
#   }
#   if (!is.null(opt$multiData)) {
#      file.copy(opt$multiData, batmanInputDir, overwrite = TRUE)
#   }
#   if (!is.null(opt$metaList)) {
#      file.copy(opt$metaList, batmanInputDir, overwrite = TRUE)
#   }   
#} 

## Run BATMAN
library(batman)
bm<-batman(txtFile=opt$inputData, batmanOptions=opt$batOptions, multiDataUser=opt$multiData, metaList=opt$metaList,  runBATMANDir=opt$output)
## Create link to simplify results obtention for tools like 
## Galaxy.
plotDiagnosticScatter(bm)
resultsDir<-paste(opt$output,"results",sep="/")
if (!file.exists(resultsDir)) {dir.create(resultsDir)}
zipfile_output<-paste(resultsDir, "zip_output", sep="/")
zip(zipfile=zipfile_output,files=bm$outputDir)

## keep RelCon.txt, MultipletsPpmShifts.txt, and RelConCreInt.txt for user review in page
#find the specific files need to be copied
file2copy1<-dir(bm$outputDir, pattern = 'RelCon.txt')
#get the full path to the files to be copied
file2copy<-paste(bm$outputDir, file2copy1,sep='/')
#copy the files
file.copy(file2copy, resultsDir, recursive = TRUE)

#find the specific files need to be copied
file2copy1<-dir(bm$outputDir, pattern = 'MultipletsPpmShifts.txt')
#get the full path to the files to be copied
file2copy<-paste(bm$outputDir, file2copy1,sep='/')
#copy the files
file.copy(file2copy, resultsDir, recursive = TRUE)

#find the specific files need to be copied
file2copy1<-dir(bm$outputDir, pattern = 'RelConCreInt.txt')
#get the full path to the files to be copied
file2copy<-paste(bm$outputDir, file2copy1,sep='/')
#copy the files
file.copy(file2copy, resultsDir, recursive = TRUE)

#find the specific files need to be removed
file2remove1<-dir(bm$outputDir, pattern = '*.txt')
#get the full path to the files to be removed
file2remove<-paste(bm$outputDir, file2remove1,sep='/')
#remove the files
file.remove(file2remove)
#find the specific files need to be removed
file2remove1<-dir(bm$outputDir, pattern = '*.dat')
#get the full path to the files to be removed
file2remove<-paste(bm$outputDir, file2remove1,sep='/')
#remove the files
file.remove(file2remove)
#find the specific files need to be removed
file2remove1<-dir(bm$outputDir, pattern = '*.csv')
#get the full path to the files to be removed
file2remove<-paste(bm$outputDir, file2remove1,sep='/')
#remove the files
file.remove(file2remove)

#find the specific files need to be copied
file2copy1<-dir(bm$outputDir, pattern = '*.pdf')
#get the full path to the files to be copied
file2copy<-paste(bm$outputDir, file2copy1,sep='/')
#copy the files
file.copy(file2copy, resultsDir, recursive = TRUE)

#file.remove(resultsDir)
#file.symlink(bm$outputDir,resultsDir)

#if (is.null(opt$inputData) & is.null(opt$output) ) {
#  bm <-batman()
#} else {
#  bm<-batman(txtFile=opt$inputData, runBATMANDir=opt$output)
  ## Create link to simplify results obtention for tools like 
  ## Galaxy.
#  resultsDir<-paste(opt$output,"results",sep="/")
#  file.remove(resultsDir)
#  file.symlink(bm$output,resultsDir)
#}
