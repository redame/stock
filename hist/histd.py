#!/bin/env python
# coding:utf-8

import urllib
import urllib2
from lxml import etree
import time
import datetime

def get_stockdata(code,sy,sm,sd,ey,em,ed,tm):
  p=1
  plen=20
  ss=""
  while(plen>=20):
    ret,plen=get_stockdata_page(code,sy,sm,sd,ey,em,ed,tm,p)
    ss=ss+ret
    p=p+1
  f=open("/mnt/stock/data/hist/daily/"+code+".txt","w")
  #f=open(code+".txt","w")
  f.write(ss)
  f.close()

def to_ymd(s):
  a=s.split("-")
  if len(a)<3:
    return s
  dt=datetime.datetime(int(a[0]),int(a[1]),int(a[2]),0,0,0)
  return dt.strftime("%Y-%m-%d")

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
      st=""
      for td in tr.findall("td"):
        s=td.text.encode('utf-8').replace(',','').replace('年','-').replace('月','-').replace('日','')
        st=st+to_ymd(s)+"\t"
      st=st+code
      ret=ret+st+"\n"
  time.sleep(1)
  #print "plen="+str(plen)+"\n"
  #print ret+"\n"
  return ret,plen

def get_stockdata_all(sy,sm,sd,ey,em,ed,tm):
  #f=open("daily/master.txt")
  ##f=open("master.txt")
  #lines=f.readlines()
  #f.close()
  #for line in lines:
  #  ay=line.split("\t")
  #  print ay[0]
  for code in range(1321,9997):
    try:
      get_stockdata(str(code),sy,sm,sd,ey,em,ed,tm)
    except:
      import traceback
      print traceback.format_exc()

if __name__ == '__main__':
  #get_stockdata("9984","2012","01","01","2014","01","01","d")
  get_stockdata_all("2001","01","01","2016","12","31","d")
