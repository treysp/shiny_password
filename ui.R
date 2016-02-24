shinyUI(fluidPage(
  # Centered login interface
  fluidRow(
    column(width = 2, offset = 5,
      br(), br(), br(), br(),
      uiOutput("uiLogin"),
      uiOutput("pass")
    ), 
  
  # Slider input
  uiOutput("obs"),

  # Histogram output
  plotOutput("distPlot")
  )
))
