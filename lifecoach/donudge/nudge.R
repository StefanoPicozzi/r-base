
Sys.setenv(NOAWT = "true")

library('httr')
library('rjson')
library('RCurl')
library('XML')

source("common/globals.R")
source("common/common.R")
source("common/container.R")

programid <- 1
userid <- 7
# obsname <- "all"
obsname <- "activity"
# obsname <- "fasting"
# obsname <- "weight"

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']

if (obsname == "fasting") {
   obsDF <- getUserobsDF(rooturl, programid, userid, obsname)
} else if (obsname == "all") {
   obsDF <- getFitbitObservations( programid, userid, username, obsname="activity", fitbitkey, fitbitsecret, fitbitappname )
   obsDF <- rbind( obsDF, getFitbitObservations( programid, userid, username, obsname="weight", fitbitkey, fitbitsecret, fitbitappname ) )
   obsDF <- rbind( obsDF, getUserobsDF(rooturl, programid, userid, obsname="gas31") )
} else {
   obsDF <- getFitbitObservations( programid, userid, username, obsname, fitbitkey, fitbitsecret, fitbitappname )
}

userids <- c(7, 4)
usernames <- c("stefano", "stephanie")

for (userid in userids) { 

  if (userid == 4) {
    obsDF[,"userid"] <- "4"
    obsDF[,"obsvalue"] <- as.character(as.numeric(obsDF[, "obsvalue"])-1000)
  }
   
  factbody <- c()
  factbody <- paste(factbody, buildObservationFact( obsDF ), sep=" ")
  request <- buildInsertRequest( factbody )
  list <- postNudgeRequest( containerurl, request )

  request <- buildQueryRequest( query="getMsgByUserid", params=paste('<int>', userid, '</int>', sep='') )
  list <- postNudgeRequest( containerurl, request )

  for ( i in 2:(length(list$result)-2) ) {
    msgtxt <- as.character( list$result[[i]]$com.redhat.weightwatcher.Msg$msgtxt )
    msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")
    print( msgtxt )
  }

}
