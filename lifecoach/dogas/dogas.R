#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

source("common/globals.R")
source("common/common.R")

# Do programid=1 and activity observations
programid <<- 1

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

  userid <<- programuser["userid"]

  if ( userid != 7 ) { next }

  # pollidlist <<- c(15, 16, 18, 17)
  pollidlist <<- c(17)
  for (polliditem in pollidlist) {

    pollid <<- polliditem
    if ( pollid == 15 ) { gastype <<- "gas11" }
    if ( pollid == 16 ) { gastype <<- "gas12" }
    if ( pollid == 18 ) { gastype <<- "gas21" }
    if ( pollid == 17 ) { gastype <<- "gas31" }

    print(paste("--->APPLYNUDGES: ", userid, "-", gastype, sep = ""))
    tryCatch({
       obsname <<- gastype
       rulename <<- "gas"
       source("common/donudges.R", echo = TRUE )
    }, error = function(err) {
       print(geterrmessage())
    }, finally = {
    })

    print(paste("--->PLOTS: ", userid, "-", gastype, sep = ""))
    tryCatch({
       obsname <<- gastype
       source("dogas/dogasplots.R", echo = TRUE )
    }, error = function(err) {
       print(geterrmessage())
    }, finally = {
    })

  }

  print(paste("--->PUSHNOTIFICATION: ", userid, sep = ""))
  tryCatch({
     source("common/donotifications.R", echo = TRUE )
  }, error = function(err) {
     print(geterrmessage())
  }, finally = {
  })

}
