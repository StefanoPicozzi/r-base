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

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools/R")
getwd()

preData <- read.delim("Pre.csv", header = T, sep = ",") 
dailyData <- read.delim("Daily.csv", header = T, sep = ",") 
dailyData <- dailyData[order(dailyData$ID, dailyData$DayNo),]
preData <- preData[order(preData$ID),]

participants <- preData$ID
list = c()
for (p in participants) {
	list <- append(list, p)
}
print(list)

regPracMins <- lm(dailyData$PracMins ~ dailyData$DayNo)
regPQMScore <- lm(dailyData$PQMScore ~ dailyData$DayNo)
regMAASScore <- lm(dailyData$MAASScore ~ dailyData$DayNo)
regWellScore <- lm(dailyData$WellScore ~ dailyData$DayNo)
regPANASNAScore <- lm(dailyData$PANASNAScore ~ dailyData$DayNo)
regPANASPAScore <- lm(dailyData$PANASPAScore ~ dailyData$DayNo)

regPracMins3 <- lm(dailyData$PracMins ~ poly(dailyData$DayNo,3) )
regPQMScore3 <- lm(dailyData$PQMScore ~ poly(dailyData$DayNo,3) )
regMAASScore3 <- lm(dailyData$MAASScore ~ poly(dailyData$DayNo,3) )
regWellScore3 <- lm(dailyData$WellScore ~ poly(dailyData$DayNo,3) )
regPANASNAScore3 <- lm(dailyData$PANASNAScore ~ poly(dailyData$DayNo,3) )
regPANASPAScore3 <- lm(dailyData$PANASPAScore ~ poly(dailyData$DayNo,3) )


# PracMIns Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/pracMinsGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$PracMins,
		type = "p",
		axes = FALSE,
		ylim = c(0, 100),
		xlim = c(1, noDays),
		ylab = NA,
		xlab = "Day No.",
		col = "deepskyblue1",
		main = "Practice Minutes Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 100, by = 10), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily Practice\n Minutes", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regPracMinsIndiv <- lm(participantDailyData$PracMins ~ participantDailyData$DayNo)
		abline(regPracMinsIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regPracMinsGroup <- lm(participantDailyData$PracMins ~ participantDailyData$DayNo)
				abline(regPracMinsGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}

	lines(predict(regPracMins3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regPracMins,	lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}


# PQM Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/pqmScoreGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$PQMScore,
		type = "p",
		axes = FALSE,
		ylab = NA,
		xlab = "Day No.",
    xlim = c(1, noDays), 
		col = "deepskyblue1",
		main = "PQM Score Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 10, by = 1), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily PQM Score", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regPQMScoreIndiv <- lm(participantDailyData$PQMScore ~ participantDailyData$DayNo)
		abline(regPQMScoreIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regPQMScoreGroup <- lm(participantDailyData$PQMScore ~ participantDailyData$DayNo)
				abline(regPracMinsGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}

	lines(predict(regPQMScore3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )	
	abline(regPQMScore,	lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}

# MAAS Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/maasScoreGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$MAASScore,
		type = "p",
		axes = FALSE,
		ylab = NA,
		xlab = "Day No.",
	  xlim = c(1, noDays),    
    col = "deepskyblue1",
		main = "MAAS Score Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 10, by = 1), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily MAAS Score", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regMAASScoreIndiv <- lm(participantDailyData$MAASScore ~ participantDailyData$DayNo)
		abline(regMAASScoreIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regMAASScoreGroup <- lm(participantDailyData$MAASScore ~ participantDailyData$DayNo)
				abline(regMAASScoreGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}
	
	lines(predict(regMAASScore3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regMAASScore, lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}

# Well Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/wellScoreGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$WellScore,
		type = "p",
		axes = FALSE,
		ylab = NA,
		xlab = "Day No.",
	  xlim = c(1, noDays),    
		col = "deepskyblue1",
		main = "Well Score Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 30, by = 1), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily Well Score", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regWellScoreIndiv <- lm(participantDailyData$WellScore ~ participantDailyData$DayNo)
		abline(regWellScoreIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regWellScoreGroup <- lm(participantDailyData$WellScore ~ participantDailyData$DayNo)
				abline(regWellScoreGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}

	lines(predict(regWellScore3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regWellScore, lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}

# PANASNA Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/panasnaScoreGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$PANASNAScore,
		type = "p",
		axes = FALSE,
		ylab = NA,
		xlab = "Day No.",
	  xlim = c(1, noDays),    
		col = "deepskyblue1",
		main = "PANASNA Score Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 30, by = 2), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily\n PANASNA Score", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regPANASNAScoreIndiv <- lm(participantDailyData$PANASNAScore ~ participantDailyData$DayNo)
		abline(regPANASNAScoreIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regPANASNAScoreGroup <- lm(participantDailyData$PANASNAScore ~ participantDailyData$DayNo)
				abline(regPANASNAScoreGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}
	
	lines(predict(regPANASNAScore3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regPANASNAScore, lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}

# PANASPA Spaghetti Plot
for (p in list) {
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
	fileName = paste("out/Daily/Participant/", p, "/panaspaScoreGroup.png", sep = "")
	png(paste(fileName, sep=""),
		res = 72,
		width = 500,
		height = 300,
		units = "px")
	plot(participantDailyData$DayNo, participantDailyData$PANASPAScore,
		type = "p",
		axes = FALSE,
		ylab = NA,
		xlab = "Day No.",
	  xlim = c(1, noDays),    
    col = "deepskyblue1",
		main = "PANASPA Score Plot" )
		
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
	axis(2, at = seq(0, 30, by = 2), las = 2)
	loc <- par("usr")
    text(loc[1], loc[4], "Daily\n PANSAPA Score", pos = 3, xpd = T)
    box()
	par(new = T)
		
	if (nrow(participantDailyData) > 2) {
		regPANASPAScoreIndiv <- lm(participantDailyData$PANASPAScore ~ participantDailyData$DayNo)
		abline(regPANASPAScoreIndiv, lwd = 2, col = "deepskyblue1")
		par(new = F)
	}

	for (p2 in list) {
		if (p2 != p) {
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				print(paste("nrows = ", nrow(participantDailyData), sep = " "))
				regPANASPAScoreGroup <- lm(participantDailyData$PANASPAScore ~ participantDailyData$DayNo)
				abline(regPANASPAScoreGroup, lwd = 1, col = "gray48")
				par(new = F)
			}
		}
	}

	lines(predict(regPANASPAScore3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regPANASPAScore, lwd = 3, col = "orangered")
	par(new = F)

	dev.off()
}


for (p in list) {
	participantDailyData <- subset( dailyData, ID == p)
	print(paste("------>", p))
	print(participantDailyData[1:4])

	if (nrow(participantDailyData) < 1) {
		next
	}
	
# PracMins
fileName = paste("out/Daily/Participant/", p, "/pracMins.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$PracMins, 
	type = "b",
	axes = FALSE,
	ylab = "Daily Practice Minutes",
	xlab = "Day No.",
	col = "deepskyblue1",
     xlim = c(1, noDays),
	main = "Practice Minutes Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 100, by = 10), las = 2)
abline(regPracMins,
	lwd = 2,
	col = "orangered")
dev.off()

# PQMScore
fileName = paste("out/Daily/Participant/", p, "/pqmScore.png", sep = "")
	png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")
plot(participantDailyData$DayNo, participantDailyData$PQMScore, 
	type = "b",
	axes = FALSE,
	ylab = "PQM Score",
	xlab = "Day No.",
	col = "deepskyblue1",
  xlim = c(1, noDays),    
	main = "PQM Score Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 10, by = 1), las = 2)
abline(regPQMScore,
	lwd = 2,
	col = "orangered")
dev.off()

# MAASScore
fileName = paste("out/Daily/Participant/", p, "/maasScore.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")
plot(participantDailyData$DayNo, participantDailyData$MAASScore, 
	type = "b",
	axes = FALSE,
	ylab = "MAAS Score",
	xlab = "Day No.",
	col = "deepskyblue1",
     xlim = c(1, noDays), 
     
	main = "MAAS Score Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 10, by = 1), las = 2)
abline(regMAASScore,
	lwd = 2,
	col = "orangered")
dev.off()

# WellScore
fileName = paste("out/Daily/Participant/", p, "/wellScore.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")
plot(participantDailyData$DayNo, participantDailyData$WellScore, 
	type = "b",
	axes = FALSE,
	ylab = "Well Score",
	xlab = "Day No.",
     xlim = c(1, noDays), 
     
     col = "deepskyblue1",
	main = "Well Score Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 30, by = 5), las = 2)
abline(regWellScore,
	lwd = 2,
	col = "orangered")
dev.off()

# PANASNAScore
fileName = paste("out/Daily/Participant/", p, "/panasnaScore.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")
plot(participantDailyData$DayNo, participantDailyData$PANASNAScore, 
	type = "b",
	axes = FALSE,
	ylab = "PANAS-NA Score",
	xlab = "Day No.",
     xlim = c(1, noDays), 
     
     col = "deepskyblue1",
	main = "PANAS-NA Score Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 30, by = 5), las = 2)
abline(regPANASNAScore,
	lwd = 2,
	col = "orangered")
dev.off()

# PANASPAScore
fileName = paste("out/Daily/Participant/", p, "/panaspaScore.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	units = "px")
plot(participantDailyData$DayNo, participantDailyData$PANASPAScore, 
	type = "b",
	axes = FALSE,
	ylab = "PANAS-PA Score",
	xlab = "Day No.",
     xlim = c(1, noDays), 
     
     col = "deepskyblue1",
	main = "PANAS-PA Score Plot" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 30, by = 5), las = 2)
abline(regPANASPAScore,
	lwd = 2,
	col = "orangered")
dev.off()

}
