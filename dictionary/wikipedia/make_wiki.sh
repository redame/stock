#!/bin/sh


rm -rf jawiki-latest-all-titles-in-ns0*

wget --no-check-certificate http://download.wikimedia.org/jawiki/latest/jawiki-latest-all-titles-in-ns0.gz
gunzip jawiki-latest-all-titles-in-ns0.gz

ruby conv_wiki.rb

/usr/libexec/mecab/mecab-dict-index -d /usr/lib64/mecab/dic/ipadic -u /home/admin/dictionary/data/wikipedia.dic -f utf-8 -t utf-8 wikipedia.csv

