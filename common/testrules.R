# Script to author and test rules files using Drools6 packages inside R
# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(httr)
library(rjson)
library("RMySQL")
library("Rdrools6")
ls("package:Rdrools6", all = TRUE)
lsf.str("package:Rdrools6", all = TRUE)

# Input test parameters section
rootdir <- "/Users/stefanopicozzi/websites/nudge/R/lifecoach/common"
rooturl <- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
#obsname <- "activity"
obsname <- "gas11"
#rulefile <- "fitbit.drl"
rulefile <- "gas.drl"
programid <- 1
userid <- 7
setwd(rootdir)
source("common.R")

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

# Apply rules file
input.columns <- colnames(userobsDF)
output.columns <-c ("id", "rulename", "ruledate", "rulemsg", "ruledata")
input.columns <- colnames(userobsDF)
rules <- readLines(rulefile)
mode <- "STREAM"
rules.session <- rulesSession(mode, rules, input.columns, output.columns)
outputDF <- runRules(rules.session, userobsDF)

for (i in 1:nrow(outputDF)) {
  rule <- getRule(rooturl, outputDF[i, "rulename" ] )
  ruleid <- 999
  if (length(rule) > 0) {
    ruleid <- rule[[1]]$ruleid
  }
  msg <- paste("{ \"programid\" :", programid, ", \"userid\" :", userid, ", \"ruleid\" :", ruleid, ", \"rulename\" :", outputDF[i, "rulename"], ", \"ruledate\" :", outputDF[i, "ruledate"], ", \"msgtxt\" :", outputDF[i, "rulemsg"], " }", sep="")
  print(msg)
  print(nchar(as.character(msg)))
}
