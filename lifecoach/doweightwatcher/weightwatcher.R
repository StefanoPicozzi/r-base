
Sys.setenv(NOAWT = "true")

library('httr')
library('rjson')
library('RCurl')
library('XML')

source("common/globals.R")
source("common/common.R")
source("common/container.R")

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']

weightDF <- getWeightObservations( username, fitbitkey, fitbitsecret, fitbitappname )

containerurl <- paste( containerurl, "/kie-server/services/rest/server/containers/instances/watch", sep = "" )

request <- buildNudgeRequest( userid = userid, username, weightDF )
list <- postNudgeRequest( containerurl, request )

for ( i in 2:(length(list$result)-2) ) {
  msgtxt <- as.character( list$result[[i]]$com.redhat.weightwatcher.Fact$facttxt )
  msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")
  sendPushover(pushoveruser, msgtxt)
  print( msgtxt )
}
