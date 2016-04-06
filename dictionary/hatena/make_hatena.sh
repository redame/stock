#!/bin/sh



rm -rf keywordlist_furigana.csv*

wget --no-check-certificate http://d.hatena.ne.jp/images/keyword/keywordlist_furigana.csv

ruby conv_hatena.rb

/usr/libexec/mecab/mecab-dict-index -d /usr/lib64/mecab/dic/ipadic -u /home/admin/dictionary/data/hatena.dic -f utf-8 -t utf-8 hatena.csv



