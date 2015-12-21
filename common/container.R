
getWeightObservations <- function( username, fitbitkey, fitbitsecret, fitbitappname) {

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
  enddate <- paste(Sys.Date()+1, ".json", sep="")   
  
  getURL <- "https://api.fitbit.com/1/user/-/body/log/weight/date/"
  getURL <- paste(getURL, startdate, "/", enddate, sep = "")
  print(getURL)
  
  weightJSON <- tryCatch({
    GET(getURL, sig)
  }, warning = function(w) {
    print("Warning weight")
    stop()
  }, error = function(e) {
    print(geterrmessage())
    print("Error GET fitbit weight")
    stop()
  }, finally = {
  })
  
  if ( length(content(weightJSON)$`weight`) == 0 ) { stop("No fitbit weight records") }
  
  weightDF <- NULL
  
  for (i in 1:length(content(weightJSON)$`weight`)) {
    row <- c( username, paste(content(weightJSON)$`weight`[i][[1]][['date']], " 07:15:00", sep=""), content(weightJSON)$`weight`[i][[1]][['weight']] )
    weightDF <- rbind(weightDF, c(row))
  }
  
  colnames(weightDF) = c("username", "obsdate", "obsvalue")
  
  return(weightDF)
}

putKIEContainer <- function( url ) {

  fileName <- 'templates/put-KIEcontainer.xml';
  request <- readChar( fileName, file.info(fileName)$size )
  
  header=c(Connection="close", 'Content-Type'="application/xml; charset=utf-8", 'Content-length'=nchar(request))
  
  response <- tryCatch({
    PUT(url, body=request, content_type_xml(), header=header, verbose(), authenticate("erics", "jbossbrms1!", type="basic"))
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
    POST(url, body=request, content_type_xml(), header=header, add_headers('X-KIE-ContentType'="XSTREAM"), verbose(), authenticate("erics", "jbossbrms1!", type="basic"))
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

buildNudgeRequest <- function( userid, username, DF ) {
  
  factbody <- ''
  # Participants
  factid <- 0
  fileName <- paste(usersdir, username, '/Participant/fact.xml', sep="");
  fact <- readChar( fileName, file.info(fileName)$size )
  factbody <- paste(factbody, fact, sep=" ")
  
  # Goals
  fileName <- paste(usersdir, username, '/Goal/fact.xml', sep="");
  fact <- readChar( fileName, file.info(fileName)$size )
  factbody <- paste(factbody, fact, sep=" ")
  
  # Observations
  factid <- 0
  fileName <- paste(templatesdir, '/fact.xml', sep="");
  factname <- "Observation"
  
  for ( i in 1:nrow(weightDF) ) {
    fact <- readChar( fileName, file.info(fileName)$size )
    factid <- factid+1
    factjson <- paste('{ "userid" : ', userid, ', "obsdate" : "', DF[i, "obsdate"], ' EST",', ' "obsname" : "weight", "obsvalue" : ', as.integer(DF[i, "obsvalue"]), ' }', sep="")
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

