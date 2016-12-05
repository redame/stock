library(shiny)

shinyUI(bootstrapPage(
  headerPanel("エリオット波動 by peakbottom"),
  #tags$div(
  #  HTML("<a href='/pattern2/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  #),

  htmlOutput("returnButton"),
  htmlOutput("stockName"),
  plotOutput("stockChart", height=350),
  dataTableOutput("patternData")
))
