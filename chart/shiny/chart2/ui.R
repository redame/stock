library(shiny)

shinyUI(bootstrapPage(
  headerPanel("チャート形状"),
  #tags$div(
  #  HTML("<a href='/pattern2/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  #),

  htmlOutput("returnButton"),
  htmlOutput("patternDescription"),
  htmlOutput("stockName"),
  plotOutput("distPlot", height=350),
  plotOutput("hist5Plot",height=350),
  plotOutput("hist10Plot",height=350),
  plotOutput("hist15Plot",height=350),
  plotOutput("hist20Plot",height=350),
  dataTableOutput("patternSimulation")
))
