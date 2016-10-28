#!/bin/env python
# coding:utf-8


#http://zaaf01d/trac/chart/svn/trunk/technicals/python/aroonIndicator.py


#import pandas
import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc
import time
import talib

import MySQLdb

connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")

cursor = connection.cursor()
# SQL
stockCode = "6758"
fromDate='2016-04-01'
cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s",[stockCode,fromDate])
result = cursor.fetchall()

ohlc=[]
fdate=[]  # float
ddate=[]  # datetime
adr=1
for row in result:
  tmp=adr
  ohlc.append((adr,row[1],row[2],row[3],row[4],row[5]))
  ddate.append(row[0])
  fdate.append(adr)
  adr=adr+1
cursor.close()
connection.close()


# graph上のfloat型の日付と、表示文字列を紐付けている
plt.xticks(
	fdate[::5],
	[x.strftime('%Y-%m-%d') for x in ddate][::5]
)


ax = plt.subplot()

candlestick_ohlc(ax,ohlc)

plt.xlabel('Date')
plt.ylabel('Price')
plt.title("title")
plt.legend()
plt.show()
