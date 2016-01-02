Sys.setenv(NOAWT = "true")

library('httr')
library('rjson')
library('RCurl')
library('XML')

source("common/globals.R")
source("common/common.R")
source("common/container.R", echo=FALSE)

userid <- 7

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']

deleteAllFacts()

userids <- c(7, 4)
for (userid in userids) { deleteAllByUserid( userid ) }

usernames <- c("stefano", "stephanie")
for (username in usernames) {
   
  factbody <- c()
  factbody <- paste(factbody, buildParticipantFact( username ), sep=" ")
  factbody <- paste(factbody, buildOptInOutFact( username ), sep=" ")
  factbody <- paste(factbody, buildGASFact( username, "activity" ), sep=" ")
  factbody <- paste(factbody, buildGASFact( username, "weight" ), sep=" ")
  factbody <- paste(factbody, buildGASFact( username, "fasting" ), sep=" ")
  factbody <- paste(factbody, buildGoalFact( username, "activity" ), sep=" ")
  factbody <- paste(factbody, buildGoalFact( username, "weight" ), sep=" ")
  factbody <- paste(factbody, buildGoalFact( username, "fasting" ), sep=" ")

  request <- buildInsertRequest( factbody )
  list <- postNudgeRequest( containerurl, request )

}

