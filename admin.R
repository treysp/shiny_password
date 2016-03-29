# Code used to manage users and passwords

#' Create credentials directory and empty data frame
#'
#' Creates the "credentials" directory inside the current working directory and 
#'  creates an empty credentials.rds data frame that will contain user credentials.
#'   
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'  
#' @examples
#' credentials_init()
credentials_init <- function() {
  if (file.exists("credentials/credentials.rds")) {
    stop("Credentials file already exists.")
  } else {
    if (!dir.exists("credentials/")) {
      dir.create("credentials/")
    }
    
    credentials <- data.frame(user = character(),
                              pw = character(),
                              locked_out = logical(),
                              stringsAsFactors = FALSE)

    saveRDS(credentials, "credentials/credentials.rds")
  }
  invisible(TRUE)
}  
  
#' Add a single user to the credentials data frame
#'
#' Reads the credentials data frame, adds a single user, and saves the credentials data frame.
#' 
#' @param user A character string
#' @param pw A character string 
#'
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'
#' @examples
#' add_one_user("user1", "password1")
add_one_user <- function(user, pw) {
  require(digest)
  
  # check inputs
  if (!is.character(user) || !(length(user) == 1) || is.na(user) || user == "") {
    stop("User name must be a non-blank character string of length 1 (cannot be a vector).")
  }
  if (!is.character(pw) || !(length(pw) == 1) || is.na(pw) || pw == "") {
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
  invisible(TRUE)
}

#' Add multiple users to the credentials data frame
#'
#' Reads the credentials data frame, adds multiple users, and saves the credentials data frame. 
#' The two input character vectors should contain pairs of user names and passwords in the same
#' locations within the vectors. For example, the first user name in the user names vector will
#' be paired with the first password in the passwords vector.
#' 
#' @param users A character vector with no values of NA or ""
#' @param pws A character vector with no values of NA or ""
#'
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'
#' @examples
#' add_multiple_users(c("user1", "user2"), c("password1", "password2"))
add_multiple_users <- function(users, pws) {
  require(digest)
  
  # check inputs
  if (!is.character(users) || !is.vector(users) || any(is.na(users)) || any(users == "")) {
    stop("User names must be a character vector with no blank entries.")
  }
  if (!is.character(pws) || !is.vector(pws) || any(is.na(pws)) || any(pws == "")) {
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
                        locked_out = rep(FALSE, times = length(users)), 
                        stringsAsFactors = FALSE)
  
  credentials <- rbind(credentials, temp_df)
  rm(temp_df)
  
  # check for rows with blank user names or password
  if (any(is.na(credentials[, "user"]) | credentials[, "user"] == "")) {
    stop("An entry in the credentials data frame is missing a user name - please correct.")
  }
  if (any(is.na(credentials[, "pw"]) | credentials[, "pw"] == "")) {
    stop("An entry in the credentials data frame is missing a password - please correct.")    
  }
  
  saveRDS(credentials, "credentials/credentials.rds") 
  invisible(TRUE)
}

#' Delete a single user from the credentials data frame
#'
#' Reads the credentials data frame, deletes a single user, and saves the credentials data frame.
#' 
#' @param user A character string
#'
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'
#' @examples
#' delete_user("user1")
delete_user <- function(user) {
  # check input
  if (!is.character(user) || !(length(user) == 1) || is.na(user) || user == "") {
    stop("User name must be a non-blank character string of length 1 (cannot be a vector).")
  }

  # delete user
  credentials <- readRDS("credentials/credentials.RDS")
  
  if (!(user %in% credentials[, "user"])) stop("User name does not exist in credentials data.")
  
  row_username <- which(credentials$user == user)
  
  if (length(row_username) > 1) stop("Credentials data error - more than one user has this user name.")
  
  credentials <- credentials[-row_username, ]

  if (nrow(credentials) == 0) warning("There are now 0 users in the credentials data.")
  
  saveRDS(credentials, "credentials/credentials.rds")
  invisible(TRUE)
}
