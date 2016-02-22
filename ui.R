shinyUI(bootstrapPage(
  # Custom CSS
  tagList(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    )
  ),
  
  # Login interface
  div(class = "login",
      uiOutput("uiLogin"),
      textOutput("pass")
  ), 
  
  # Slider input
  div(class = "span4", uiOutput("obs")),
  
  # Histogram output
  div(class = "span8", plotOutput("distPlot"))
  
))
