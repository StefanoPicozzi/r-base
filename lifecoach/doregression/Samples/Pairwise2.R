library("xlsx")
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


panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, use = "complete.obs"))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste(prefix, txt, sep = "")
  if (missing(cex.cor))
    cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * (1 + r)/2)
}

panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts
  y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "white", ...)
}

panel.lm <- function (x, y, 
                      col = par("col"), 
                      bg = NA, pch = par("pch"), cex = 1, 
                      col.smooth = "black", ...) { 
  points(x, y, pch = pch, col = col, bg = bg, cex = cex) 
  abline(stats::lm(y ~ x), col = col.smooth, ...) 
}

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools")
getwd()

preData <- read.xlsx("Study1-ETL-Tool-v1.4.xls", sheetName = "PreCleanData")
dailyData <- read.xlsx("Study1-ETL-Tool-v1.4.xls", sheetName = "DailyCleanData")
dailyData <- subset(dailyData, ID != "BG30" && DayNo <= 62)
dailyData <- dailyData[order(dailyData$ID, dailyData$DayNo),]

setwd("/Users/stefanopicozzi/Google Drive/ANU/StefanoPicozzi/Study 1 - August 2013/Tools/R")
getwd()

dailyData[1:5]

participants <- preData$ID
list = c()
for (p in participants) {
  list <- append(list, p)
}
print(list)

print(paste("------> Study"))

pairsData <- data.frame(
  dayNo = c(dailyData$DayNo),
  id = c(dailyData$ID),
  pracMins = c(dailyData$PracMins), 
  pqmScore = c(dailyData$PQMScore) , 
  maasScore = c(dailyData$MAASScore), 
  wellScore = c(dailyData$WellScore),
  panasnaScore = c(dailyData$PANASNAScore), 
  panaspaScore = c(dailyData$PANASPAScore)
)

fileName = paste("out/Study/pairwise.png", sep = "")
png(paste(fileName, sep=""),
  res = ppi,
  width = 8*ppi,
  height = 8*ppi,
  pointsize = 16,
  units = "px")
  
pairs(pairsData,
  upper.panel = panel.cor,
  diag.panel = panel.hist,
  lower.panel = panel.smooth
)
dev.off()

for (p in list) {
	
	print(paste("------>", p))
	pDailyData <- c()
	pDailyData <- subset( dailyData, ID == p)

	if (nrow(pDailyData) < 1) { next }
	
	len <- nrow(pDailyData)
	
	if ( p == "PR63" ) {
		print(pDailyData[1:5])
	}
	
	pairsData <- data.frame(
		dayNo = c(pDailyData$DayNo), 
		pracMins = c(pDailyData$PracMins), 
		pqmScore = c(pDailyData$PQMScore) , 
		maasScore = c(pDailyData$MAASScore), 
		wellScore = c(pDailyData$WellScore),
		panasnaScore = c(pDailyData$PANASNAScore), 
		panaspaScore = c(pDailyData$PANASPAScore)
	)
		
	print(len)
	print(dim(pairsData))
#	print(pairsData[1:5])
  
	fileName = paste("out/Daily/Participant/", p, "/pairwise.png", sep = "")
	png(paste(fileName, sep=""),
		res = ppi,
		width = 8*ppi,
		height = 8*ppi,
		pointsize = 16,
		units = "px")
  
  pairs(pairsData,
    upper.panel = panel.cor,
    diag.panel = panel.hist,
    lower.panel = panel.smooth
  )
 
 	dev.off()
}