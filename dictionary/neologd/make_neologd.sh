#!/bin/sh


if [ -d mecab-ipadic-neologd ];then
#  pushd mecab-ipadic-neologd 
#  echo "git pull"
#  git pull
#  popd
  rm -rf mecab-ipadic-neologd
fi
#else
  echo "git clone https://github.com/neologd/mecab-ipadic-neologd.git"
  git clone https://github.com/neologd/mecab-ipadic-neologd.git
#fi

cd mecab-ipadic-neologd/seed

fname=""
fwk=`ls *xz` > /dev/null
if [ $? = 0 ];then
  fname=${fwk%.*}
  xz --decompress $fwk
fi

fname=`ls mecab*csv`
echo "fname=$fname"
if [ "$fname" = "" ];then
  echo "do nothing"
else

  echo "cat $fname |sed 's/$/,neologd/' > /home/admin/dictionary/neologd/${fname}.txt"
  cat $fname |sed 's/$/,neologd/' > /home/admin/dictionary/neologd/${fname}.txt

  echo "/usr/libexec/mecab/mecab-dict-index -d /usr/lib64/mecab/dic/ipadic -u /home/admin/dictionary/data/neologd.dic -f utf-8 -t utf-8 /home/admin/dictionary/neologd/${fname}.txt"
  /usr/libexec/mecab/mecab-dict-index -d /usr/lib64/mecab/dic/ipadic -u /home/admin/dictionary/data/neologd.dic -f utf-8 -t utf-8 /home/admin/dictionary/neologd/${fname}.txt
fi

