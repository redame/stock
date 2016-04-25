#!/bin/env python
# coding:utf-8
import sqlite3
import sys

def import_data(file):
  con=sqlite3.connect("stock.db",isolation_level=None)
  sql=u"insert into histDaily values(?,?,?,?,?,?,?,?)"
  for line in open(file,'r'):
    ay=line.split('\t')
    con.execute(sql,(ay[0],ay[1],ay[2],ay[3],ay[4],ay[5],ay[6],ay[7]))
  con.close()
  

if __name__ == '__main__':
  #get_stockdata("9984","2012","01","01","2014","01","01","d")
  print sys.argv[1]
  import_data(sys.argv[1])
