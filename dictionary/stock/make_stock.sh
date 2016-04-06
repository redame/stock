#!/bin/sh
# create stock code file



ruby ./conv_stock.rb 

/usr/libexec/mecab/mecab-dict-index -d /usr/lib64/mecab/dic/ipadic -u /home/admin/dictionary/data/stock.dic -f utf-8 -t utf-8 stock.csv
rm -rf stock.txt

