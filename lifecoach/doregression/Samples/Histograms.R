library("xlsx")
library("lattice")
library("MASS")

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

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools")
getwd()

preData <- read.xlsx("Study1-ETL-Tool-v1.4.xls", sheetName = "PreCleanData")
dailyData <- read.xlsx("Study1-ETL-Tool-v1.4.xls", sheetName = "DailyCleanData")
dailyData <- dailyData[order(dailyData$ID, dailyData$DayNo),]
dailyData <- subset(dailyData, ID != "BG30" && DayNo <= 62)

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools/R")
getwd()

pracMinsEachDay = data.frame(
	dayNo = integer(10),
	pracMins = integer(10),
	stringsAsFactors = FALSE)
	
pracMinsDay = data.frame(
	dayNo = integer(10),
	pracMins = integer(10),
	stringsAsFactors = FALSE)

pracMinsWeek = data.frame(
	WeekNo = integer(10),
	pracMins = integer(10),
	stringsAsFactors = FALSE)

x <- 0
for (i in 1:noDays) {
	pracMinsData <- subset(dailyData, DayNo == i)
	x <- sum(pracMinsData$PracMins)
	pracMinsEachDay[i,] <- c(i, x)
}
pracMinsDay
	
x <- 0
for (i in 1:noDays) {
	pracMinsData <- subset(dailyData, DayNo == i)
	x <- x + sum(pracMinsData$PracMins)
	pracMinsDay[i,] <- c(i, x)
}
pracMinsDay

x <- 0
for (i in 1:noWeeks) {
	pracMinsData <- subset(dailyData, WeekNo == i)
	x <- x + sum(pracMinsData$PracMins)
	pracMinsWeek[i,] <- c(i, x)
}
pracMinsWeek

# Histogram of Each Day PracMins by Days
png("out/Study/pracMinsEachDay.png", 
	res = 72, 
	width = 600, 
	height = 600, 
	units = "px")
plot(pracMinsEachDay$dayNo, pracMinsEachDay$pracMins, 
	type = "l", axes = FALSE, 
	ylim = c(0, 1000), 
	xlim = c(1, noDays),
	ylab = NA, 
	xlab = "Day No.", 
	col = "deepskyblue1", 
	lwd = 6, 
	main = "Group Practice Minutes Plot")

grid()
polygon(c(1, 1:noDays, noDays), c(0, pracMinsEachDay$pracMins, 0), col = "deepskyblue1", border = NA)
par(new = T)
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek, cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 1000, by = 100), las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Daily Practice\n Minutes", pos = 3, xpd = T)
box()

dev.off()
# Histogram of cummulative PracMins by Days
png("out/Study/pracMinsDay.png", 
	res = 72, 
	width = 600, 
	height = 600, 
	units = "px")
plot(pracMinsDay$dayNo, pracMinsDay$pracMins, 
	type = "l", axes = FALSE, 
	ylim = c(0, 10000), 
	xlim = c(1, noDays), 
	ylab = NA, 
	xlab = "Day No.", 
	col = "deepskyblue1", 
	lwd = 6, 
	main = "Group Practice Minutes Plot")

grid()
polygon(c(1, 1:noDays, noDays), c(0, pracMinsDay$pracMins, 0), col = "deepskyblue1", border = NA)
par(new = T)
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek, cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 10000, by = 1000), las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Cummulative\n Daily Practice\n Minutes", pos = 3, xpd = T)
box()

dev.off()

# Histogram of cummulative PracMins by Weeks
png("out/Study/pracMinsWeek.png", 
	res = 72, 
	width = 600, 
	height = 600, 
	units = "px")
plot(pracMinsDay$dayNo, pracMinsDay$pracMins, 
	type = "l", axes = FALSE, 
	ylim = c(0, 10000), 
	xlim = c(1, noWeeks), 
	ylab = NA, 
	xlab = "Week No.", 
	col = "deepskyblue1", 
	lwd = 6, 
	main = "Group Practice Minutes Plot")

grid()
polygon(c(1, 1:noWeeks, noWeeks), c(0, pracMinsWeek$pracMins, 0), col = "deepskyblue1", border = NA)
par(new = T)
axis(1, at = seq(1, noWeeks, by = 1), cex.axis = 0.7, las = 0)
axis(2, at = seq(0, 10000, by = 1000), las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Cummulative\n Weekly Practice\n Minutes", pos = 3, xpd = T)
box()

dev.off()
