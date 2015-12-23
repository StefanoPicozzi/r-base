
rootdir <<- paste(getwd(), "/lifecoach", sep="")
datadir <<- paste(getwd(), "/lifecoach/data", sep="")

# Default test case
if ( !exists("userid") ) { userid <<- 7 }
if ( !exists("programid") ) { programid <<- 1 }
if ( !exists("obsname") ) { obsname <<- "weight" }

containerurl <<- "http://192.168.99.100:8080"
#containerurl <<- "http://weightwatcher.cloudapps.example.com"
#containerurl <<- "http://192.168.59.103:8080"
containerurl <- paste( containerurl, "/kie-server/services/rest/server/containers/instances/watch", sep = "" )

#rooturl <<- "http://localhost:8080/tnm/rest"
#rooturl <- "http://nudgeserver.cloudapps.example.com/tnm/rest"
rooturl <<- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"

imagesdir <<- paste(getwd(), "/data/images/", sep="")
templatesdir <<- paste(getwd(), "/data/templates/", sep="")
usersdir <<- paste(getwd(), "/data/users/", sep="")

ppi <<- 300
