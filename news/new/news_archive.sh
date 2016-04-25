#!/bin/sh

categories="
pol
soci
peo
int
cn
kr
asia
n_ame
s_ame
eurp
m_est
bus_all
brf
biz
ind
ent
musi
movi
game
asent
spo
base
socc
moto
horse
golf
fight
sci
sctch
prod
life
hlth
env
cul
hoktoh
kan
sinhok
tok
kin
chu
sik
kyuoki
"

for cate in $categories;do
  ruby news_archive.rb "news/data" $cate  
done

