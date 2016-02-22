library(shiny)
library(digest)

# credentials data frame for testing (username = "test" and password = "password")
# NOTE: in real use this would open an existing data frame containing user credentials
credentials <- data.frame(user = "test", pw = "380796939c86c55d6aa8ea8c941f7652", stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  # reactive value containing user's authentication status
  user_input <- reactiveValues(authenticated = FALSE)
  
  # password entry UI if not authenticated
  output$uiLogin <- renderUI({
    if (user_input$authenticated == FALSE) {
      wellPanel(
        textInput("user_name", "User Name:"),
        
        passwordInput("password", "Password:"),

        actionButton("login_button", "Log in")
        )
    }
  })
  
  # authenticate user by checking whether their user name and password are in the credentials data frame and 
  #   on the same row
  output$pass <- renderText({
    req(input$login_button)
    
    if (input$login_button > 0) {
      if (user_input$authenticated == FALSE) {  
          row.username <- isolate(which(credentials$user == input$user_name))
          row.password <- isolate(which(credentials$pw == digest(input$password))) # digest() makes md5 hash of password
          
          if (length(row.username) > 0 && 
              length(row.password) > 0 &&
              (row.username == row.password)) {
                user_input$authenticated <- TRUE
          } else  {
            "User name or password failed!"
          }
      }
    }
  })
    
  # show slider input widget if user is authenticated
  observe({
    if (user_input$authenticated == TRUE) {
      output$obs <- renderUI({
        sliderInput("obs", "Number of observations:", 
                    min = 10000, max = 90000, 
                    value = 50000, step = 10000)
      })
    }
  })

  # render histogram if the slider input value exists
  # NOTE: this will only appear if user is authenticated because the slider will only exist and have a value
  #   if the user is authenticated (and the function "req()" in this code tells Shiny that this output item
  #   should not be created until "input$obs" exists)
  output$distPlot <- renderPlot({
    req(input$obs)
    hist(rnorm(input$obs), breaks = 100, main = paste("Your password:", input$password))
  })
})
