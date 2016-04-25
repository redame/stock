#!/bin/sh

export PATH=/home/pi/.dnx/runtimes/dnx-mono.1.0.0-beta4/bin:/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/nvm/versions/node/v0.12.4/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

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
  ruby news_archive.rb "/mnt/news/data" $cate  
done

