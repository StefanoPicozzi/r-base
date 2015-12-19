#!/usr/bin/env Rscript
print("--> Installing packages")

packages <- c(
   "rJava",
   "Rcpp",
   "RColorBrewer",
   "dichtomat",
   "munsell",
   "labeling",
   "plyr",
   "digest",
   "gtable",
   "reshap2",
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
   "colorspace"
)

for (package in packages) {
   if (package %in% rownames(installed.packages()) == FALSE) {
      install.packages(package)
   }
}

quit("no")
