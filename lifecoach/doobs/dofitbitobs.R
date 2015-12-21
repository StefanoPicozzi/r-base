# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

source("common/globals.R")
source("common/common.R")

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']                             
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']      

if ( ! is.na(fitbitkey) ) {

   token_url <- "https://api.fitbit.com/oauth/request_token"
   access_url <- "https://api.fitbit.com/oauth/access_token"
   auth_url <- "https://www.fitbit.com/oauth/authorize"
   fbr = oauth_app(fitbitappname, fitbitkey, fitbitsecret)
   token <- readRDS(file = paste(usersdir, username, "/fitbit-token.RDS", sep = ""))
   sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

   lastdate <- getMaxobsdate(rooturl, programid, userid, "activity")
   print(lastdate)
   if (lastdate == "1970-01-01 00:00:00") {
      startdate <- Sys.Date()-362
   } else {
      startdate <- as.Date(substring(lastdate, 1, 10))+1
   }
   # startdate <- as.Date(Sys.Date()) - 31   
   getURL <- "https://api.fitbit.com/1/user/-/activities/steps/date/"
   getURL <- paste(getURL, startdate, "/today.json", sep = "")

   # get all step data from my first day of use to the current date:
   stepsJSON <- tryCatch({
      GET(getURL, sig)
   }, warning = function(w) {
      print("Warning steps")
      stop()
   }, error = function(e) {
      print("Error steps")
      stop()
   }, finally = {
   })

   stepsDF <- NULL
   for (i in 1:length(content(stepsJSON)$`activities-steps`)) {
      x = c( content(stepsJSON)$`activities-steps`[i][[1]][['dateTime']], content(stepsJSON)$`activities-steps`[i][[1]][['value']] ) 
      stepsDF <- cbind(stepsDF, x)
   }
   stepsDF <- t(stepsDF)
   colnames(stepsDF) = c("obsdate", "obsvalue")
   stepsDF = as.data.frame(stepsDF, row.names = 1)

   inputDF <- cbind( username = c(username), stepsDF)
   inputDF <- data.frame(lapply(inputDF, as.character), stringsAsFactors=FALSE)

   # Remove the userobs for this programid and userid and obsname
   # delUserobs(rooturl, programid, userid, "activity")

   for (i in 1:nrow(inputDF)) { 

      userobs <- c(programid=programid,
                userid=userid,
                obsname="\"activity\"",
                obsdate=paste("\"", inputDF[i, "obsdate"], "\"", sep=""),
                obsvalue=inputDF[i, "obsvalue"],
                obsdesc="\"System generated from fitbit.com stepcount download\""                
               )
   
      postUserobs(rooturl, userobs)
   
   }
   # userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

}
