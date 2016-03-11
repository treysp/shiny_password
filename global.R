library(shiny)
library(digest)

# credentials data frame for testing (username = "test" and password = "password")
# NOTE: in real use this would open an existing data frame containing user credentials
credentials <- data.frame(user = "test", 
                          pw = "380796939c86c55d6aa8ea8c941f7652", 
                          locked_out = FALSE,
                          stringsAsFactors = FALSE)

num_fails_to_lockout <- 2
