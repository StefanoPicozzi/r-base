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

if ( is.na(fitbitkey) ) { stop("fitbitkey does not exist") }

token_url <- "https://api.fitbit.com/oauth/request_token"
access_url <- "https://api.fitbit.com/oauth/access_token"
auth_url <- "https://www.fitbit.com/oauth/authorize"
fbr = oauth_app(fitbitappname, fitbitkey, fitbitsecret)
token <- readRDS(file = paste("../user/", username, "/fitbit-token.RDS", sep = ""))
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

lastdate <- getMaxobsdate(rooturl, programid, userid, "weight")
if (lastdate == "1970-01-01 00:00:00") {
   startdate <- Sys.Date()-30
} else {
   startdate <- as.Date(substring(lastdate, 1, 10))+1
}
enddate <- paste(Sys.Date()+1, ".json", sep="")   
getURL <- "https://api.fitbit.com/1/user/-/body/log/weight/date/"
getURL <- paste(getURL, startdate, "/", enddate, sep = "")
print(getURL)
   
weightJSON <- tryCatch({
   GET(getURL, sig)
}, warning = function(w) {
   print("Warning weight")
   stop()
}, error = function(e) {
   print(geterrmessage())
   print("Error GET fitbit weight")
   stop()
}, finally = {
})

if ( length(content(weightJSON)$`weight`) == 0 ) { stop("No fitbit weight records") }

inputDF <- NULL
weightDF <- NULL
for (i in 1:length(content(weightJSON)$`weight`)) {
   timestamp <- paste( content(weightJSON)$`weight`[i][[1]][['date']], " 07:15:00", sep = "")
   timestamp <- as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", origin = "1970-01-01", tz = "Australia/Sydney")
   timestamp <- as.numeric(timestamp) * 1000
   x = c( timestamp, content(weightJSON)$`weight`[i][[1]][['weight']] ) 
   weightDF <- cbind(weightDF, x)
}
weightDF <- t(weightDF)
colnames(weightDF) = c("obsdate", "obsvalue")
inputDF <- cbind( username = c(username), weightDF)

for (i in 1:nrow(inputDF)) { 
   userobs <- c(programid = programid,
                userid,
                obsname = "\"weight\"",
                obsdate = inputDF[i, "obsdate"],
                obsvalue = inputDF[i, "obsvalue"],
                obsdesc = "\"System generated from fitbit.com weight download\""                
               )
   postUserobs(rooturl, userobs)
}

inputDF <- NULL
bmiDF <- NULL
for (i in 1:length(content(weightJSON)$`weight`)) {
   timestamp <- paste( content(weightJSON)$`weight`[i][[1]][['date']], " 07:15:00", sep = "")
   timestamp <- as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", origin = "1970-01-01", tz = "Australia/Sydney")
   timestamp <- as.numeric(timestamp) * 1000
   x = c( timestamp, content(weightJSON)$`weight`[i][[1]][['bmi']] ) 
      bmiDF <- cbind(bmiDF, x)
}
bmiDF <- t(bmiDF)
colnames(bmiDF) = c("obsdate", "obsvalue")
inputDF <- cbind( username = c(username), bmiDF)
   
for (i in 1:nrow(inputDF)) { 
   userobs <- c(programid = programid,
                userid,
                obsname = "\"bmi\"",
                obsdate = inputDF[i, "obsdate"],
                obsvalue = inputDF[i, "obsvalue"],
                obsdesc = "\"System generated from fitbit.com bmi download\""                
               )
   postUserobs(rooturl, userobs)
}
 
lastdate <- getMaxobsdate(rooturl, programid, userid, "fat")
if (lastdate == "1970-01-01 00:00:00") {
   startdate <- Sys.Date()-30
} else {
   startdate <- as.Date(substring(lastdate, 1, 10))+1
}
   
today <- as.Date(Sys.Date())
days <- today - as.Date(lastdate)
if (days < 1) { stop("No fat records needed") }

inputDF <- NULL
for (i in seq(0,days)) {
   getURL <- "https://api.fitbit.com/1/user/-/body/log/fat/date/"
   date <- today - i
   getURL <- paste(getURL, date, ".json", sep = "")
   print(getURL)
      
   fatJSON <- tryCatch({
      GET(getURL, sig)
   }, warning = function(w) {
      print("Warning fat")
      stop()
   }, error = function(e) {
      print(geterrmessage())
      print("Error GET fitbit fat")
      stop()
   }, finally = {
   })

   if ( length(content(fatJSON)$`fat`) == 0 ) { stop("No fitbit fat records") }
      
   fatDF <- NULL
   for (i in 1:length(content(fatJSON)$`fat`)) {
      timestamp <- paste( content(fatJSON)$`fat`[i][[1]][['date']], " 07:15:00", sep = "")
      timestamp <- as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", origin = "1970-01-01", tz = "Australia/Sydney")
      timestamp <- as.numeric(timestamp) * 1000
      fat <- content(fatJSON)$`fat`[i][[1]][['fat']]
      fatDF <- c( username, timestamp, content(fatJSON)$`fat`[i][[1]][['fat']] ) 
      fatDF <- t(fatDF)
      inputDF <- rbind(inputDF, fatDF)
   }
}

colnames(inputDF) <- c("username", "obsdate", "obsvalue")   

for (i in 1:nrow(inputDF)) { 
   userobs <- c(programid = programid,
                userid,
                obsname = "\"fat\"",
                inputDF[i, "obsdate"],
                inputDF[i, "obsvalue"],
                obsdesc = "\"System generated from fitbit.com fat download\""                
               )
   postUserobs(rooturl, userobs)
}
