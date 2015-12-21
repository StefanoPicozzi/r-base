#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

source("common/globals.R")
source("common/common.R")

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

#   if ( userid != 7 && userid != 58 ) { next }   
   if ( userid != 7 ) { next }

   obsname <<- "activity"
   print(paste("--->OBS activity", userid, sep = ""))
   source("lifecoach/doobs/dofitbitobs.R", echo = TRUE )

   obsname <<- "weight"
   print(paste("--->OBS weight", userid, sep = ""))
   source("lifecoach/doobs/dowithingsobs-weight.R", echo = TRUE )
   
}
