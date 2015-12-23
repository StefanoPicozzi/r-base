#!/usr/bin/Rscript

library("httr")

getwd()
print(R.Version()$version.string)

token_url <- "https://api.fitbit.com/oauth/request_token"
access_url <- "https://api.fitbit.com/oauth/access_token"
auth_url <- "https://www.fitbit.com/oauth/authorize"
fitbitkey <- "a7dd1c18a2a64dbcbd11e10482c8d5ef"
fitbitsecret <- "ff877fa1f54741ae93a549bdb2d7e900"
fitbitappname <- "TheNudgeMachine"
username <- "stefano"

fbr <- oauth_app(fitbitappname, fitbitkey, fitbitsecret)
print(fbr)

fitbit <- oauth_endpoint(token_url, auth_url, access_url)
print(fitbit)

token <- readRDS(file=paste("../user/", username, "/fitbit-token.RDS", sep = ""))
print(token)

sig <- sign_oauth1.0(app=fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)
print(sig)



