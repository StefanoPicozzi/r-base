
Sys.setenv(NOAWT = "true")

library('httr')
library('rjson')
library('RCurl')
library('XML')

source("common/globals.R")
source("common/common.R")
source("common/container.R")

# obsname <- "all"
obsname <- "activity"
# obsname <- "gas31"

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']

if (obsname == "gas31") {
   obsDF <- getUserobsDF(rooturl, programid, userid, obsname)
} else if (obsname == "all") {
   obsDF <- getFitbitObservations( userid, username, obsname="activity", fitbitkey, fitbitsecret, fitbitappname )
   obsDF <- rbind( obsDF, getFitbitObservations( userid, username, obsname="weight", fitbitkey, fitbitsecret, fitbitappname ) )
   obsDF <- rbind( obsDF, getUserobsDF(rooturl, programid, userid, obsname="gas31") )
} else {
   obsDF <- getFitbitObservations( userid, username, obsname, fitbitkey, fitbitsecret, fitbitappname )
}

factbody <- buildParticipantFact( username )
factbody <- paste(factbody, buildGASFact( username, "steps" ), sep=" ")
factbody <- paste(factbody, buildGoalFact( username, obsname ), sep=" ")
factbody <- paste(factbody, buildObservationFact( obsDF ), sep=" ")
request <- buildEnvelopeRequest( factbody )
list <- postNudgeRequest( containerurl, request )

for ( i in 2:(length(list$result)-2) ) {
  msgtxt <- as.character( list$result[[i]]$com.redhat.weightwatcher.Fact$facttxt )
  msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")
  sendPushover(pushoveruser, msgtxt)
  print( msgtxt )
}
