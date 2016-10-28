library(shiny)

shinyUI(bootstrapPage(
  headerPanel("チャート形状 by peakbottom"),
  #tags$div(
  #  HTML("<a href='/pattern2/'  class='btn btn-primary'><b>Back</b></a><br><br>")
  #),
  tags$div(
    HTML("<div align='right'><a href='http://zai.diamond.jp/articles/-/134822' class='btn btn-primary'>チャートパターンサンプル</a></div><br><br>")
  ),

  htmlOutput("returnButton"),
  htmlOutput("patternDescription"),
  htmlOutput("stockName"),
  plotOutput("stockChart", height=350),
  helpText("パターンリスト"),
  dataTableOutput("ptnList")
  #helpText("過去2001年からシグナル発生時までの同一形状発生時の5,10,20期間後の収益率"),
  #plotOutput("simuChart",height=200),
  #dataTableOutput("simuResult")
))
