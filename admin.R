# Code used to manage users and passwords

# # Create credentials directory and data frame on first usage
#   if (!dir.exists("credentials/")) {
#     dir.create("credentials/")
#   }
#     
#   if (!file.exists("credentials/credentials.rds")) {
#     credentials <- data.frame(user = character(), 
#                               pw = character(), 
#                               locked_out = logical(),
#                               stringsAsFactors = FALSE)
#     
#     saveRDS(credentials, "credentials/credentials.rds")
#   }
  
# Function to add users
  add_user <- function(user, pw) {
    require(digest)
    
    # check inputs
    if (!is.character(user)) stop("User name must be a character string.")
    if (!is.character(pw)) stop("User password must be a character string.")
    if (!(length(user) == 1)) stop("User name must be length 1 (cannot be a vector).")
    if (!(length(pw) == 1)) stop("User password must be length 1 (cannot be a vector).")
    
    # add user
    credentials <- readRDS("credentials/credentials.RDS")
    
    if (user %in% credentials$user) stop("User already exists - choose a different user name.")
    
    row <- nrow(credentials) + 1
    
    credentials[row, "user"] <- user
    credentials[row, "pw"] <- digest(pw)
    credentials[row, "locked_out"] <- FALSE
    
    # check for rows with blank user names or password
    if (any(is.na(credentials[, "user"]) | 
        credentials[, "user"] == "")) {
      stop("An entry in the credentials data frame is missing a user name - please correct.")
    }
    if (any(is.na(credentials[, "pw"]) | 
        credentials[, "pw"] == "")) {
      stop("An entry in the credentials data frame is missing a password.")    
    }
    
    saveRDS(credentials, "credentials/credentials.rds")    
  }
