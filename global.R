library(shiny)
library(digest)

############# FOR TESTING ONLY - DELETE THIS CODE before using app!!!

# credentials data frame for testing (username = "test" and password = "password")
# NOTE: in real use this would open an existing data frame containing user credentials

  if (!file.exists("credentials/credentials.rds")) {
    credentials <- data.frame(user = "test", 
                              pw = "380796939c86c55d6aa8ea8c941f7652", 
                              locked_out = FALSE,
                              stringsAsFactors = FALSE)
    
    saveRDS(credentials, "credentials/credentials.rds")
  }
    
############# CODE ABOVE FOR TESTING ONLY!!!
  
# set the number of failed attempts allowed before user is locked out

num_fails_to_lockout <- 3
