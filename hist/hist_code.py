#!/bin/env python
# coding:utf-8

import sys
import urllib
import urllib2
from lxml import etree
import time


def get_stockdata(code,sy,sm,sd,ey,em,ed,tm):
  p=1
  plen=53
  ss=""
  while(plen>=53):
    ret,plen=get_stockdata_page(code,sy,sm,sd,ey,em,ed,tm,p)
    ss=ss+ret
    p=p+1
  f=open("data/"+code+".txt","w")
  f.write(ss)
  f.close()

def get_stockdata_page(code,sy,sm,sd,ey,em,ed,tm,p):
  # http://info.finance.yahoo.co.jp/history/?code=9433&sy=2014&sm=7&sd=28&ey=2014&em=8&ed=27&tm=d
  url="http://info.finance.yahoo.co.jp/history/?%s"
  #params={"code":code,"sy":"2014","sm":"7","sd":"28","ey":"2014","em":"8","ed":"27","tm":"d","p":p}
  params={"code":code,"sy":sy,"sm":sm,"sd":sd,"ey":ey,"em":em,"ed":ed,"tm":tm,"p":p}
  data=urllib.urlencode(params)
  #print data
  res=urllib.urlopen(url % data)
  page=res.read()
  root=etree.fromstring(page,etree.HTMLParser())
  elem=root.xpath("//table")
  
  ret=""
  plen=len(elem[1].xpath("//tr"))
  for tr in elem[1].xpath("//tr"):
    if len(tr.findall("td"))==7:
      str=""
      for td in tr.findall("td"):
        s=td.text.encode('utf-8').replace(',','').replace('年','-').replace('月','-').replace('日','')
        ay=s.split('-')
        if len(ay)>1:
          ds=ay[0]+'-'
          if len(ay[1])==1:
            ds=ds+"0"
          ds=ds+ay[1]+'-'
          if len(ay[2])==1:
            ds=ds+"0"
          s=ds+ay[2]
        str=str+s+"\t"
      str=str+code
      ret=ret+str+"\n"
  time.sleep(1)
  return ret,plen

def get_stockdata_all(sy,sm,sd,ey,em,ed,tm):
  f=open("data/master.txt")
  lines=f.readlines()
  f.close()
  for line in lines:
    ay=line.split("\t")
    print ay[0]
    get_stockdata(ay[0],sy,sm,sd,ey,em,ed,tm)

if __name__ == '__main__':
  #get_stockdata("9984","2012","01","01","2014","01","01","d")
  print sys.argv[1]
  get_stockdata(sys.argv[1],"2000","01","01","2014","08","27","d")
