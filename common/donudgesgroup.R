# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(rjson)

# Input Parameters
#  programid
#  groupid
#  rulename

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

delFact(rooturl, programid, groupid=groupid, factname=obsname)
for (programuser in programusers) {
   if (programuser$roletype != "participant") { next }
   userid <- programuser["userid"]
   userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
   postFact(rooturl, programid, groupid=groupid, factname=obsname, userobsDF)
}

getNudge(rooturl, programid, groupid=groupid, factname=obsname, rulename=rulename)
factouts <- getFactsystem(rooturl, programid, groupid=groupid, factname=obsname)

outputDF = c()
for (factout in factouts) {
   outputDF <- cbind(outputDF, 
      c( id=fromJSON(factout$factjson)$id, 
         rulename=fromJSON(factout$factjson)$rulename,
         ruledate=fromJSON(factout$factjson)$ruledate,
         rulemsg=fromJSON(factout$factjson)$rulemsg,
         ruledata=fromJSON(factout$factjson)$ruledata ))
}

if (! is.null(nrow(outputDF))) {
   outputDF = data.frame(t(outputDF))

      
      # Get optinrules for this programid and userid
      optinruleviewDF <- getOptinruleviewDF(rooturl, programid, userid)
      outputDF <- outputDF[ order(outputDF[, "rulename"]), ]
      outputDF <- subset(outputDF, outputDF[, "rulename"] %in% optinruleviewDF )

      smsDF <- outputDF
      today <- Sys.Date()

      if ( ! is.null(nrow(smsDF)) ) {
         for (i in 1:nrow(smsDF)) {
            print(smsDF[i, "rulename" ])  
            rule <- getRule(rooturl, smsDF[i, "rulename" ] )
            
            userid <- as.character(smsDF[i, "id"]);
            
            msg <- c(programid=programid,
               userid=userid,
               ruleid=rule[[1]]$ruleid,
               rulename=paste("\"", smsDF[i, "rulename" ], "\"", sep=""),
               ruledate=paste("\"", smsDF[i, "ruledate"], "\"", sep=""),
               msgtxt=paste("\"", smsDF[i, "rulemsg" ], "\"", sep="")
            )

            # Create msg for this programid and userid
            postMsg(rooturl, msg)
         }
      }
   
}
