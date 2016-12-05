library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("チャート形状"),
  tags$div(
    HTML("<a href='/pattern3/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  ),
  
  helpText("現状シグナル一覧"),
  dataTableOutput("patternNow"),
  helpText("過去シグナル一覧"),
  htmlOutput("patternDescription"),
  htmlOutput("patternImage"),
  dataTableOutput("patternView")
))
