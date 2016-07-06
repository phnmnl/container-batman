#!/usr/bin/env Rscript

## check if "optparse" is installed
package_installed<-require("optparse")
print(package_installed)
## install the package "optparse" if it wasn't installed.
if (!package_installed)
{
   install.packages("optparse", repos="http://cran.us.r-project.org")
}

## import optparse library
suppressPackageStartupMessages(library("optparse"))

## specify our desired options in a list
## by default OptionParser will add an help option equivalent to
## make_option(c("-h", "--help"), action="store_true", default=FALSE,
## help="Show this help message and exit")
option_list <- list(
   make_option(c("-i", "--inputData"), help="Full path to the input NMR spectra data"),
   make_option(c("-o", "--output"), help="Export BATMAN results to your specified folder"),
   make_option(c("-p", "--batOptions"), help="Upload BATMAN options, if there is no this option, using the default BATMAN options"),
   make_option(c("-u", "--multiData"), help="Upload user's metabolites template, if there is no this option, using the default template"),
   make_option(c("-l", "--metaList"), help="Upload a list of wanted metabolites, if there is no this option, using the default metabolites list")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list=option_list))

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

if (is.null(opt$inputData)) {
  print("using default trial data set.")
} else {
  opt$inputData<-replaceBSlash(opt$inputData) 
}
if (is.null(opt$output)) {
  print("using default output directory.")
} else {
  opt$output<-replaceBSlash(opt$output)
}

## copy the options, metabolites template and list to the BATMAN
## input folder is the files are provided

if (is.null(opt$batOptions)) {
   print("using default BATMAN options")
} else {
   opt$batOptions<-replaceBSlash(opt$batOptions)
}

if (is.null(opt$multiData)) {
   print("using default BATMAN metabolites template")
} else {
   opt$multiData<-replaceBSlash(opt$multiData)
}

if (is.null(opt$metaList)) {
   print("using default BATMAN metabolites list")
} else {
   opt$metaList<-replaceBSlash(opt$metaList)
}

batmanInputDir<-paste(getwd(), "/runBATMAN/BatmanInput", sep="")
if (dir.exists(batmanInputDir)) {
   if (!is.null(opt$batOptions)) {
      file.copy(opt$batOptions, batmanInputDir, overwrite = TRUE)
   }
   if (!is.null(opt$multiData)) {
      file.copy(opt$multiData, batmanInputDir, overwrite = TRUE)
   }
   if (!is.null(opt$metaList)) {
      file.copy(opt$metaList, batmanInputDir, overwrite = TRUE)
   }   
} 

## Run BATMAN
library(batman)
bm<-batman(txtFile=opt$inputData)
## Read BATMAN results path
resultsDir<-paste(bm$outputDir)
## Copy BATMAN results to the specified folder
list.of.files<-list.files(resultsDir, full.names=TRUE)
file.copy(list.of.files,opt$output)

q(save="no")
