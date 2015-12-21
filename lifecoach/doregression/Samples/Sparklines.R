library("lattice")
library("MASS")
#library("YaleToolkit")

ppi <- 300
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

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools/R")
getwd()

preData <- read.delim("Pre.csv", header = T, sep = ",")
dailyData <- read.delim("Daily.csv", header = T, sep = ",")
dailyData <- dailyData[order(dailyData$ID, dailyData$DayNo),]

dailyData[1:5]

participants <- preData$ID
list = c()
for (p in participants) {
  list <- append(list, p)
}
print(list)
	
for (p in list) {
	
	print(paste("------>", p))
	pDailyData <- c()
	pDailyData <- subset( dailyData, ID == p)

	if (nrow(pDailyData) < 1) { next }
	
	startDay <- max(pDailyData$DayNo) - 14
	lastDay <- max(pDailyData$DayNo)
	pDailyData <- subset( pDailyData, DayNo >= startDay)
	len <- nrow(pDailyData)
	
	if ( p == "PR63" ) {
		print(pDailyData[1:5])
	}
	
	fileName = paste("out/Daily/Participant/", p, "/sparklines.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 800,
		height = 800,
		pointsize = 16,
		units = "px")

  	par(mfrow = c(6, 1), mar = c(3, 4, 2, 1), oma = c(4, 0, 1, 2))
#  	par(mfrow = c(6, 1), mar = c(5, 4, 2, 4) + 0.1, oma = c(4, 0, 2, 2) )

  	plot(pDailyData$DayNo, pDailyData$PracMins, axes = F, ylab = "", xlab = "", main = "", type = "l")
    mtext("Daily Dashboard\n Last 14 Days of Recordings", cex = 0.8)
  	axis(2, at = seq(0, 120, by = 20), las = 2, cex.axis = 0.7)
  	lastY <- pDailyData$PracMins[len]
  	maxY <- max(pDailyData$PracMins)
  	minY <- min(pDailyData$PracMins)
 
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 2)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = lastY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = minY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "Practice Mins", pos = 3, xpd = T)

  	plot(pDailyData$DayNo, pDailyData$PQMScore, axes = F, ylab = "", xlab = "", main = "", type = "l")
  	axis(2,  at = seq(0, 10, by = 1), las = 2, cex.axis = 0.7)
  	lastY <- pDailyData$PQMScore[len]
#  	maxY <- max(pDailyData$PQMScore)
#  	minY <- min(pDailyData$PQMScore)
  	
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 1)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = lastY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = minY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "Practice Quality", pos = 3, xpd = T)
    
 	plot(pDailyData$DayNo, pDailyData$MAASScore, axes = F, ylab = "", xlab = "", main = "", type = "l")
  	axis(2, at = seq(0, 10, by = 1), las = 2, cex.axis = 0.7)
  	lastY = pDailyData$MAASScore[len]
#   maxY <- max(pDailyData$MAASScore)
#  	minY <- min(pDailyData$MAASScore)
  	
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 1)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = maxY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = maxY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "MAAS Score", pos = 3, xpd = T)
      	
 	plot(pDailyData$DayNo, pDailyData$WellScore,, axes = F, ylab = "", xlab = "", main = "", type = "l")
  	axis(2, at = seq(0, 30, by = 2), las = 2, cex.axis = 0.7)
  	lastY <- pDailyData$WellScore[len]
#  	maxY <- max(pDailyData$WellScore)
#  	minY <- min(pDailyData$WellScore)
  	
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 1)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = maxY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = maxY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "Wellbeing Score", pos = 3, xpd = T)

 	plot(pDailyData$DayNo, pDailyData$PANASNAScore,, axes = F, ylab = "", xlab = "", main = "", type = "l")
  	axis(2, at = seq(0, 30, by = 2), las = 2, cex.axis = 0.7)
  	lastY <- pDailyData$PANASNAScore[len]
#  	maxY <- max(pDailyData$PANASNAScore)
#  	minY <- min(pDailyData$PANASNAScore)
  	
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 1)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = maxY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = maxY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "PANAS-NA Score", pos = 3, xpd = T)
    
 	plot(pDailyData$DayNo, pDailyData$PANASPAScore,, axes = F, ylab = "", xlab = "", main = "", type = "l")
  	axis(2, at = seq(0, 30, by = 2), las = 2, cex.axis = 0.7)
  	lastY <- pDailyData$PANASPAScore[len]
#  	maxY <- max(pDailyData$PANASPAScore)
#  	minY <- min(pDailyData$PANASPAScore)
  	
  	points(x = lastDay, y = lastY, col = "deepskyblue1", pch = 19, cex = 1)
  	text(x = lastDay, y = maxY, labels = maxY, pos = 1, cex = 1.5, col = "green", offset = 0.8)
  	text(x = lastDay, y = maxY, labels = lastY, pos = 1, cex = 1.5, col = "blue", offset = 2.0)
  	text(x = lastDay, y = maxY, labels = minY, pos = 1, cex = 1.5, col = "red", offset = 3.4)
	loc <- par("usr")
    text(loc[1], loc[4], "PANAS-PA Score", pos = 3, xpd = T)
    
    axis(1, pos = c(-1), at = seq(startDay, lastDay, by = 1), cex = 0.7)    
	loc <- par("usr")
    mtext("    Day No.", adj = 0, side = 1, outer = TRUE, cex = 0.7)    
    
 	dev.off()

#sparklines(dailySparks)

}