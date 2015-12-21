#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/lifecoach/dofitbit"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../common/common.R")

getProgramruleuserDF <- getProgramruleuserDF(rooturl, 1, 58) 
