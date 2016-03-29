# Code used to manage users and passwords

# Function to create credentials directory and data frame on first usage
credentials_init <- function() {
  if (!dir.exists("credentials/")) {
    dir.create("credentials/")
  }

  if (!file.exists("credentials/credentials.rds")) {
    credentials <- data.frame(user = character(),
                              pw = character(),
                              locked_out = logical(),
                              stringsAsFactors = FALSE)

    saveRDS(credentials, "credentials/credentials.rds")
  }
}  
  
# Function to add a single user
add_one_user <- function(user, pw) {
  require(digest)
  
  # check inputs
  if (!is.character(user) || !(length(user) == 1) ||
      is.na(user) || user == "") {
    stop("User name must be a non-blank character string of length 1 (cannot be a vector).")
  }
  if (!is.character(pw) || !(length(pw) == 1) ||
      is.na(pw) || pw == "") {
    stop("User password must be a non-blank character string of length 1 (cannot be a vector).")
  }

  # add user
  credentials <- readRDS("credentials/credentials.RDS")
  
  if (user %in% credentials[, "user"]) stop("User already exists - choose a different user name.")
  
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
    stop("An entry in the credentials data frame is missing a password - please correct.")    
  }
  
  saveRDS(credentials, "credentials/credentials.rds")    
}

# Function to add multiple users
add_multiple_users <- function(users, pws) {
  require(digest)
  
  # check inputs
  if (!is.character(users) || !is.vector(users) ||
      any(is.na(users)) || any(users == "")) {
    stop("User names must be a character vector with no blank entries.")
  }
  if (!is.character(pws) || !is.vector(pws) ||
      any(is.na(pws)) || any(pws == "")) {
    stop("User passwords must be a character vector with no blank entries.")
  }
  if (length(users) != length(pws)) stop("Users and passwords vectors are not the same length.")
  
  # add users
  credentials <- readRDS("credentials/credentials.RDS")
  
  if (any(users %in% credentials[, "user"])) {
    dupe_users <- credentials[users %in% credentials[, "user"], "user"]
    
    dupe_users <- paste(dupe_users, collapse = ", ")
    message <- paste0("Users [", dupe_users, "] already exist - choose different user names.")
    stop(message)
  }
  
  temp_df <- data.frame(user = users, pw = digest(pws), 
                        locked_out = rep(FALSE, times = length(users)), stringsAsFactors = FALSE)
  
  credentials <- rbind(credentials, temp_df)
  rm(temp_df)
  
  # check for rows with blank user names or password
  if (any(is.na(credentials[, "user"]) | 
      credentials[, "user"] == "")) {
    stop("An entry in the credentials data frame is missing a user name - please correct.")
  }
  if (any(is.na(credentials[, "pw"]) | 
      credentials[, "pw"] == "")) {
    stop("An entry in the credentials data frame is missing a password - please correct.")    
  }
  
  saveRDS(credentials, "credentials/credentials.rds")    
}
