library("xlsx")
library("lattice")
library("MASS")

getwd()
setwd("/Users/stefanopicozzi/tnm/tnmbatch/R/lifecoach/dosolar")
list.files()

#inputRollDF <- read.csv(file = "Solar.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE)

inputsolarDF <- read.csv(file = "Solar.csv", header = FALSE, sep = ";", stringsAsFactors = FALSE)
solarnames <- c()
for (i in 1:ncol(inputsolarDF)) {
   solarname <- inputsolarDF[1,i]
   n <- regexpr(" ", solarname)
   if ( n > 0 ) {
      solarname <- substr(solarname, 1, n)
   }  
   solarnames <- cbind(solarnames, solarname)
}
inputsolarDF <- inputsolarDF[-1,]
solarDF <- inputsolarDF
colnames(solarDF) = solarnames






outputRollDF <- c()
pageno <- 1047
rollno <- 8616
hit <- 0
for (i in 1:nrow(rollDF)) {
   
   LASTNAME <- as.character(rollDF[i, "LASTNAME"])   

   if ( is.na(LASTNAME) ) {
      next
   }
   if ( nchar(LASTNAME) < 2 ) {
      next
   }
   
   hit <- grep("Given Name", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("Printed", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("Surname", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("Vote", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("Address", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }   
   hit <- grep("Page", LASTNAME)   
   if (length(hit) > 0 ) {
      hit <- grep("of", LASTNAME)   
      if (length(hit) > 0 ) {
         ofpos <- gregexpr("of", LASTNAME)
         ofposno <- ofpos[[1]][1]
         pagepos <- gregexpr("Page", LASTNAME)
         pageposno <- pagepos[[1]][1]
         pageno <- as.numeric(substr(LASTNAME, pageposno + 4, ofposno - 1)) + 1
         next
      }
   }
   hit <- grep("All Wards", LASTNAME)   
   if (length(hit) > 0 ) {
      pageno <- pageno + 1
      next
   }
   hit <- grep("status Ward", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep(" PM", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("PM ", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
   hit <- grep("/", LASTNAME)   
   if (length(hit) > 0 ) {
      next
   }
      
   rollno <- rollno + 1
   lastname <- LASTNAME
   
   firstname <- ''
   firstnametmp <- as.character(rollDF[i, "FIRSTNAME"])
   if ( !is.na(firstnametmp)) { firstname <- firstnametmp }

   propertyaddress <- ''
   propertyaddresstmp <- as.character(rollDF[i, "PROPERTYADDRESS"])
   if ( !is.na(propertyaddresstmp)) { propertyaddress <- propertyaddresstmp }
   
   C1 <- as.character(rollDF[i, "C1"])   
   C2 <- as.character(rollDF[i, "C2"])   
   C3 <- as.character(rollDF[i, "C3"])   
   
   postcode <- ''
   if ( !is.na(C1) ) {
      hit <- grep("5", C1)   
      if (length(hit) > 0 ) {
         postcode <- C1
      }
   }
   
   votestatus <- ''
   if ( !is.na(C2) ) {
      hit <- grep("BOTH", C2)   
      if (length(hit) > 0 ) {
         votestatus <- C2
      }
   }
   
   if ( !is.na(C1) ) {
      hit <- grep("BOTH", C1)   
      if (length(hit) > 0 ) {
         votestatus <- C1
      }
   }

   ward <- ''
   if ( !is.na(C2) ) {
      hit <- grep("([1-9])", C2)
      if ( length(hit) > 0 ) { 
         ward <- C2
      }
   }
   if ( !is.na(C3) ) { 
      hit <- grep("([1-9])", C3)
      if ( length(hit) > 0 ) { 
         ward <- C3
      }
   } 
   
   if ( !is.na(propertyaddress) ) {
      hit <- grep("BOTH", propertyaddress)      
      if ( length(hit) > 0 ) {
         votestatus <- propertyaddress
         if ( !is.na(C1) ) { 
            ward <- C1 
         }
         propertyaddress <- ''
      }
   }
   
   postaladdress <- ''
   n <- regexpr(" ", lastname)
   if ( n > 0 ) {
      postaladdress = substr(lastname, n, nchar(lastname) )
   } else {
      postaladdress <- propertyaddress
   }
   lastletter <- substr(lastname, nchar(lastname), nchar(lastname) )
   
   outputRollDF <- rbind(outputRollDF, 
      c( PAGENO = pageno, 
         ROLLNO = rollno, 
         LASTNAME = lastname, 
         FIRSTNAME = firstname,   
         PROPERTYADDRESS = propertyaddress,
         POSTCODE = postcode,
         VOTESTATUS = votestatus,
         WARD = ward,
         POSTALADDRESS = postaladdress,
         LASTLETTER = lastletter
      ))
   
   print(
      paste(
         pageno, ", ",          
         rollno, ", ", 
         lastname, ", ", 
         firstname, ", ", 
         propertyaddress, ", ", 
         postcode, ", ",          
         votestatus, ", ", 
         ward, ", ", 
         lastletter, " ", 
         separator = ""))

}


