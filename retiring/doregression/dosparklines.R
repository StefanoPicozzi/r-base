#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library("ggplot2")
library("rjson")
library("xts")

# Default test case
if ( !exists("userid") ) { userid <- 7 }
if ( !exists("programid") ) { programid <- 1 }

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

noDays <- 62
noWeeks <- 10

dayOfWeek <- c(
  "1-Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "2-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "3-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "4-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "5-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "6-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "7-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "8-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
  "9-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu"
)

user <- getUser(rooturl, userid)
username <- user['username']

fileName = paste(imagesdir, "/lifecoach/user/", username, "/sparklines.png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

par(mfrow = c(6, 1), mar = c(3, 4, 2, 1), oma = c(4, 0, 1, 2))
#  	par(mfrow = c(6, 1), mar = c(5, 4, 2, 4) + 0.1, oma = c(4, 0, 2, 2) )

# Weight sparkline
obsname <- "weight"
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
obsdate <- as.POSIXct(userobsDF[, "obsdate"], format="%Y-%m-%d %H:%M:%S")
obsdatestr <- userobsDF[, "obsdate"]
startday <- as.POSIXct(as.Date(max(obsdate))-14, format="%Y-%m-%d %H:%M:%S")
startdaystr <- as.Date(startday)
lastday <- max(obsdate)

userobsDF <- subset(userobsDF, obsdate >= startday)
obsdate <- as.POSIXct(userobsDF[, "obsdate"], format="%Y-%m-%d %H:%M:%S")
obsvalue <- as.numeric(userobsDF[, "obsvalue"])
len <- nrow(userobsDF)
maxY <- max(obsvalue)
minY <- min(obsvalue)

plot(obsdate, obsvalue, axes=F, ylab="", xlab ="", main="", type="l")
mtext("Daily Dashboard\n Last 14 Days of Recordings", cex = 0.8)

axis(2, at=seq(minY, maxY, by=0.1), ylim=c(minY, maxY), las=2, cex.axis=0.7)
#axis(2, ylim=c(minY, maxY), las=2, cex.axis=0.7)
lastY <- userobsDF[, "obsvalue"][len]


points(x=lastday, y=lastY, col="deepskyblue1", pch=19, cex=4)
text(x = lastday, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
text(x = lastday, y = lastY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
text(x = lastday, y = minY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
loc <- par("usr")
text(loc[1], loc[4], "Weight", pos = 3, xpd = T)

#axis(1, pos = c(-1), at=seq(startday, lastday, by=1), cex = 0.7)    
axis(1, pos = c(-1), at=obsdate, xlim=c(startday, lastday), labels=as.Date(obsdate), cex = 0.7)    
loc <- par("usr")
mtext("    Day No.", adj = 0, side = 1, outer = TRUE, cex = 0.7)    

dev.off()

ououtouytou

# Activity sparkline
obsname <- "activity"
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

plot(userobsDF[, "obsdate"], userobsDF[, "obsvalue"], axes = F, ylab = "", xlab = "", main = "", type = "l")
mtext("Daily Dashboard\n Last 14 Days of Recordings", cex = 0.8)
axis(2, at = seq(0, 120, by = 20), las = 2, cex.axis = 0.7)
lastY <- userobsDF[, "obsvalue"][len]
maxY <- max(userobsDF[, "obsvalue"])
minY <- min(userobsDF[, "obsvalue"])

points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 2)
text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
text(x = lastDay, y = lastY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
text(x = lastDay, y = minY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
loc <- par("usr")
text(loc[1], loc[4], "Steps", pos = 3, xpd = T)
    
dev.off()
