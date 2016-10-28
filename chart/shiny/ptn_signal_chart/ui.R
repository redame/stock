library(shiny)

shinyUI(bootstrapPage(
  headerPanel("チャートパターンシグナル"),
  tags$div(
    HTML("<div align='right'><a href='http://zai.diamond.jp/articles/-/134822' class='btn btn-primary'>チャートパターンサンプル</a></div><br><br>")
  ),

  htmlOutput("returnButton"),
  htmlOutput("patternDescription"),
  htmlOutput("stockName"),
  plotOutput("stockChart", height=350),
  helpText("パターンリスト"),
  dataTableOutput("ptnList"),
  helpText("過去2001年からシグナル発生時までの同一形状発生時の収益率"),
  #plotOutput("simuChart",height=200),
  htmlOutput("ptnImage"),
  htmlOutput("ptnResult")
))
