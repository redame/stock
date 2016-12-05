library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("チャートパターン by PeakBottom"),
  tags$div(
    HTML("<div align='right'><a href='http://zai.diamond.jp/articles/-/134822' class='btn btn-primary'>チャートパターンサンプル</a></div><br><br><a href='../ptnpb_list/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  ),

  tags$div(
    HTML("<div align='center'><a href='../ptnpb_list/?ashi=d' class='btn btn-primary'><b>Daily</b></a>&nbsp;<a href='../ptnpb_list/?ashi=w' class='btn btn-primary'><b>Weekly</b></a>&nbsp;<a href='../ptnpb_list/?ashi=m' class='btn btn-primary'><b>Monthly</b></a></div>")
  ),
  
  helpText("パターン一覧"),
  htmlOutput("ptnAshi"),
  dataTableOutput("ptnAllList"),
  tags$div(
    HTML("<hr>")
  ),
  helpText("パターン詳細"),
  htmlOutput("ptnListName"),
  dataTableOutput("ptnList")
  
))
