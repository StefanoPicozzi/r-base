#!/usr/local/bin/Rscript
Sys.setenv(NOAWT = "true")

source("common/globals.R")
source("common/common.R")

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {
   
   userid <<- programuser["userid"]
   if ( userid != 7 ) { next }
   
   obsname <- "activity"
   print(paste("--->PLOTS fitbit :", userid, sep = ""))
   source("lifecoach/doplots/dofitbitplots.R", echo = TRUE )

   obsname <- "gas31"
   print(paste("--->PLOTS GAS :", userid, sep = ""))
   source("lifecoach/doplots/dogasplots.R", echo = TRUE )
   
   obsname <- "weight"
   print(paste("--->PLOTS weight :", userid, sep = ""))
   source("lifecoach/doplots/dowithingsplots.R", echo = TRUE )

   obsname <- "bmi"
   print(paste("--->PLOTS bmi :", userid, sep = ""))
   source("lifecoach/doplots/dowithingsplots.R", echo = TRUE )
   
   obsname <- "fat"
   print(paste("--->PLOTS fat :", userid, sep = ""))
   source("lifecoach/doplots/dowithingsplots.R", echo = TRUE )

   obsname <- "weight"
   print(paste("--->PLOTS regress weight :", userid, sep = ""))
   source("lifecoach/doplots/doregression.R", echo = TRUE )

   obsname <- "bmi"
   print(paste("--->PLOTS regress weight :", userid, sep = ""))
   source("lifecoach/doplots/doregression.R", echo = TRUE )

   obsname <- "fat"
   print(paste("--->PLOTS regress weight :", userid, sep = ""))
   source("lifecoach/doplots/doregression.R", echo = TRUE )
   
}