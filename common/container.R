
getFitbitObservations <- function( userid, username, obsname, fitbitkey, fitbitsecret, fitbitappname) {

  token_url <- "https://api.fitbit.com/oauth/request_token"
  access_url <- "https://api.fitbit.com/oauth/access_token"
  auth_url <- "https://www.fitbit.com/oauth/authorize"
  
  fbr <- oauth_app(fitbitappname, fitbitkey, fitbitsecret)
  fitbit <- oauth_endpoint(token_url, auth_url, access_url)
  #token = oauth1.0_token(fitbit, fbr)
  #saveRDS(token, file = paste("user/", username, "/fitbit-token.RDS", sep = ""))
  token <- readRDS(paste(usersdir, username, "/fitbit-token.RDS", sep=""))
  sig <- sign_oauth1.0(app=fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)
  
  startdate <- Sys.Date()-30
  enddate <- paste(Sys.Date(), ".json", sep="")
  
  if (obsname == "weight") {
    getURL <- "https://api.fitbit.com/1/user/-/body/log/weight/date/"
    getURL <- paste(getURL, startdate, "/", enddate, sep = "")
  } else if (obsname == "activity") {
    getURL <- "https://api.fitbit.com/1/user/-/activities/steps/date/"
    getURL <- paste(getURL, startdate, "/", enddate, sep = "")  
  }
  print(getURL)
  
  obsJSON <- tryCatch({
    GET(getURL, sig)
  }, warning = function(w) {
    print("Warning GET obs")
    stop()
  }, error = function(e) {
    print(geterrmessage())
    print("Error GET obs")
    stop()
  }, finally = {
  })
  
  if (obsname == "weight") if ( length(content(obsJSON)$`weight`) == 0 ) { stop("No observation records.") }
  if (obsname == "activity") if ( length(content(obsJSON)$`activities-steps`) == 0 ) { stop("No observation records.") }
  
  obsDF <- NULL

  if (obsname == "weight") {
    for (i in 1:length(content(obsJSON)$`weight`)) {
      row <- c( userid, obsname, paste(content(obsJSON)$`weight`[i][[1]][['date']], " 07:15:00", sep=""), content(obsJSON)$`weight`[i][[1]][['weight']] )
      obsDF <- rbind(obsDF, c(row))
    }
  } else if (obsname == "activity") {
    for (i in 1:length(content(obsJSON)$`activities-steps`)) {
      row <- c( userid, obsname, paste(content(obsJSON)$`activities-steps`[i][[1]][['dateTime']], " 07:15:00", sep=""), content(obsJSON)$`activities-steps`[i][[1]][['value']] )
      obsDF <- rbind(obsDF, c(row))
    }
  }
  
  colnames(obsDF) = c("userid", "obsname", "obsdate", "obsvalue")
  return(obsDF)
}

putKIEContainer <- function( url ) {

  fileName <- paste(templatesdir, '/put-KIEcontainer.xml', sep="");
  request <- readChar( fileName, file.info(fileName)$size )
  
  header=c(Connection="close", 'Content-Type'="application/xml; charset=utf-8", 'Content-length'=nchar(request))
  
  response <- tryCatch({
    PUT(url, body=request, content_type_xml(), header=header, verbose(), authenticate(jbossuser, jbosspassword, type="basic"))
  }, warning = function(w) {
    print("Warning POST")
    stop()
  }, error = function(e) {
    print(geterrmessage())
    print("Error POST")
    stop()
  }, finally = {
  })
  
  return( content(response, type="application/xml") )
}

postNudgeRequest <- function( url, request ) {
  
  header=c(Connection="close", 'Content-Type'="application/xml; charset=utf-8", 'Content-length'=nchar(request))
  
  response <- tryCatch({
    POST(url, body=request, content_type_xml(), header=header, add_headers('X-KIE-ContentType'="XSTREAM"), verbose(), authenticate(jbossuser, jbosspassword, type="basic"))
  }, warning = function(w) {
    print("Warning POST")
    stop()
  }, error = function(e) {
    print(geterrmessage())
    print("Error POST")
    stop()
  }, finally = {
  })
  
  # Tidy up response payload
  response <- saveXML( content(response, type="application/xml") )
  response <- gsub("&lt;", "<", response, fixed=TRUE)
  response <- gsub("&gt;", ">", response, fixed=TRUE)
  response <- gsub("&amp;quot;", '"', response, fixed=TRUE)
  
  list <- xmlToList(xmlTreeParse(response))
  
  return(list)
}

getNudgeRequest <- function( list, query ) {
   factDF = c()
   for ( i in 2:(length(list$result)-2) ) {
      factjson <- as.character( list$result[[i]]$com.redhat.weightwatcher.Fact$factjson )
      fact <- fromJSON( list$result[[i]]$com.redhat.weightwatcher.Fact$factjson )
      factDF <- rbind( factDF, c( userid=fact$userid, goalname=fact$goalname, obsdate=fact$obsdate, score=fact$score ) )
   }
   return(factDF)
}

buildParticipantFact <- function( username ) {
   factbody <- ''
   factid <- 0
   fileName <- paste(usersdir, username, '/Participant/fact.xml', sep="");
   fact <- readChar( fileName, file.info(fileName)$size )
   factbody <- paste(factbody, fact, sep=" ")
   return(factbody)
}

buildOptInOutFact <- function( username ) {
   factbody <- ''
   factid <- 0
   fileName <- paste(usersdir, username, '/OptInOut/fact.xml', sep="");
   fact <- readChar( fileName, file.info(fileName)$size )
   factbody <- paste(factbody, fact, sep=" ")
   return(factbody)
}

buildGASFact <- function( username, goalname ) {
   factbody <- ''
   factid <- 0
   fileName <- paste(usersdir, username, '/GAS/', goalname, '/fact.xml', sep="");
   fact <- readChar( fileName, file.info(fileName)$size )
   factbody <- paste(factbody, fact, sep=" ")
   return(factbody)
}

buildGoalFact <- function( username, obsname ) {
   factbody <- ''
   factid <- 0
   fileName <- paste(usersdir, username, '/Goal/', obsname, '/fact.xml', sep="");
   fact <- readChar( fileName, file.info(fileName)$size )
   factbody <- paste(factbody, fact, sep=" ")
   return(factbody)
}

buildObservationFact <- function( obsDF ) {
   factbody <- ''
   factid <- 0
   fileName <- paste(templatesdir, '/fact.xml', sep="");
   factname <- "Observation"
   for ( i in 1:nrow(obsDF) ) {
      fact <- readChar( fileName, file.info(fileName)$size )
      factid <- factid+1
      factjson <- paste('{ "userid" : ', obsDF[i, "userid"], ', "obsdate" : "', obsDF[i, "obsdate"], ' EST",', ' "obsname" : "', obsDF[i, "obsname"], '", "obsvalue" : ', as.integer(obsDF[i, "obsvalue"]), ' }', sep="")
      fact <- gsub("$(factid)", factid, fact, fixed=TRUE)
      fact <- gsub("$(factname)", factname, fact, fixed=TRUE)
      fact <- gsub("$(factjson)", factjson, fact, fixed=TRUE)
      factbody <- paste(factbody, fact, sep=" ")
   }
   return(factbody)
}

buildEnvelopeRequest <- function( factbody, query, params ) {
   fileName <- paste(templatesdir, '/fact-envelope.xml', sep="");
   request <- readChar( fileName, file.info(fileName)$size )
   request <- gsub("$(factbody)", factbody, request, fixed=TRUE)
   request <- gsub("$(query)", query, request, fixed=TRUE)
   request <- gsub("$(params)", params, request, fixed=TRUE)
   write( request, "input.xml" )
   print(request)
   return(request)
}

buildNudgeRequest <- function( userid, username, obsname, obsDF ) {
  
  factbody <- ''
  # Participants
  factid <- 0
  fileName <- paste(usersdir, username, '/Participant/fact.xml', sep="");
  fact <- readChar( fileName, file.info(fileName)$size )
  factbody <- paste(factbody, fact, sep=" ")
  
  # Goals
  fileName <- paste(usersdir, username, '/Goal/', obsname, '/fact.xml', sep="");
  fact <- readChar( fileName, file.info(fileName)$size )
  factbody <- paste(factbody, fact, sep=" ")
  
  # Observations
  factid <- 0
  fileName <- paste(templatesdir, '/fact.xml', sep="");
  factname <- "Observation"
  
  for ( i in 1:nrow(obsDF) ) {
    fact <- readChar( fileName, file.info(fileName)$size )
    factid <- factid+1
    factjson <- paste('{ "userid" : ', obsDF[i, "userid"], ', "obsdate" : "', obsDF[i, "obsdate"], ' EST",', ' "obsname" : "', obsDF[i, "obsname"], '", "obsvalue" : ', as.integer(obsDF[i, "obsvalue"]), ' }', sep="")
    fact <- gsub("$(factid)", factid, fact, fixed=TRUE)
    fact <- gsub("$(factname)", factname, fact, fixed=TRUE)
    fact <- gsub("$(factjson)", factjson, fact, fixed=TRUE)
    factbody <- paste(factbody, fact, sep=" ")
  }
  
  # Envelope
  fileName <- paste(templatesdir, '/fact-envelope.xml', sep="");
  envelope <- readChar( fileName, file.info(fileName)$size )
  request <- gsub("$(factbody)", factbody, envelope, fixed=TRUE)
  write( request, "input.xml" )
  
  print(request)
  return(request)

}

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

