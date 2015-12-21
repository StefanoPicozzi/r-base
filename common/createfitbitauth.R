# This script will generate reusable fitbit authentication files
# The sxript will trigger a browser page to be launched in which you enter Allow

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
fitbit = oauth_endpoint(token_url, auth_url, access_url)
token = oauth1.0_token(fitbit, fbr)
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)
saveRDS(token, file="fitbit-token.RDS")
