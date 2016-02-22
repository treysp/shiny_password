shinyUI(bootstrapPage(
  # Add custom CSS & Javascript;
  tagList(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    )
  ),
  
  ## Login module;
  div(class = "login",
      uiOutput("uiLogin"),
      textOutput("pass")
  ), 
  
  div(class = "span4", uiOutput("obs")),
  div(class = "span8", plotOutput("distPlot"))
  
))
