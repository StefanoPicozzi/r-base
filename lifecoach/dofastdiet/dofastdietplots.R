#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library(plyr)
library(scales)
#library(rgl)

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/lifecoach/dofastdiet"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../../common/common.R")

# Do programid=1 and weight observations
programid <- 1
obsname <- "weight"

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

dir.create(file.path( paste(imagesdir, "/lifecoach/user/", sep="") ), showWarnings = FALSE)

Sys.sleep(1)
userobsDF <- c()
for (programuser in programusers) {
   if (programuser$roletype != "participant") { next }
   userid <- programuser["userid"]
   if (userid != 7) { next }
   
   user <- getUser(rooturl, userid)
   username <<- user['username']
   userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)   
   userobsDF <- as.data.frame(userobsDF, stringsAsFactors=FALSE)
   userobsDF[, "obsvalue"] <- as.numeric(as.character(userobsDF[, "obsvalue"]))
   userobsDF[, "id"] <- as.numeric(as.character(userobsDF[, "id"]))
   userobsDF[, "obsdate"] <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")
   userobsDF <- cbind(userobsDF, obsdatelabel=substring(userobsDF[, "obsdate"], 1, 10))
   obsdatelabel <- substring(userobsDF[, "obsdate"], 1, 10)
   
   userdiaryDF <- getUserdiaryDF(rooturl, programid, userid)   
   userdiaryDF <- cbind(userdiaryDF, diarydatelabel=substring(userdiaryDF[, "diarydate"], 1, 10), obsvalue=0)
   userdiaryDF <- as.data.frame(userdiaryDF, stringsAsFactors=FALSE)   
}

filenamexy = paste(imagesdir, "/lifecoach/user/", username, "/fastdiet.png", sep = "")
png(filenamexy,
  res = ppi,
  width = 5*ppi,
  height = 4*ppi,
  units = "px")

ggplot(userobsDF, aes(x=factor(obsdatelabel), y=obsvalue, group=username)) +
  geom_line(size=0.5) +
  geom_point(size=2, shape=1) +
  theme(axis.text.x=element_text(size=3, angle=45, hjust=1)) +
  theme(axis.text.y=element_text(size=4)) +
  theme(axis.title=element_text(size=10)) +
  xlab("Observation Date") +
  ylab("Weight") +
  geom_hline(yintercept=80, linetype="dashed") +
  scale_y_continuous(breaks=seq(70, 90, by=0.25)) +
  annotate("text", size=2, x="2015-04-03", y=83.25, label="Easter 4 day break") +
  annotate("rect", xmin="2015-04-03", xmax="2015-04-07", ymin=77, ymax=83, alpha=0.1, fill="blue") +
  annotate("text", size=2, x="2015-03-15", y=79, label="Conference 5 days") +
  annotate("rect", xmin="2015-03-15", xmax="2015-03-19", ymin=77, ymax=83, alpha=0.1, fill="blue") +
  annotate("text", size=2, x="2015-03-07", y=77, label="Vacation 1 week") +
  annotate("rect", xmin="2015-03-07", xmax="2015-03-13", ymin=77, ymax=83, alpha=0.1, fill="blue") +
  annotate("text", size=2, x="2015-02-01", y=77, label="Start Fast Diet") +
  annotate("rect", xmin="2015-02-01", xmax="2015-02-02", ymin=77, ymax=83, alpha=0.1, fill="blue")
  
  

#  source("annotate-stefano.R", echo=TRUE)

#for(i in 1:nrow(userdiaryDF)) {
#  diary <- userdiaryDF[i,]
#  annotate("text", size=2, x=diary$diarydatelabel, y=81, label=diary$diarylabel)
#}

dev.off()
