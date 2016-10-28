library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("チャートパターン シグナル"),
  tags$div(
    HTML("<div align='center'><a href='../ptn_signal/?ashi=d' class='btn btn-primary'><b>Daily</b></a>&nbsp;<a href='../ptn_signal/?ashi=w' class='btn btn-primary'><b>Weekly</b></a>&nbsp;<a href='../ptn_signal/?ashi=m' class='btn btn-primary'><b>Monthly</b></a></div>")
  ),
  
  helpText("パターン一覧"),
  htmlOutput("ptnAshi"),
  dataTableOutput("ptnAllList")
  
))
