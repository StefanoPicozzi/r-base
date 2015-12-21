#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

   if ( userid != 7 && userid != 58 ) { next }
   
   # Calculate GAS actuals using activity observations
   inputobsname <<- "activity"
   obsname <<- "gasobs"
   rulename <<- "gasobs"
   
   print(paste("--->INSERTOBS --", userid, sep = ""))
   source("dogasobsins.R", echo = TRUE )
   
   print(paste("--->PUSHNOTIFICATION :", userid, sep = ""))
   source("../common/donotifications.R", echo = TRUE )

   print(paste("--->PLOTS :", userid, sep = ""))
   source("dogasobsplots.R", echo = TRUE )

}
