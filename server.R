library(shiny)
library(digest)

# credentials data frame for testing (username = "test" and password = "password")
# NOTE: in real use this would open an existing data frame containing user credentials
credentials <- data.frame(user = "test", pw = "380796939c86c55d6aa8ea8c941f7652", stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  # reactive value containing user's authentication status
  user_input <- reactiveValues(authenticated = FALSE, status = "")

  output$ui_general <- renderUI({
    if (user_input$authenticated == FALSE) {
      # Centered login interface
      fluidPage(
        fluidRow(
          column(width = 2, offset = 5,
            br(), br(), br(), br(),
            uiOutput("uiLogin"),
            uiOutput("pass")
          )
        )
      )
    } else {
      fluidPage(
        fluidRow(
          # Slider input
          uiOutput("obs"),
  
          # Histogram output
          plotOutput("distPlot")
        )
      )
    }
  })
    
  # password entry UI if not authenticated
  output$uiLogin <- renderUI({
      wellPanel(
        textInput("user_name", "User Name:"),
        
        passwordInput("password", "Password:"),

        actionButton("login_button", "Log in")
      )
  })

  output$pass <- renderUI({
    if (user_input$status == "bad_user") {
      h5(strong("User name not found!", style = "color:red"), align = "center")
    } else if (user_input$status == "bad_password") {
      h5(strong("Incorrect password!", style = "color:red"), align = "center")
    }
  })   
    
  # authenticate user by checking whether their user name and password are in the credentials data frame and 
  #   on the same row
  # if not authenticated, determine whether the user name or the password is bad (username precedent over pw)
  observeEvent(input$login_button, {
          row.username <- isolate(which(credentials$user == input$user_name))
          row.password <- isolate(which(credentials$pw == digest(input$password))) # digest() makes md5 hash of password
          
          if (length(row.username) == 1 && 
              length(row.password) == 1 &&
              (row.username == row.password)) {
                user_input$authenticated <- TRUE
          } else if (input$user_name == "" || length(row.username) == 0) {
            user_input$status <- "bad_user"
          } else if (input$password == "" || length(row.password) == 0) {
            user_input$status <- "bad_password"
          }
  })  
  
  # slider input widget if user is authenticated
  output$obs <- renderUI({
    sliderInput("obs", "Number of observations:", 
                min = 10000, max = 90000, 
                value = 50000, step = 10000)
  })

  # render histogram if the slider input value exists
  output$distPlot <- renderPlot({
    req(input$obs)
    hist(rnorm(input$obs), breaks = 100, main = paste("Your password:", input$password))
  })
})
