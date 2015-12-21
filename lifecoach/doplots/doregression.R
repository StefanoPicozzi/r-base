#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library("xts")

source("common/globals.R")
source("common/common.R")

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
userobss <- getUserobs(rooturl, programid, userid, obsname)
user <- getUser(rooturl, userid)
username <- user['username']

obsdate <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")
obsdatestr <- userobsDF[, "obsdate"]
obsvalue <- as.numeric(userobsDF[, "obsvalue"])

reg1 <- lm(obsvalue ~ obsdate)
reg3 <- lm(obsvalue ~ poly(obsdate, 3))
smooth <- predict(loess(obsvalue ~ as.numeric(obsdate)))

xlimlo <- min(obsdate)
xlimhi <- max(obsdate)
ylimlo <- as.integer(min(obsvalue)) - 2
ylimhi <- as.integer(max(obsvalue)) + 2
yearmon <- as.yearmon(obsdate, "%YM%m")

fileName = paste(imagesdir, "/user/", username, "/", obsname, "reg.png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

p <- plot(obsdate, smooth,
     type = "l",
     lwd = 4,
     axes = "FALSE",
     xlim = c(xlimlo, xlimhi),
     ylim = c(ylimlo, ylimhi),
     ylab = "Weight",
     xlab = "",
     col = "deepskyblue1",
     main = paste(obsname, " Plot", sep="") )

dates <- seq(xlimlo, by = "weeks", length=52)
axis(1, at = dates, labels=c(substr(as.Date(dates), 1, 10)), cex.axis = 0.4, las = 2)
axis(2, at = seq(ylimlo, ylimhi, by = 1), cex.axis = 0.7, las = 2)

abline(h = 80, lty=2, lwd=1, col="gray48")  
abline(h = 76, lty=2, lwd=1, col="gray48")

#lines(obsdate, predict(reg1, obsdate), lwd = 1, col="gray68" )
lines(obsdate, predict(reg3, obsdate), lwd = 2, col="darkorange" )
lines(obsdate, obsvalue, lwd=0.5, col="gray78" )

print(p)

dev.off()   
