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

   print(paste("--->WEIGHTWATCHER --", userid, sep = ""))
   tryCatch({
      source("doweightwatcher/weightwatcher.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {
   })

}
