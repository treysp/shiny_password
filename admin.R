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
  
#' Add users to the credentials data frame
#'
#' Reads the credentials data frame, adds users, and saves the credentials data frame. 
#' When adding multiple users, the two input character vectors should contain pairs of 
#' user names and passwords in the same locations within the vectors. For example, the 
#' first user name in the user names vector will be paired with the first password in 
#' the passwords vector.
#' 
#' @param users A character singleton or vector with no values of NA or ""
#' @param pws A character singleton or vector with no values of NA or ""
#'
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'
#' @examples
#' add_users("user1", "password1")
#' 
#' users_to_add <- c("user2", "user3")
#' passwords_to_add <- c("password2", "password3")
#' add_users(user_to_add, passwords_to_add)
add_users <- function(users, pws) {
  library(digest)
  
  # check inputs
  if (!is.character(users) || any(is.na(users)) || any(users == "")) {
    stop("User names must be characters. User names cannot be NA or \"\".")
  }
  if (length(unique(users)) != length(users)) stop("You cannot add multiple users with the same user name.")
  if (!is.character(pws) || any(is.na(pws)) || any(pws == "")) {
    stop("Passwords must be characters. Passwords cannot be NA or \"\".")
  }
  if (length(users) != length(pws)) stop("You must have the same number of passwords as users.")
  
  # add users
  credentials <- readRDS("credentials/credentials.RDS")
  
  if (any(credentials[, "user"] %in% users)) {
    dupe_users <- credentials[which(credentials[, "user"] %in% users), "user"]
    
    dupe_users <- paste(dupe_users, collapse = ", ")
    message <- paste0("Users [", dupe_users, "] already exist - choose different user names.")
    stop(message)
  }
  
  temp_df <- data.frame(user = users, pw = sapply(pws, FUN = digest), 
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

#' Delete users from the credentials data frame
#'
#' Reads the credentials data frame, deletes users, and saves the credentials data frame.
#' 
#' @param users A character singleton or vector with no values of NA or ""
#'
#' @return This function is exclusively used for its side effects and returns TRUE invisibly 
#'  if it executes successfully.
#'
#' @examples
#' delete_users("user1")
#' 
#' users_to_delete <- c("user1", "user2")
#' delete_users(user_to_delete)
delete_users <- function(users) {
  # check input
  if (!is.character(users) || any(is.na(users)) || any(users == "")) {
    stop("User names must be characters. User names cannot be NA or \"\".")
  }
  if (length(unique(users)) != length(users)) {
    warning("Your list of users to delete has a duplicated user name in it.")
  }

  # delete users
  credentials <- readRDS("credentials/credentials.RDS")
  
  if (any(!(users %in% credentials[, "user"]))) {
    bad_users <- users[!(users %in% credentials[, "user"])]
    
    bad_users <- paste(bad_users, collapse = ", ")
    message <- paste0("Users [", bad_users, "] are not in the credentials data - please correct.")
    stop(message)
  }

  row_username <- which(credentials[, "user"] %in% users)
  
  if (length(row_username) > length(users)) stop("Credentials data error - more than one user has the same user name.")
  
  credentials <- credentials[-row_username, ]

  if (nrow(credentials) == 0) warning("There are now 0 users in the credentials data.")
  
  saveRDS(credentials, "credentials/credentials.rds")
  invisible(TRUE)
}
