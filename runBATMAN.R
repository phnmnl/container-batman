#!/usr/bin/Rscript

## Collect arguments
args <- commandArgs(TRUE)
 
## Display help information when no enough arguments passed
if(length(args) < 4) {
  args <- c("--help")
}

## Help section
if("--help" %in% args) {
  cat(" 
      The R Script
 
      Arguments:
      arg1: someValue   - input NMR data
      arg2: someValue   - output directory
      --help            - print this text
 
      Example:
      ./test.R -i \"input NMR data\" -o \"output directory(for example: \"C:/temp\") \"  \n\n")
 
  q(save="no")
}

## Parse arguments -- for import NRM data
if (args[1]=="-i") {
   batmanData<-args[2]
} else if (args[3]=="-i") {
   batmanData<-args[4]
}
# Path '\' in arguments will be read as '\\', needs to be replaced by '/'
backslash <- grepl('\\\\',batmanData)
sep <- if(backslash) '\\\\' else '/'
tempPath <-as.list(strsplit(batmanData,sep)[[1]])
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
  batmanData<-path
}

## Parse arguments -- for export BATMAN test resutls to a folder on local drive
if (args[1]=="-o") {
   cpbatmanOutputDir<-args[2]
} else if (args[3]=="-o") {
   cpbatmanOutputDir<-args[4]
}
# Path '\' in arguments will be read as '\\', needs to be replaced by '/'
backslash <- grepl('\\\\',cpbatmanOutputDir)
sep <- if(backslash) '\\\\' else '/'
tempPath <-as.list(strsplit(cpbatmanOutputDir,sep)[[1]])
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
   cpbatmanOutputDir<-path
}
## Run BATMAN
library(batman)
bm<-batman(txtFile=batmanData)
## Read BATMAN results path
resultsDir<-paste(bm$outputDir)
## Copy BATMAN results to the specified folder
list.of.files<-list.files(resultsDir, full.names=TRUE)
file.copy(list.of.files,cpbatmanOutputDir)

q(save="no")