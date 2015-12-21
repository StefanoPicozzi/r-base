# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(rjson)

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
if ( nrow(userobsDF) > 1000 ) { 
  userobsDF <- subset( userobsDF, regexpr( Sys.Date(), userobsDF[, "obsdate"]) > 0)
}

delFact(rooturl, programid, groupid=userid, factname=obsname)
postFact(rooturl, programid, groupid=userid, factname=obsname, userobsDF)
getNudge(rooturl, programid, groupid=userid, factname=obsname, rulename=rulename)
factouts <- getFactsystem(rooturl, programid, groupid=userid, factname=obsname)

outputDF <- c()
for (factout in factouts) {
  outputDF <- cbind(outputDF, c( id=fromJSON(factout$factjson)$id, 
                                 rulename=fromJSON(factout$factjson)$rulename,
                                 ruledate=fromJSON(factout$factjson)$ruledate,
                                 rulemsg=fromJSON(factout$factjson)$rulemsg,
                                 ruledata=fromJSON(factout$factjson)$ruledata))
}

if ( is.null(outputDF) ) { stop("outputDF is NULL") }

outputDF = data.frame(t(outputDF))

# Get optinrules for this programid and userid
optinruleviewDF <- getOptinruleviewDF(rooturl, programid, userid)
outputDF <- outputDF[ order(outputDF[, "rulename"]), ]
outputDF <- subset(outputDF, outputDF[, "rulename"] %in% optinruleviewDF )

if ( nrow(outputDF) == 0 ) { stop("No opt-ins") }
    
smsDF <- outputDF
today <- Sys.Date()

if ( nrow(smsDF) == 0 ) { stop("No messages") }
 
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
  