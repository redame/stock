library(shiny)

shinyUI(bootstrapPage(
  headerPanel("chart pattern"),
  tags$div(
    HTML("<a href='/pattern/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  ),

  htmlOutput("patternDescription"),
#  htmlOutput("patternImage"),
  plotOutput("distPlot", height=350),
  dataTableOutput("patternWinRate")
))
