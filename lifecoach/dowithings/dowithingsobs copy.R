# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

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
   token <- readRDS(file = paste("../user/", username, "/fitbit-token.RDS", sep = ""))
   sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

   getURL <- "https://api.fitbit.com/1/user/-/body/log/weight/date/"
   startdate <- as.Date(Sys.Date()) - 31
   getURL <- paste(getURL, startdate, "/today.json", sep = "")
   
   weightJSON <- tryCatch({
      GET(getURL, sig)
   }, warning = function(w) {
      print("Warning weight")
      stop()
   }, error = function(e) {
      print("Error weight")
      stop()
   }, finally = {
   })
   
   weightDF <- NULL
   for (i in 1:length(content(weightJSON)$`weight`)) {
      timestampch <- paste( content(weightJSON)$`weight`[i][[1]][['date']], " 08:15:00", sep = "") 
      timestamp <- as.POSIXct(timestampch, tz = "Australia/Sydney")
#      x <- c( content(weightJSON)$`weight`[i][[1]][['date']], content(weightJSON)$`weight`[i][[1]][['weight']] ) 
#      x <- c( strptime(timestamp, format = "%Y-%M-%D %H:%M:%S", tz = "AU"), content(weightJSON)$`weight`[i][[1]][['weight']] )          
      x <- c( timestamp, content(weightJSON)$`weight`[i][[1]][['weight']] )             
      weightDF <- cbind(weightDF, x)
   }
   weightDF <- t(weightDF)
   colnames(weightDF) = c("obsdate", "obsvalue")
   weightDF = as.data.frame(weightDF, row.names = 1)

   inputDF <- cbind( username = c(username), weightDF)
   inputDF <- data.frame(lapply(inputDF, as.character), stringsAsFactors=FALSE)

   # Remove the userobs for this programid and userid and obsname
   delUserobs(rooturl, programid, userid, "weight")

   for (i in 1:nrow(inputDF)) { 

      userobs <- c(programid=programid,
                userid,
                obsname="\"weight\"",
                obsdate=paste("\"", inputDF[i, "obsdate"], "\"", sep=""),
                obsvalue=inputDF[i, "obsvalue"],
                obsdesc="\"System generated from fitbit.com weight download\""                
               )
   
      postUserobs(rooturl, userobs)
   
   }
   # userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

   bmiDF <- NULL
   for (i in 1:length(content(weightJSON)$`weight`)) {
      x = c( content(weightJSON)$`weight`[i][[1]][['date']], content(weightJSON)$`weight`[i][[1]][['bmi']] ) 
      bmiDF <- cbind(bmiDF, x)
   }
   bmiDF <- t(bmiDF)
   colnames(bmiDF) = c("obsdate", "obsvalue")
   bmiDF = as.data.frame(bmiDF, row.names = 1)
   
   inputDF <- cbind( username = c(username), bmiDF)
   inputDF <- data.frame(lapply(inputDF, as.character), stringsAsFactors=FALSE)
   
   # Remove the userobs for this programid and userid and obsname
   delUserobs(rooturl, programid, userid, "bmi")
   
   for (i in 1:nrow(inputDF)) { 
      
      userobs <- c(programid=programid,
                   userid,
                   obsname="\"bmi\"",
                   obsdate=paste("\"", inputDF[i, "obsdate"], "\"", sep=""),
                   obsvalue=inputDF[i, "obsvalue"],
                   obsdesc="\"System generated from fitbit.com bmi download\""                
      )
      
      postUserobs(rooturl, userobs)
      
   }
   # userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
   
}
