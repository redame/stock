#!/bin/env ruby 
# coding:utf-8


require 'kconv'
require 'natto'
require 'nkf'
require 'pp'

in_file = File::open( "stock.txt")

# 出力ファイル（hatena.csvというファイルを出力します）
out_file = File::open( "stock.csv", 'w' )

i = 0

# 1行ずつ読み込み、out_fileに出力していく
while line = in_file.gets

  # システム辞書でEUCを使用している場合は、toutf8は削ってください
  line = line.toutf8.strip
  #line = line.strip

  # タブ区切り（仮名\t単語）になっているので、split
  #splitted_word = line.split("\t")
  #next if splitted_word.size < 2
  kana = "*" 
  word = line.strip.gsub(/^\"/,'').gsub(/\"$/,'').gsub(/,/,'')
  
  word = word.gsub(/ CO\., LTD\./,'')
  word = word.gsub(/(INC.|CORP.|& CO.,|CO.,|LTD.)/, '')
  word = word.gsub(/^ *|^　*| *$|　*$/, '')
  word = word.gsub(/,$|\.$/, '')
  word = word.gsub(/ CO$/, '')


  cost = [-36000, -400 * word.size**1.5].max
  cost = cost.to_i

  # 行出力 
  out_file.puts "#{word},0,0,#{cost},名詞,固有名詞,組織,*,*,*,#{word},*,*,stock"

  puts "#{i.to_s}件目を処理" if ( i += 1 ) % 1000 == 0
  # break if i > 3000
end

in_file.close
out_file.close


