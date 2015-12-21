# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']

# Eventually replace this with REST lookup of programruleuser table
gasboundary1 <- 4
gasboundary2 <- 5
gasboundary3 <- 6
gasboundary4 <- 7

userobsDF <- getUserobsDF(rooturl, programid, userid, inputobsname)
userobsDF[,"obsname"] <- obsname
userobsDF <- cbind( userobsDF, 
   gasboundary1=gasboundary1, 
   gasboundary2=gasboundary2, 
   gasboundary3=gasboundary3,
   gasboundary4=gasboundary4)
delFact(rooturl, programid, groupid=userid, factname=obsname)
postFact(rooturl, programid, groupid=userid, factname=obsname, userobsDF)

getNudge(rooturl, programid, groupid=userid, factname=obsname, rulename=rulename)
factouts <- getFactsystem(rooturl, programid, groupid=userid, factname=obsname)

outputDF = c()
for (factout in factouts) {
   outputDF <- cbind(outputDF, c( id=fromJSON(factout$factjson)$id, 
                                  rulename=fromJSON(factout$factjson)$rulename,
                                  ruledate=fromJSON(factout$factjson)$ruledate,
                                  rulemsg=fromJSON(factout$factjson)$rulemsg,
                                  ruledata=fromJSON(factout$factjson)$ruledata))
}
outputDF = data.frame(t(outputDF))

# Remove the userobs for this programid and userid and obsname
# delUserobs(rooturl, programid, userid, obsname)

for (i in 1:nrow(outputDF)) { 
   
   userobs <- c(programid=programid,
                userid,
                obsname=paste("\"", obsname, "\"", sep= ""),
                obsdate=paste("\"", outputDF[i, "ruledate"], "\"", sep=""),
                obsvalue=as.character(outputDF[i, "ruledata"]),
                obsdesc="\"System generated using rule service\""                
   )
   
   postUserobs(rooturl, userobs)
   
}

smsDF <- outputDF
today <- Sys.Date()

if ( ! is.null(nrow(smsDF)) ) {
   
   for (i in 1:nrow(smsDF)) {
      print(smsDF[i, "rulename" ])  
      
      rule <- getRule(rooturl, smsDF[i, "rulename" ] )
      
      # ruledate <- as.POSIXct(smsDF[i, "ruledate" ], format = "%a %b %d")
      
      msg <- c(programid=programid,
               userid,
               ruleid=rule[[1]]$ruleid,
               rulename=paste("\"", smsDF[i, "rulename" ], "\"", sep=""),
               ruledate=paste("\"", smsDF[i, "ruledate"], "\"", sep=""),
               msgtxt=paste("\"", smsDF[i, "rulemsg" ], "\"", sep="")
      )
      
      # Create msg for this programid and userid
      postMsg(rooturl, msg)
   }
   
}


