# Nudge common functions

library(httr)
library(rjson)
library('RCurl')

sendPushover <- function(pushoveruser, msgtxt) {

  curl_cmd = paste(
    "curl -s",
    " -F \"token=acqa2Xgn6Fj7NsctUaxqPm8ngURksP\" ",
    " -F \"user=", pushoveruser, "\" ",
    " -F \"message=", msgtxt, "\" ",
    " https://api.pushover.net/1/messages.json",
    sep = "")

  result <- tryCatch({
    system(curl_cmd)
  }, warning = function(w) {
    print("Warning sendPushover")
    stop()
  }, error = function(e) {
    print("Error sendPushover")
    stop()
  }, finally = {
  })
  return(result)
}

getRulefile <- function(rooturl, programid, groupid, rulename) {
  rulefileJSON <- tryCatch({
    getURL(paste(rooturl, "/rulefile?programid=", programid, "&groupid=", groupid, "&rulename=", rulename, sep=""))
  }, warning = function(w) {
    print("Warning")
  }, error = function(e) {
    print("Error getRulefile")
    message(e)
    stop()
  }, finally = {
  })
  rulefile <- fromJSON(rulefileJSON)
  return(rulefile)
}

getNudge <- function(rooturl, programid, groupid, factname, rulename) {
  result <- tryCatch({
    facts <- getURL(paste(rooturl, "/nudge?", "programid=", programid, "&groupid=", userid, "&factname=", factname, "&rulename=", rulename, sep=""))
  }, warning = function(w) {
    print("Warning getNudge")
  }, error = function(e) {
    print("Error getNudge")
    message(e)
    stop()
  }, finally = {
  })
  print(result)
}

getFactDF <- function(rooturl, programid, groupid, factname) {
  factJSON <- tryCatch({
    getURL(paste(rooturl, "/fact/user?programid=", programid, "&groupid=", groupid, "&factname=", factname, sep=""))
  }, warning = function(w) {
    print("Warning getFactDF")
  }, error = function(e) {
    print("Error getFactDF")
    message(e)
    stop()
  }, finally = {
  })
  facts <- fromJSON(factJSON)
  factDF = c()
  for (fact in facts ) {
    factDF <- cbind( factDF, c( id=fact$id, programid=fact$programid, groupid=fact$groupid, factjson=fact$factjson ) )
  }
  factDF <- t(factDF)
  return(factDF)
}

getFactsystem <- function(rooturl, programid, groupid, factname) {
  factJSON <- tryCatch({
    getURL(paste(rooturl, "/fact/system?programid=", programid, "&groupid=", groupid, "&factname=", factname, sep=""))
  }, warning = function(w) {
    print("Warning getFactsystem")
  }, error = function(e) {
    print("Error getFactsystem")
    message(e)
    stop()
  }, finally = {
  })
  return(fromJSON(factJSON))
}

getFactsystemDF <- function(rooturl, programid, groupid, factname) {
  factJSON <- tryCatch({
    getURL(paste(rooturl, "/fact/system?programid=", programid, "&groupid=", groupid, "&factname=", factname, sep=""))
  }, warning = function(w) {
    print("Warning getFactsystemDF")
  }, error = function(e) {
    print("Error getFactsystemDF")
    message(e)
    stop()
  }, finally = {
  })
  facts <- fromJSON(factJSON)
  return(as.data.frame(do.call(rbind, facts)))

#  facts <- fromJSON(factJSON)
#  factDF = c()
#  for (fact in facts) {
#    factDF <- cbind( factDF, c( id=fact$id, programid=fact$programid, groupid=fact$groupid, factjson=fact$factjson ) )
#  }
#  factDF <- t(factDF)
#  return(factDF)
}

delFact <- function(rooturl, programid, groupid, factname) {
  result <- tryCatch({
    getURL(paste(rooturl, "/fact/del?programid=",programid, "&groupid=", groupid, "&factname=", factname, sep=""))
  }, warning = function(w) {
    print("Warning delFact")
  }, error = function(e) {
    print("Error delFact")
    message(e)
    stop()
  }, finally = {
  })
  return(result)
}


postFact <- function(rootusr, programid, groupid, factname, userobsDF) {
  for (i in 1:nrow(userobsDF)) {

    #JSON <- paste("{ \"programid\" :", programid, ", \"groupid\" :", groupid, ", \"facttype\" : 0", ", \"factjson\" :\"", toString(toJSON(userobsDF[i,])), "\"  }", sep="")
    #curl.opts <- list(postfields = JSON, httpheader = c("Content-Type: application/json", "Accept: application/json"), useragent = "RCurl", ssl.verifypeer = FALSE)

    username <- userobsDF[i, "username"]
    obsname <- userobsDF[i, "obsname"]
    obsdate <- userobsDF[i, "obsdate"]
    obsdate <- paste("\"", obsdate, "\"", sep="")
    obsvalue <- userobsDF[i, "obsvalue"]
    gasboundary1 <- NULL
    gasboundary2 <- NULL
    gasboundary3 <- NULL
    gasboundary4 <- NULL

    if ( "gasboundary1" %in% colnames(userobsDF) ) { gasboundary1 <- userobsDF[i, "gasboundary1"] }
    if ( "gasboundary2" %in% colnames(userobsDF) ) { gasboundary2 <- userobsDF[i, "gasboundary2"] }
    if ( "gasboundary3" %in% colnames(userobsDF) ) { gasboundary3 <- userobsDF[i, "gasboundary3"] }
    if ( "gasboundary4" %in% colnames(userobsDF) ) { gasboundary4 <- userobsDF[i, "gasboundary4"] }

    obsdesc <- "\"Generated using R sysbatch procedure\"";

    if ( is.null( gasboundary1 ) ) {
      factjson <- paste('{ \"username\":', username,
                      ', \"obsname\":', obsname,
                      ', \"obsdate\":', obsdate,
                      ', \"obsvalue\":', obsvalue,
                      ', \"obsdesc\":', obsdesc, '}' )
    } else {
       factjson <- paste('{ \"username\":', username,
                         ', \"obsname\":', obsname,
                         ', \"obsdate\":', obsdate,
                         ', \"obsvalue\":', obsvalue,
                         ', \"gasboundary1\":', gasboundary1,
                         ', \"gasboundary2\":', gasboundary2,
                         ', \"gasboundary3\":', gasboundary3,
                         ', \"gasboundary4\":', gasboundary4,
                         ', \"obsdesc\":', obsdesc, '}' )

    }

    #  params <- paste("programid=", programid, "&groupid=", userid, "&factjson=", factjson, sep="")
    #  url <- paste("curl -X POST --data '", params, "' ", rooturl, "/fact", sep="")

    result <- tryCatch({
      # postForm( paste(rooturl, "/fact", sep=""), .opts = curl.opts )
      postForm( paste(rooturl, "/fact", sep=""), programid=programid, groupid=groupid, factname=factname, factjson=factjson, style="POST"  )
      # system(url)
      print(paste("Posting fact-->", factjson, sep=""))
    }, warning = function(w) {
      print("Warning postFact")
    }, error = function(e) {
      print("Error postFact")
      message(e)
      stop()
    }, finally = {
    })
  }
  return(result)
}

getProgramuser <- function(rooturl, programid) {
  programuserJSON <- tryCatch({
    getURL(paste(rooturl, "/programuser/user?programid=", programid, sep=""))
  }, warning = function(w) {
    print("Warning gerProgramuser")
  }, error = function(e) {
    print("Error getProgramuser")
    message(e)
    stop()
  }, finally = {
  })
  programuser <- fromJSON(programuserJSON)
  return(programuser)
}

getProgramuserDF <- function(rooturl, programid) {
   programuserJSON <- tryCatch({
      getURL(paste(rooturl, "/programuser/user?programid=", programid, sep=""))
   }, warning = function(w) {
      print("Warning getProgramuserDF")
   }, error = function(e) {
      print("Error getProgramuserDF")
      message(e)
      stop()
   }, finally = {
   })
   programusers <- fromJSON(programuserJSON)
   programuserDF = c()
   for (programuser in programusers) {
      programuserDF <- cbind( programuserDF, c( userid=programuser$userid, roletype=programuser$roletype ) )
   }
   programuserDF <- t(programuserDF)
   programuserDF <- subset(programuserDF, programuserDF[,"roletype"] == "participant")
   return(programuserDF)
}

getProgramruleuserDF <- function(rooturl, programid, userid) {
   programruleuserJSON <- tryCatch({
      getURL(paste(rooturl, "/programruleuser", sep=""))
   }, warning = function(w) {
      print("Warning gerProgramruleuser")
   }, error = function(e) {
      print("Error getProgramruleuser")
      message(e)
      stop()
   }, finally = {
   })
   programruleusers <- fromJSON(programruleuserJSON)
   programruleuserDF = c()
   for (programruleuser in programruleusers) {
         programruleuserDF <- cbind( programruleuserDF,
            c( programid = programruleuser$programid,
               userid = programruleuser$userid,
               ruleid = programruleuser$ruleid,
               rulelow = programruleuser$rulelow,
               rulehigh = programruleuser$rulehigh ) )
   }
   programruleuserDF <- t(programruleuserDF)
   programruleuserDF <- subset(programruleuserDF, programruleuserDF[,"programid"] == programid)
   programruleuserDF <- subset(programruleuserDF, programruleuserDF[,"userid"] == userid)
   return(programruleuserDF)
}

getUser <- function(rooturl, userid) {
   userJSON <- tryCatch({
      getURL(paste(rooturl, "/user/user?userid=", userid, sep=""))
   }, warning = function(w) {
      print("Warning getUser")
   }, error = function(e) {
      print("Error getUser")
      message(e)
      stop()
   }, finally = {
   })

   user <- fromJSON(userJSON)
   return(user)
}

getRule <- function(rooturl, rulename) {
  ruleJSON <- tryCatch({
    getURL(paste(rooturl, "/rule?rulename=", rulename, sep=""))
  }, warning = function(w) {
    print("Warning getRule")
  }, error = function(e) {
    print("Error getRule")
    message(e)
    stop()
  }, finally = {
  })
  rule <- fromJSON(ruleJSON)
  return(rule)
}

postUserobs <- function(rooturl, userobs) {

   JSON <- paste("{ \"programid\" :", userobs["programid"], ", \"userid\" :", userobs["userid"], ", \"obsname\" :", userobs["obsname"], ", \"obsvalue\" :", userobs["obsvalue"], ", \"obsdesc\" :", userobs["obsdesc"], ", \"obsdate\" :", userobs["obsdate"], ", \"obstype\" : \"userobs\" }", sep="")
   curl.opts <- list(postfields = JSON, httpheader = c("Content-Type: application/json", "Accept: application/json"), useragent = "RCurl", ssl.verifypeer = FALSE)
   print(JSON)

   result <- tryCatch({
      postForm( paste(rooturl, "/userobs", sep=""), .opts = curl.opts )
      print(paste("Posting userobs-->", JSON, sep=""))
   }, warning = function(w) {
      print("Warning postUserobs")
   }, error = function(e) {
      print("Error postUserobs")
      message(e)
      stop()
   }, finally = {
   })
   return(result)
}

delUserobs <- function(rooturl, programid, userid, obsname) {

   result <- tryCatch({
      getURL(paste(rooturl, "/userobs/del?programid=", programid, "&userid=", userid, "&obsname=", obsname, sep=""))
   }, warning = function(w) {
      print("Warning")
   }, error = function(e) {
      print("Error delUserobs")
      message(e)
      stop()
   }, finally = {
   })

   return(result)
}

getUserobs <- function(rooturl, programid, userid, obsname) {
  userobsJSON <- tryCatch({
    getURL(paste(rooturl, "/userobs/user?programid=", programid, "&userid=", userid, "&obsname=", obsname, sep=""))
  }, warning = function(w) {
    print("Warning getUserobs")
  }, error = function(e) {
    print("Error getUserobs")
    message(e)
    stop()
  }, finally = {
  })
  print(userobsJSON)
  return(fromJSON(userobsJSON))
}

getMaxobsdate <- function(rooturl, programid, userid, obsname) {
  userobsJSON <- tryCatch({
    getURL(paste(rooturl, "/userobs/user?programid=", programid, "&userid=", userid, "&obsname=", obsname, sep=""))
  }, warning = function(w) {
    print("Warning getUserobs")
  }, error = function(e) {
    print("Error getUserobs")
    message(e)
    stop()
  }, finally = {
  })
  userobss <- fromJSON(userobsJSON)
  userobsDF <- c()
  if (length(userobss) == 0) { return("1970-01-01 00:00:00") }
  for (userobs in userobss) {
    obsdate <- toString(as.POSIXlt( as.numeric(userobs$obsdate)/1000, origin="1970-01-01 00:00:00" ))
    userobsDF <- rbind( userobsDF, c( id=userobs$userobsid, username=userobs$userid, obsname=userobs$obsname, obsdate=obsdate, obsvalue=userobs$obsvalue ) )
  }

  if (nrow(userobsDF) > 0) {
    userobsDF <- userobsDF[ order(userobsDF[, "obsdate"], decreasing = TRUE), ]
    return(userobsDF[1, "obsdate"])
  } else {
    return("1970-01-01 00:00:00")
  }
}

getUserobsDF <- function(rooturl, programid, userid, obsname) {
   userobsJSON <- tryCatch({
      getURL(paste(rooturl, "/userobs/user?programid=", programid, "&userid=", userid, "&obsname=", obsname, sep=""))
   }, warning = function(w) {
      print("Warning getUserobsDF")
   }, error = function(e) {
      print("Error getUserobsDF")
      message(e)
      stop()
   }, finally = {
   })

   userobsDF <- NULL
   if ( is.null(userobsJSON) ) { return(userobsDF) }

   userobss <- fromJSON(userobsJSON)

   for (userobs in userobss) {
      obsdate <- toString(as.POSIXlt( as.numeric(userobs$obsdate)/1000, origin="1970-01-01 00:00:00" ))
      userobsDF <- cbind( userobsDF, c( id=userobs$userobsid, username=userobs$userid, obsname=userobs$obsname, obsdate=obsdate, obsvalue=userobs$obsvalue ) )
   }
   userobsDF <- t(userobsDF)
   userobsDF <- userobsDF[order(userobsDF[, "obsdate"]),]
   return(userobsDF)
}

getUserdiaryDF <- function(rooturl, programid, userid) {
  userdiaryJSON <- tryCatch({
    getURL(paste(rooturl, "/userdiary/user?programid=", programid, "&userid=", userid, sep=""))
  }, warning = function(w) {
    print("Warning getUserdiaryDF")
  }, error = function(e) {
    print("Error getUserdiaryDF")
    message(e)
    stop()
  }, finally = {
  })

  userdiaryDF <- NULL
  if ( is.null(userdiaryJSON) ) { return(userdiaryDF) }

  userdiarys <- fromJSON(userdiaryJSON)

  for (userdiary in userdiarys) {
    diarydate <- toString(as.POSIXlt( as.numeric(userdiary$diarydate)/1000, origin="1970-01-01 00:00:00" ))
    userdiaryDF <- cbind( userdiaryDF, c( id=userdiary$userdiaryid, username=userdiary$userid, diarylabel=userdiary$diarylabel, diarydate=diarydate, diarytxt=userdiary$diarytxt ) )
  }
  userdiaryDF <- t(userdiaryDF)
  userdiaryDF <- userdiaryDF[order(userdiaryDF[, "diarydate"]),]
  return(userdiaryDF)
}

getOptinruleviewDF <- function(rooturl, programid, userid) {
   optinruleviewJSON <- tryCatch({
      getURL(paste(rooturl, "/optinruleview/user?programid=", programid, "&userid=", userid, sep=""))
   }, warning = function(w) {
      print("Warning")
   }, error = function(e) {
      print("Error getOptinruleviewDF")
      message(e)
      stop()
   }, finally = {
   })
   optinruleviews <- fromJSON(optinruleviewJSON)
   optinruleviewDF = c()
#   lapply(optinruleview, function(rulename=optinruleview$rulename) { cbind( optinruleviewDF, c(rulename) ) } )
   for (optinruleview in optinruleviews) {
      optinruleviewDF <- cbind( optinruleviewDF, c( rulename=optinruleview$rulename ) )
   }
   optinruleviewDF <- t(optinruleviewDF)
   optinruleviewDF <- optinruleviewDF[order(optinruleviewDF[, "rulename"]),]
   return(optinruleviewDF)
}


getMsg <- function(rooturl, programid, userid) {
  msgJSON <- tryCatch({
    getURL(paste(rooturl, "/msg/isnotsent?programid=", programid, "&userid=", userid, sep=""))
  }, warning = function(w) {
    print("Warning getMsg")
  }, error = function(e) {
    print("Error getMsg")
    message(e)
    stop()
  }, finally = {
  })
  print(msgJSON)
  return( fromJSON(msgJSON) )
}

getMsgDF <- function(rooturl, programid, userid) {
   msgJSON <- tryCatch({
      getURL(paste(rooturl, "/msg/isnotsent?programid=", programid, "&userid=", userid, sep=""))
   }, warning = function(w) {
      print("Warning getMsgDF")
   }, error = function(e) {
      print("Error getMsgDF")
      message(e)
      stop()
   }, finally = {
   })
   msgs <- fromJSON(msgJSON)
   msgDF <- c()
   for (msg in msgs) {
      msgdate <- toString(as.POSIXlt( as.numeric(msg$ruledate)/1000, origin="1970-01-01 00:00:00" ))
      msgDF <- cbind( msgDF, c( msgid=msg$msgid, userid=msg$userid, rulename=msg$rulename, msgdate=msgdate, msgtxt=msg$msgtxt ) )
   }
   msgDF <- t(msgDF)
   return(msgDF)
}

postMsg <- function(rootusr, msg) {
  JSON <- paste("{ \"programid\" :", msg["programid"], ", \"userid\" :", msg["userid"], ", \"ruleid\" :", msg["ruleid"], ", \"rulename\" :", msg["rulename"], ", \"ruledate\" :", msg["ruledate"], ", \"msgtxt\" :", msg["msgtxt"], " }", sep="")
  curl.opts <- list(postfields = JSON, httpheader = c("Content-Type: application/json", "Accept: application/json"), useragent = "RCurl", ssl.verifypeer = FALSE)
  result <- tryCatch({
    print(paste("Posting msg-->", JSON, sep=""))
    postForm( paste(rooturl, "/msg", sep=""), .opts = curl.opts )
  }, warning = function(w) {
    print("Warning postMsg")
  }, error = function(e) {
    print("Error postMsg")
    message(e)
    stop()
  }, finally = {
  })
  return(result)
}

setMsgissent <- function(rooturl, msgid) {
      msgJSON <- tryCatch({
      getURL(paste(rooturl, "/msg/issent?msgid=", msgid, sep=""))
   }, warning = function(w) {
      print("Warning")
   }, error = function(e) {
      print("Error setMsgissent")
      message(e)
      stop()
   }, finally = {
   })
}
