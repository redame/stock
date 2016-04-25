#!/bin/env ruby
# coding:utf-8

require 'kconv'
require 'natto'
require "pp"

# http://d.hatena.ne.jp/hatenadiary/20060922/1158908401から落としたファイル
in_file = File::open( "keywordlist_furigana.csv" )

# 出力ファイル（hatena.csvというファイルを出力します）
out_file = File::open( "hatena.csv", 'w' )

i = 0
  # MeCabでパース
  natto = Natto::MeCab.new("-F%f[0],%f[1],%s")


# 1行ずつ読み込み、out_fileに出力していく
while line = in_file.gets

  # EUC-JPのファイルなので、使用しているUTF-8に変換（ついでにtrim）
  # システム辞書でEUCを使用している場合は、toutf8は削ってください
  line = line.toutf8.strip.gsub(/^\"/,'').gsub(/\"$/,'').gsub(/,/,'')

  # タブ区切り（仮名\t単語）になっているので、split
  splitted_word = line.split("\t")
  kana=""
  word=""
  spword=""
  if splitted_word.size >= 2 then
    kana = splitted_word[0].strip
    kana = "*" if kana.to_s == ""
    word = splitted_word[1].strip
    spword = splitted_word[1]
  else
    word = splitted_word[0]
    spword = splitted_word[0]
  end

  # 日付が入ったワードは、不要なものが多いので外す
  next if /[0-9]{4}(\/|\-)[0-9]{2}(\/|\-)[0-9]{2}/ =~ word
  next if /[0-9]{4}年/ =~ word
  next if /[0-9]{1,2}月[0-9]{1,2}日/ =~ word

  # 制御文字、HTML特殊文字が入ったものは外す
  next if /[[:cntrl:]]/ =~ word
  next if /\&\#/ =~ word

  #数字削除
  wordwk=word.gsub(/[0123456789]/,"")
  next if wordwk.size == 0
  wordwk=word.gsub(/[０１２３４５６７８９]/,"")
  next if wordwk.size == 0

  #QR
  wordwk=word.gsub(/[ぁァぃィぅゥぇェぉォっッゃャゅュょョー・、]/,"")
  next if wordwk.size <= 1

  # はてなという言葉が入ってるものは、運用の為のワードが多いので削除
  # 一部、正しい用語も消してしまっているので、用途によっては下行をコメントアウト
  next if /はてな/ =~ word

  #ノード数
  node_count = 0
  # 未知語数
  unk_count = 0
  #品詞細分類2が地域の数
  area_count = 0
  #品詞細分類2が人名の数
  name_count = 0

  #ノードと種類をカウント
  natto.parse(spword) {|n|
    node_word=n.surface
    break if n.is_eos?
    feature=n.feature.split(",")
    area_count += 1 if feature[1].strip == "地域"
    name_count += 1 if feature[1].strip == "人名"
    # 未知語(stat:1)をカウント
    unk_count += 1 if feature[2]== 1
    node_count += 1
  }

  # node数が1つ（システム辞書で1語として解析可能）の場合は登録しない
  next if node_count <= 1 and unk_count == 0

  # 全nodeが地域名だった場合は、登録しない（東京都北区は、東京都 | 北区で分けたい為）
  next if node_count == area_count

  # 全nodeが人名だった場合は、登録しない（相田翔子は、相田 | 翔子で分けたい為）
  next if node_count == name_count

  # コストの計算
  cost = [-36000,-400*word.size**1.5].max

  # 平仮名を片仮名に変換(jcode使わないと文字化けします)
  #require 'jcode'
  kana.tr!('ぁ-ん', 'ァ-ン')  

  # 行出力 
  out_file.puts "#{word},0,0,#{cost},名詞,一般,*,*,*,*,#{word},*,*,hatena"

  # 全角も登録
#  zen_word=NKF.nkf( '-w',word.tr('0-9','０-９').tr('a-z','ａ-ｚ').tr('A-Z','Ａ-Ｚ'))
#  if zen_word != word
#    out_file.puts "#{zen_word},0,0,#{cost},名詞,一般,*,*,*,*,#{zen_word},*,*,hatena"
#  end

  # 英字の場合は、小文字統一、大文字統一も出力しておく
#  if word != word.downcase
#    out_file.puts "#{word.downcase},0,0,#{cost},名詞,一般,*,*,*,*,#{word},*,*,hatena"
#  end
#  if word != word.upcase
#    out_file.puts "#{word.upcase},0,0,#{cost},名詞,一般,*,*,*,*,#{word},*,*,hatena"
#  end

  puts "#{i.to_s}件目を処理" if ( i += 1 ) % 1000 == 0
  # break if i > 3000
end

in_file.close
out_file.close
