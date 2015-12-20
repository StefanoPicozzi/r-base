#!/usr/bin/env Rscript
print("--> Installing packages")

packages <- c(
   "rJava",
   "Rcpp",
   "RColorBrewer",
   "dichromat",
   "munsell",
   "labeling",
   "plyr",
   "digest",
   "gtable",
   "reshape2",
   "scales",
   "proto",
   "ggplot2",
   "png",
   "xlsxjars",
   "rjson",
   "rgl",
   "xlsx",
   "jsonlite",
   "mime",
   "curl",
   "R6",
   "httr",
   "bitops",
   "RCurl",
   "XML",
   "base64enc",
   "stringi",
   "magrittr",
   "colorspace",
   "xts"
)

for (package in packages) {
   if (package %in% rownames(installed.packages()) == FALSE) {
      print(package)
      install.packages(package)
   }
}

quit("no")
