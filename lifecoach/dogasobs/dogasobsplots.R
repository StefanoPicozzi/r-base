# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)

# Default test case
if ( !exists("userid") ) { userid <- 7 }
if ( !exists("programid") ) { programid <- 1 }
if ( !exists("obsname") ) { obsname <- "gas31" }

rooturl <- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <- "~/GitHub/tnmbatch/R/lifecoach/dowithings"
imagesdir <- "~/websites/nudge/images"
ppi <- 300

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
userobss <- getUserobs(rooturl, programid, userid, obsname)
user <- getUser(rooturl, userid)
username <- user['username']

userobsDF <- tail(userobsDF, 52)

x <- c()
for (i in 1:nrow(userobsDF)) {
   x <- append(x, userobsDF[i, 'obsvalue'])   
}

if (length(x) > 0) {
   polldesc <- "Goal Attainment Scale Results"
   
   dir.create(file.path( paste(imagesdir, "/lifecoach/user/", username, sep="") ), showWarnings = FALSE)
   filenamebp = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, "bp.png", sep = "")
   filenamexy = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, "xy.png", sep = "")
   
   # GAS Bar Plot
   png(filenamebp,
       res = ppi,
       width = 5*ppi,
       height = 4*ppi,
       pointsize = 10,
       units = "px")
   
   ylim <- c(0, 100)
   xpct <- ( table(x)/sum(table(x)) ) * 100
   
   bp <- barplot(xpct,
                 xaxt = "n",
                 ylab = "Outcome Percentage",
                 ylim = ylim,
                 axes = FALSE,
                 xlab = "Goal Attainment Scale Outcome",
                 col = "deepskyblue1",
                 main = polldesc,
                 cex.lab = 0.8)
   text(x = bp, y = xpct, label = table(x), pos = 3, cex.axis = 0.6, col = "red")
   
   xunique <- unique(unlist(x, use.names = FALSE))
   if (length(xunique) == 5) {
      axis(1, at = bp, 
           labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),   
           tick = FALSE,
           las = 2,
           line = -0.5,
           cex.axis=0.6)
   } else {
      axis(1, at = bp,
           labels = unique(x),
           tick = FALSE,
           las = 2,
           line = -0.5,
           cex.axis=0.6)
   }
   axis(2, at = seq(0, 100, by = 10), srt = 45, cex.axis = 0.6)
   
   dev.off()
   
   obsdate <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")
   obsvalue <- userobsDF[, "obsvalue"]
      
   png(filenamexy,
       res = ppi,
       width = 5*ppi,
       height = 4*ppi,
       pointsize = 10,
       units = "px")
   
   plot(obsdate, obsvalue,
        type = "b",
        axes = FALSE,
        ylab = "Outcome",
        ylim = c(-2, 2),
        xlim = c( min(obsdate), max(obsdate) ),
        xlab = "Date",
        col = "deepskyblue1",
        main = polldesc )
   
   axis(2, at = seq(-2, 2, by = 1), 
        labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
        cex.axis = 0.4, las = 2, srt = 45)
   axis(1, at = obsdate, labels = substr(obsdate, 6, 10), cex.axis = 0.4, las = 2)
   
   grid()
   
   loc <- par("usr")
   box()
   dev.off()   
   
}
