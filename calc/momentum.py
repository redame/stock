#!/bin/env python
# -*- coding:utf-8 -*-

import datetime
import numpy
import talib
import sqlite3

import os


TECH="Momentum"

def makeTechnicalFunc(code,cl,n):
  fileName="../work/"+TECH+".txt"
  try:
    #cl=ohlc[:,4].astype(float)
    mom=talib.MOM(cl,timeperiod=n)
    print mom
    f=open(fileName,"w")
    f.write(mom)
    f.close()
  except ValueError:
    mssage(ValueError)

def makeTechnical():
  conn=sqlite3.connect("/home/pi/stock/data/stock.db")
  cur=conn.cursor()
  cur.execute("select code from stockMaster")
  codes=[]
  for row in cur.fetchall():
    codes.append(row[0])

  for code in codes:
    cur.execute("select adj_close from histDaily where code='"+code+"' order by date")
    cl=[]
    for row in cur.fetchall():
      cl.append(row[0])
    makeTechnicalFunc(code,cl,25)
    return


if __name__ == "__main__":
  makeTechnical()
