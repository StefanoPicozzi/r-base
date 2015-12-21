
# This is a longitudinal survey in which participants record
# the number of minutes they have been practising Mindfulness (PracMins)
# each day (DayNo). 
# We are interested in patterns of practice across the
# duration of a mindfulness based training course.


# Set up your survey data frames as necessary to reflect your input data
# In my data the participant list lives in preData
# and the participant practice longitudinal data in dailyData
preData <- read.delim("Pre.csv", header = T, sep = ",") 
dailyData <- read.delim("Daily.csv", header = T, sep = ",") 


# In this study the time variable is DayNo
# The minimum the longitidunal data set needs is ID, DayNo and the observation, e.g. PracMins
# one record per row for each participant ID and DayNo observed combination.
# Sort the data
dailyData <- dailyData[order(dailyData$ID, dailyData$DayNo),]


# The graphs need to know how many days in this study to make plot neater.
# This could be set dynamically by extracting the max(DayNo) in the sample
# but simply harded coded here instead
# Ditto for maximum number of practice minutes, the observed variable
noDays <- 48
maxMins <- 100


# Pretty up the x axis to show Days-of-Week rather than a DayNo integer
# This could be built dynamically but hard coded here instead
# Our study began on a Thursday as week 1 and then each week
# starts on the Wednesday thereafter
dayOfWeek <- c(
		  "1-Th", "Fr", "Sa", "Su", "Mo", "Tu",
	"2-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
	"3-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
	"4-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
	"5-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu",
	"6-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu"
	"7-We", "Th", "Fr", "Sa", "Su", "Mo", "Tu"
	)


# Create a list of participants in your study
# This list needs to contain a unique list of IDs
participants <- preData$ID
list = c()
for (p in participants) {
	list <- append(list, p)
}


# For the entire group fit a linear regression
# and optionally other curves such as a 3 degree polynomial
regPracMins <- lm(dailyData$PracMins ~ dailyData$DayNo)
regPracMins3 <- lm(dailyData$PracMins ~ poly(dailyData$DayNo,3) )


# For each participant create a Spaghetti Plot
for (p in list) {
	
	# Create a subset of of the time series data for the participant of interest
	# and skip if insufficient data points
	# Note use of subset()
	participantDailyData <- subset(dailyData, ID == p & DayNo > 0)
	if (nrow(participantDailyData) < 1) {
		next
	}
	
	# Set up the output file
	# In this case the dependent variable is known as PracMins
	# Filename path hard coded here, recommend you paramterise this too
	fileName = paste("~/Downloads/PracMinsPlot-", p,",.jpeg", sep = "")
	jpeg(paste(fileName, sep=""),
		quality = 100,
		width = 300,
		height = 300,
		units = "px")
		
	# Plot PracMins observations against DayNo for this participant
	# These will appear as blue circles
	plot(participantDailyData$DayNo, participantDailyData$PracMins,
		type = "p",
		axes = FALSE,
		ylim = c(0, maxMins),
		xlim = c(1, noDays),
		ylab = "Daily Practice Minutes",
		xlab = "Day No.",
		col = "deepskyblue1",
		main = "Practice Minutes Plot" )
	
	# Pretty up the axes
	axis(1, at = seq(1, noDays, by = 1), labels = dayOfWeek,  cex.axis = 0.7)
	axis(2, at = seq(0, 100, by = 10))
	# This is a new plot, ready to add additional curves to the same plot
	par(new = T)
		
	# If sufficient observations fit a linear regression for this participant
	# and add this line to the plot in a deep blue colour
	if (nrow(participantDailyData) > 2) {
		regPracMinsIndiv <- lm(participantDailyData$PracMins ~ participantDailyData$DayNo)
		abline(regPracMinsIndiv, lwd = 2, col = "deepskyblue1")
		# Add this line to existing plot
		par(new = F)
	}

	# If sufficient observations fit a linear regression for every other participant
	# and add this line to the plot each time which will appear as thin gray lines
	for (p2 in list) {
		if (p2 != p) {
			# Subset off just the data for this participant
			participantDailyData <- subset(dailyData, ID == p2 & DayNo > 0)
			if (nrow(participantDailyData) > 2) {
				regPracMinsGroup <- lm(participantDailyData$PracMins ~ participantDailyData$DayNo)
				abline(regPracMinsGroup, lwd = 1, col = "gray48")
				# Add this line to existing plot
				par(new = F)
			}
		}
	}

	# Add the overall group linear regression and cubic polynomial to the plot
	# The linear trend will be orange, the cubic trend in dark gray 
	lines(predict(regPracMins3, newdata=data.frame(dailyData$DayNo)), lwd = 3, col="gray48" )
	abline(regPracMins,	lwd = 3, col = "orangered")
	# Add these curves to existing plot
	par(new = F)

	# We are done close the plot .jpeg file
	dev.off()
}
