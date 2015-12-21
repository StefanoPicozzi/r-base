# Pull down observations from database and do plots
Sys.setenv(NOAWT = "true")

library(RColorBrewer)

source("common/globals.R")
source("common/common.R")

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']

userobsDF <- NULL
# Get observations for this programid and userid and obsname
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
if ( is.null(userobsDF) ) { stop("userobsDF is NULL") }
if ( nrow(userobsDF) == 0 ) { stop("userobsDF is empty") }

userobsDF <- tail(userobsDF, 50)
userobsDF <- subset(userobsDF, nchar(userobsDF[,"obsvalue"]) >= 2)

# extract step counts and convert to numeric:
obsvalues = as.numeric( as.character(userobsDF[, "obsvalue"]) )
obsdate <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")

fileName = paste(imagesdir, "/user/", username, "/", obsname, ".png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

if (obsname == "bmi") {
  ylim <- 22.0
}
if (obsname == "fat") {
  ylim <- 20.0
}
if (obsname == "weight") {
  ylim <- 75.0
}

plot(obsdate, obsvalues,
     type = "o",
     lty = 1,
     cex = 0.5,
     pch = 20,
     axes = FALSE,
     ylab = obsname,
     ylim = c( ylim, ceiling(max(obsvalues)) ),
     xlim = c( min(obsdate), max(obsdate) ),
     xlab = "Date",
     col = "deepskyblue1",
     cex.lab = 0.8,
     main = paste(obsname, " Plot", split = ""))

axis(1, at = obsdate, 
   labels = substr(obsdate, 1, 10), 
   cex.axis = 0.4, las = 2)

if (obsname == "bmi") {
   axis(2, at = seq( ylim, ceiling(max(obsvalues)), 0.25),
        las = 1,
        cex.axis=0.4)
   abline(h = 27.5, lty = 2)      
   abline(h = 25.0, lty = 2)   
}

if (obsname == "weight") {   
  axis(2, at = seq( ylim, ceiling(max(obsvalues)), 0.25),
       las = 1,
       cex.axis=0.4)
  abline(h = 80, lty = 2)  
  abline(h = 76, lty = 2)
}

if (obsname == "fat") {
  axis(2, at = seq( ylim, ceiling(max(obsvalues)), 0.25),
       las = 1,
       cex.axis=0.4)
  abline(h = 25, lty = 2)
  abline(h = 22, lty = 2)   
}

dev.off()

