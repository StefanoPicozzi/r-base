# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
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

if ( is.na(fitbitkey) ) { stop("fitbitkey does not exist") }

token_url <- "https://api.fitbit.com/oauth/request_token"
access_url <- "https://api.fitbit.com/oauth/access_token"
auth_url <- "https://www.fitbit.com/oauth/authorize"

print(R.Version()$version.string)

fbr <- oauth_app(fitbitappname, fitbitkey, fitbitsecret)
fitbit <- oauth_endpoint(token_url, auth_url, access_url)
#token = oauth1.0_token(fitbit, fbr)
#saveRDS(token, file = paste("user/", username, "/fitbit-token.RDS", sep = ""))
token <- readRDS(file = paste(usersdir, username, "/fitbit-token.RDS", sep = ""))
sig <- sign_oauth1.0(app=fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

lastdate <- getMaxobsdate(rooturl, programid, userid, "weight")
print(lastdate)
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
if ( is.null(inputDF) ) { stop("No weight records returned") }

for (i in 1:nrow(inputDF)) { 
   userobs <- c(programid=as.numeric(programid),
                userid=as.numeric(userid),
                obsname="\"weight\"",
                obsdate=inputDF[i, "obsdate"],
                obsvalue=inputDF[i, "obsvalue"],
                obsdesc="\"System generated from fitbit.com weight download\""                
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
if ( is.null(inputDF) ) { stop("No bmi records returned") }

for (i in 1:nrow(inputDF)) { 
   userobs <- c(programid=as.numeric(programid),
                userid=as.numeric(userid),
                obsname="\"bmi\"",
                obsdate=inputDF[i, "obsdate"],
                obsvalue=inputDF[i, "obsvalue"],
                obsdesc="\"System generated from fitbit.com bmi download\""                
               )
   postUserobs(rooturl, userobs)
}
