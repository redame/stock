#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib
import urllib2
from lxml import etree
import time
import os

os.environ["LANG"]="ja_JP.UTF-8"


def get_stockmaster(hira):
  p=1
  ret="dummy"
  ss=""
  while(ret!=""):
    ret,plen=get_stockmaster_page(hira,p)
    #print ret
    if ret != "":
      ss=ss+ret
    p=p+1
  return ss

def get_stockmaster_page(hira,p):
  hira=hira.encode('utf-8')
  url="http://stocks.finance.yahoo.co.jp/stocks/qi/?%s"
  params={"js":hira,"p":p}
  data=urllib.urlencode(params)
  #print data
  res=urllib.urlopen(url % data)
  page=res.read()
  root=etree.fromstring(page,etree.HTMLParser())
  elem=root.xpath("//a[contains(@href,'/stocks/detail')]")
  i=0
  ret=""
  for ele in elem:
    if ele.text != None:
      if i%3==0:
        ret=ret+ele.text+"\t"
      if i%3==1:
        ret=ret+ele.text.encode('utf-8')+"\n"
    i=i+1
  time.sleep(1)
  return ret,len(elem)

def get_stockmasterall():
  hira=u"あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよわ"
  size=len(hira)
  ss=""
  for i in range(0,size):
    #print hira[i:i+1]
    #print i
    ss=ss+get_stockmaster(hira[i:i+1])
  f=open("daily/master.txt","w")
  f.write(ss)
  f.close()

if __name__ == '__main__':
  get_stockmasterall()
