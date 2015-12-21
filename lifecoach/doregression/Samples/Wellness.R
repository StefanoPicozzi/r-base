library("lattice")
library("MASS")

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
preData <- preData[order(preData$ID),]

participants <- preData$ID
list = c()
for (p in participants) {
	list <- append(list, p)
}
print(list)

regStress <- lm(dailyData$Stress ~ dailyData$DayNo)
regSleep <- lm(dailyData$Sleep ~ dailyData$DayNo)
regDiet <- lm(dailyData$Diet ~ dailyData$DayNo)
regRelation <- lm(dailyData$Relationship ~ dailyData$DayNo)
regBusy <- lm(dailyData$Busy ~ dailyData$DayNo)
regPhysical <- lm(dailyData$Physical ~ dailyData$DayNo)
regWellScore <- lm(dailyData$WellScore ~ dailyData$DayNo)

regStress3 <- lm(dailyData$Stress ~ poly(dailyData$DayNo,3))
regSleep3 <- lm(dailyData$Sleep ~ poly(dailyData$DayNo, 3))
regDiet3 <- lm(dailyData$Diet ~ poly(dailyData$DayNo, 3))
regRelation3 <- lm(dailyData$Relationship ~ poly(dailyData$DayNo, 3))
regBusy3 <- lm(dailyData$Busy ~ poly(dailyData$DayNo, 3))
regPhysical3 <- lm(dailyData$Physical ~ poly(dailyData$DayNo, 3))
regWellScore3 <- lm(dailyData$WellScore ~ poly(dailyData$DayNo, 3))


for (p in list) {
	
	participantDailyData <- subset( dailyData, ID == p)
	print(paste("------>", p))
	#print(participantDailyData[1:4])
	if (nrow(participantDailyData) < 1) { next }

# Stress
fileName = paste("out/Daily/Participant/", p, "/stress.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")
par(mar=c(5,4,4,2) + 0.2)   
plot(participantDailyData$DayNo, participantDailyData$Sleep, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 5),
	ylab = NA,
	xlab = "Day Of Week",
	col = "deepskyblue1",
     xlim = c(1, noDays),
	main = "Stress Plot" )
abline(regStress,
	lwd = 2,
	col = "orangered")
lines(predict(regStress3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("None", "Very \nLittle", "A\n Moderate \nAmount", "Quite\n a Bit", "A\n Great\n Deal"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Stress", pos = 3, xpd = T)
box()
dev.off()

# Sleep
fileName = paste("out/Daily/Participant/", p, "/sleep.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$Sleep, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 5),
     xlim = c(1, noDays),
	ylab = NA,
	xlab = "Day Of Week",
	col = "deepskyblue1",
	main = "Sleep Plot" )
abline(regSleep,
	lwd = 2,
	col = "orangered")
lines(predict(regSleep3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("Excellent", "Very\n Good", "Fair", "Poor", "Very\n Poor"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Sleep", pos = 3, xpd = T)
box()
dev.off()

# Diet
fileName = paste("out/Daily/Participant/", p, "/diet.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$Diet, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 5),
     xlim = c(1, noDays),
     ylab = NA,
	xlab = "Day Of Week",
	col = "deepskyblue1",
	main = "Diet Plot" )
abline(regDiet,
	lwd = 2,
	col = "orangered")
lines(predict(regDiet3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("Excellent", "Very\n Good", "Fair", "Poor", "Very\n Poor"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Diet", pos = 3, xpd = T)
box()
dev.off()

# Relation
fileName = paste("out/Daily/Participant/", p, "/relation.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$Relation, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 4),
     xlim = c(1, noDays),
	ylab = NA,
	xlab = "Day Of Week",	
	col = "deepskyblue1",
	main = "Relationship Plot" )
abline(regRelation,
	lwd = 2,
	col = "orangered")
lines(predict(regRelation3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("Excellent", "Very\n Good", "Fair", "Poor", "Very\n Poor"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Relationships", pos = 3, xpd = T)
box()
dev.off()

# Busy
fileName = paste("out/Daily/Participant/", p, "/busy.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$Busy, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 4),
     xlim = c(1, noDays),
	ylab = NA,
	xlab = "Day Of Week",
	col = "deepskyblue1",
	main = "Business Plot" )
abline(regBusy,
	lwd = 2,
	col = "orangered")
lines(predict(regBusy3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("Not\n at\n All", "Slightly\n Busy", "Somewhat\n Busy", "Moderately\n Busy", "Extremely\n Busy"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Business", pos = 3, xpd = T)
box()
dev.off()

# Physical
fileName = paste("out/Daily/Participant/", p, "/physical.png", sep = "")
png(paste(fileName, sep=""),
	res = 72,
	width = 500,
	height = 300,
	pointsize = 10,
	units = "px")	
plot(participantDailyData$DayNo, participantDailyData$Physical, 
	type = "b",
	axes = FALSE,
	ylim = c(0, 4),
     xlim = c(1, noDays),
	ylab = NA,
	xlab = "Day Of Week",	
	col = "deepskyblue1",
	main = "Physical Plot" )
abline(regPhysical,
	lwd = 2,
	col = "orangered")
lines(predict(regPhysical3, newdata=data.frame(dailyData$DayNo)), lwd = 2, col="gray48" )
axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7, las = 2)
axis(2, at = seq(0, 4, by = 1), labels = c("0 mins", "1-10 mins", "11-30 mins", "31-45 mins", "More Than\n 45 mins"), cex.axis = 0.7, las = 2)
loc <- par("usr")
text(loc[1], loc[4], "Physical", pos = 3, xpd = T)
box()
dev.off()


}

# Combined Wellness Results
# To be completed - find out how to combine multiple plots in R

for (p in list) {
	participantDailyData <- subset( dailyData, ID == p)
	print(paste("------>", p))
	print(participantDailyData[1:4])

# Stress
fileName = paste("out/Daily/Participant/", p, "/well.jpg", sep = "")

jpeg(paste(fileName, sep=""),
	quality = 100,
	width = 500,
	height = 300,
	units = "px")	

plot(participantDailyData$DayNo, participantDailyData$Sleep, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 5),
	col = "deepskyblue1",
	main = "Well Plot" )
abline(regStress,
	lwd = 2,
	col = "orangered")

# Sleep

plot(participantDailyData$DayNo, participantDailyData$Sleep, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 5),
	col = "deepskyblue1",
	main = "Sleep Plot" )
abline(regSleep,
	lwd = 2,
	col = "orangered")

# Diet

plot(participantDailyData$DayNo, participantDailyData$Diet, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 5),
	ylab = "Diet",
	xlab = "Day No.",
	col = "deepskyblue1")
abline(regDiet,
	lwd = 2,
	col = "orangered")

# Relation

plot(participantDailyData$DayNo, participantDailyData$Relation, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 4),
	col = "deepskyblue1")
abline(regRelation,
	lwd = 2,
	col = "orangered")

# Busy

plot(participantDailyData$DayNo, participantDailyData$Busy, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 4),
	col = "deepskyblue1")
abline(regBusy,
	lwd = 2,
	col = "orangered")

# Physical

plot(participantDailyData$DayNo, participantDailyData$Physical, 
	type = "b",
	xlim = c(1,noDays),
	ylim = c(0, 4),
	col = "deepskyblue1")
abline(regPhysical,
	lwd = 2,
	col = "orangered")
dev.off()


}

