#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

source("common/globals.R")
source("common/common.R")

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

   if ( userid != 7 ) { next }

   obsname <- "activity"
   print(paste("---> Nudge activity ", userid, sep = ""))
   tryCatch({
      source("lifecoach/donudge/nudge.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {
   })

   obsname <- "weight"
   print(paste("---> Nudge weight ", userid, sep = ""))
   tryCatch({
      source("lifecoach/donudge/nudge.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {
   })

   obsname <- "gas31"
   print(paste("---> Nudge gas31 ", userid, sep = ""))
   tryCatch({
      source("lifecoach/donudge/nudge.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {
   })
   
}
