library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("エリオット波動 by peakbottom"),
  tags$div(
    HTML("<a href='/shiny/elliottpb_list/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  ),
  
  helpText("一覧"),
  dataTableOutput("patternList")
))
