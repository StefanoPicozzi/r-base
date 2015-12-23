# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']

filepath <- "~/SolarMax/Data/"
processedfilepath <- "~/SolarMax/Processed/"

maxobsdate <- getMaxobsdate(rooturl, programid, userid, obsname)
maxobsdate <- as.POSIXct( maxobsdate, format="%Y-%m-%d %H:%M:%OS", origin="1970-01-01", tz="Australia/Sydney")
if ( is.na(maxobsdate)) {
  maxobsdate <- as.POSIXct( "1970-01-01 00:00:00.000", format="%Y-%m-%d %H:%M:%OS", origin="1970-01-01", tz="Australia/Sydney")
}
maxobsdate <- as.numeric(maxobsdate)

csvDF <- c()
inputsolarDF <- c()
listfiles <- list.files(path = filepath , pattern = "Nudge-Monitor" ) 
for (file in listfiles) {
  csvDF <- read.csv(file = paste(filepath, file, sep = "") , header = FALSE, sep = ";", stringsAsFactors = FALSE)   
  if (nrow(csvDF) > 0) {
    csvDF <- csvDF[-1,]
    csvDF <- subset(csvDF, V2 != "n/a")
    csvDF <- subset(csvDF, as.numeric(as.POSIXct(V1, format="%Y-%m-%d %H:%M:%OS", origin="1970-01-01", tz="Australia/Sydney")) > maxobsdate)
    if (nrow(csvDF) > 0) { inputsolarDF <- rbind(inputsolarDF, csvDF) }
  }
  if ( regexpr( Sys.Date(), file) < 1 ) {
    file.rename(from = paste(filepath, file, sep = ""),  to = paste(processedfilepath, file, sep = ""))
  }
}

if ( is.data.frame(inputsolarDF) && nrow(inputsolarDF) > 0) {

  colnamesDF <- read.csv(file = paste(rootdir, "/SolarHeaders.csv", sep = ""), header = FALSE, sep = ";", stringsAsFactors = FALSE)
  solarnames <- c()
  for (i in 1:ncol(colnamesDF)) {
    solarname <- colnamesDF[1,i]
    n <- regexpr(" ", solarname)
    if ( n > 0 ) {
      solarname <- substr(solarname, 1, n-1)
    }     
    solarnames <- cbind(solarnames, solarname)
  }

  solarDF <- inputsolarDF
  colnames(solarDF) = solarnames
  inputDF <- cbind( username = c(username), solarDF)

  for (i in 1:nrow(inputDF)) { 

    timestamp <- as.POSIXct( inputDF[i, "Timestamp"], format = "%Y-%m-%d %H:%M:%OS", origin = "1970-01-01", tz = "Australia/Sydney")
    timestamp <- as.numeric(timestamp) * 1000
  
    userobs <- c(
      programid = programid,
      userid,
      obsname = "\"solar\"",   
      obsdate = timestamp,      
      obsvalue = inputDF[i, "S"],
      obsdesc = "\"System generated from solar filelogger\""                
    )
   
    postUserobs(rooturl, userobs)
  }

}
