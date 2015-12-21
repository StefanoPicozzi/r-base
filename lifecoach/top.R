
return(0)

print("Top top")

result = tryCatch( {
   source("../../test.R")
}, error = function(err) {
   print("Script stopped")
}, finally = {   
})


print("Top bottom")
