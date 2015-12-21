
Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

fitbitkey <- "a7dd1c18a2a64dbcbd11e10482c8d5ef"                          
fitbitsecret <- "ff877fa1f54741ae93a549bdb2d7e900"
fitbitappname <- "TheNudgeMachine"      
token_url <- "http://api.fitbit.com/oauth/request_token"
access_url <- "http://api.fitbit.com/oauth/access_token"
auth_url <- "http://www.fitbit.com/oauth/authorize"
fbr = oauth_app(fitbitappname, fitbitkey, fitbitsecret)
token <- readRDS(file = paste("fitbit-token.RDS", sep = ""))
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

getURL <- "http://api.fitbit.com/1/user/-/activities/steps/date/"
#startdate <- Sys.Date() - 7
startdate <- "2014-04-01"
startdatestr <- as.POSIXct(startdate, format = "%a %b %d")
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


getURL <- "http://api.fitbit.com/1/user/-/body/log/weight/date/2014-03-30.json"
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
