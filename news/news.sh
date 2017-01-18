#!/bin/bash
#PBS -N news_crawler
#PBS -j oe 
#PBS -l ncpus=1
#PBS -q SINGLE

cd ${PBS_O_WORKDIR}
source ~/.bashrc

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
  ruby news.rb "/mnt/data/news" $cate  
done

