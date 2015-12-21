#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/lifecoach/dosolar"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../../common/common.R")

# Do programid=1 and activity observations
programid <<- 1
obsname <<- "solar"
rulename <<- "solar"

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

#   if ( userid != 7 && userid != 58 ) { next }

   if ( userid != 7 ) { next }

   print(paste("--->INSERTOBS --", userid, sep = ""))
   source("dosolarobs.R", echo = TRUE )

   print(paste("--->APPLYNUDGES --", userid, sep = ""))
   source("../common/donudges.R", echo = TRUE )

   print(paste("--->PUSHNOTIFICATION :", userid, sep = ""))
   source("../common/donotifications.R", echo = TRUE )

}
