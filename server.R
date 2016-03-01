library(shiny)
library(digest)

# credentials data frame for testing (username = "test" and password = "password")
# NOTE: in real use this would open an existing data frame containing user credentials
credentials <- data.frame(user = "test", pw = "380796939c86c55d6aa8ea8c941f7652", 
                          stringsAsFactors = FALSE)

shinyServer(function(input, output, session) {
#### UI code --------------------------------------------------------------
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
          column(width = 4, offset = 5,
          br(), br(),
          uiOutput("obs"),
          br(), br()
          )
        ),
        fluidRow(
          # Histogram output
          plotOutput("distPlot")
        )
      )
    }
  })
  
#### SERVER code -----------------------------------------------------------------------------
  # main UI components (displayed if user --IS-- authenticated)
    # slider input widget
    output$obs <- renderUI({
      sliderInput("obs", "Number of observations:", 
                  min = 1, max = 1000, value = 500)
    })
  
    # render histogram once slider input value exists
    output$distPlot <- renderPlot({
      req(input$obs)
      hist(rnorm(input$obs), main = "")
    })
    
#### PASSWORD MODULE ------------------------------------------------------------------------ 
  # reactive value containing user's authentication status
  user_input <- reactiveValues(authenticated = FALSE, status = "")

  # authenticate user by checking whether their user name and password are in the credentials 
  #   data frame and on the same row
  # if not authenticated, determine whether the user name or the password is bad (username 
  #   precedent over pw)
  observeEvent(input$login_button, {
    row.username <- which(credentials$user == input$user_name)
    row.password <- which(credentials$pw == digest(input$password)) # digest() makes md5 hash of password
    
    if (length(row.username) == 1 && 
        length(row.password) >= 1 &&
        (row.username %in% row.password)) { # more than one user may have same pw
      user_input$authenticated <- TRUE
    } else {
      user_input$authenticated <- FALSE
    }
    
    if (user_input$authenticated == FALSE &
        (input$user_name == "" || length(row.username) == 0)) {
      user_input$status <- "bad_user"
    } else if (user_input$authenticated == FALSE &
               (input$password == "" || length(row.password) == 0)) {
      user_input$status <- "bad_password"
    }
  })   

  # password entry UI componenets (displayed if user is not authenticated)
  # username and password text fields, login button
  output$uiLogin <- renderUI({
    wellPanel(
      textInput("user_name", "User Name:"),
      
      passwordInput("password", "Password:"),

      actionButton("login_button", "Log in")
    )
  })

  # red error message if bad credentials
  output$pass <- renderUI({
    if (user_input$status == "bad_user") {
      h5(strong("User name not found!", style = "color:red"), align = "center")
    } else if (user_input$status == "bad_password") {
      h5(strong("Incorrect password!", style = "color:red"), align = "center")
    } else {
      ""
    }
  })  
})
