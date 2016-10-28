#!/bin/env python
# coding:utf-8

# calcurate fibonatti fan
# http://fxtrend.jp/column-oscillator-fibonacci-fan.html

import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc
import time
import MySQLdb
import sys

import talib as ta
import numpy as np

# http://nbviewer.jupyter.org/github/jbn/ZigZag/blob/master/zigzag_demo.ipynb
import pandas as pd
from qrzigzag import peak_valley_pivots, max_drawdown, compute_segment_returns, pivots_to_modes


class PeakBottom:
    def __init__(self,zigzag):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")
        self.fromDate='2001-01-01'
        self.toDate = '2010-12-31'
        self.zigzag_upper= zigzag
        self.zigzag_lower= -zigzag
        self.pivots=None

    def calc(self,stockCode):
        cursor=self.connection.cursor()
        cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s and date<=%s",[stockCode,self.fromDate,self.toDate])
        result = cursor.fetchall()

        self.ohlc=[]
        for row in result:
            self.ohlc.append(row)

        cursor.close()
        if len(self.ohlc)>0:
            close=np.asarray(self.ohlc)[:,4]
            self.pivots = peak_valley_pivots(close, self.zigzag_upper, self.zigzag_lower)

class FiboFan:
    def __init__(self,stockCode,zigzag):
        self.tol=0.04
        self.fibo1=0.618
        self.fibo2=0.5
        self.fibo3=0.382
        self.stockCode=stockCode
        self.zigzag=zigzag
        self.pb = PeakBottom(self.zigzag)
        self.fibo_num=0
        self.fibo_ok1=0
        self.fibo_ok2 = 0
        self.fibo_ok3 = 0
        self.fibo_allnum=0
    def calc(self):
        self.pb.calc(self.stockCode)
        if self.pb.pivots is None:
            return

        for i in range(0,len(self.pb.pivots)):
            if self.pb.pivots[i] != 0:
                p1=i
                if p1 is None:
                    continue
                p2=self.get_point(i+1)
                if p2 is None:
                    continue
                p3=self.get_point(p2+1)
                if p3 is None:
                    continue
                p4=self.get_point(p3+1)
                if p4 is None:
                    continue
                self.calc_fibofan(p1,p2,p3,p4)

    def get_point(self, i):
        for j in range(i, len(self.pb.pivots)):
            if self.pb.pivots[j] != 0:
                return(j)
        return(None)

    def calc_fibofan(self,p1,p2,p3,p4):
        self.fibo_allnum=self.fibo_allnum+1

        if self.pb.pivots[p1] == 1: # peak
            r1=self.pb.ohlc[p1][2] # high
            r2=self.pb.ohlc[p2][3] # low
            r3=self.pb.ohlc[p3][2] # high
            r4=self.pb.ohlc[p4][3] # low
        else: # bottom
            r1=self.pb.ohlc[p1][3] # low
            r2=self.pb.ohlc[p2][2] # high
            r3=self.pb.ohlc[p3][3] # low
            r4=self.pb.ohlc[p4][2] # high

        b1=(r2-r1)*self.fibo1/(p2-p1) # 傾き
        b2=(r2-r1)*self.fibo2/(p2-p1) # 傾き
        b3=(r2-r1)*self.fibo3/(p2-p1) # 傾き


        # fibonacci fan price
        t1=b1*(p3-p1)+r1
        t2=b2*(p3-p1)+r1
        t3=b3*(p3-p1)+r1

        self.fibo_num=self.fibo_allnum
        #print "p="+str(p1)+","+str(p2)+","+str(p3)+","+str(p4)+",r="+str(r1)+","+str(r2)+","+str(r3)+","+str(r4)+",b="+str(b1)+","+str(b2)+","+str(b3)+",t="+str(t1)+","+str(t2)+","+str(t3)

        if r3 > (t1 - self.tol) and r3 < (t1+self.tol) :
            #print "p1=" + str(p1) + "," + str(p2) + "," + str(p3) + ",r=" + str(r1) + "," + str(r2) + "," + str(r3) + ",b=" + str(b1) + "," + str(b2) + "," + str(b3) + ",t=" + str(t1) + "," + str(t2) + "," + str(t3)
            self.fibo_ok1 = self.fibo_ok1 + 1
        elif r3 > (t2 - self.tol) and r3 < (t2 + self.tol) :
            #print "p2=" + str(p1) + "," + str(p2) + "," + str(p3) + ",r=" + str(r1) + "," + str(r2) + "," + str(r3) + ",b=" + str(b1) + "," + str(b2) + "," + str(b3) + ",t=" + str(t1) + "," + str(t2) + "," + str(t3)
            self.fibo_ok2 = self.fibo_ok2 + 1
        elif r3 > (t3 - self.tol) and r3 < (t3 + self.tol) :
            #print "p3=" + str(p1) + "," + str(p2) + "," + str(p3) + ",r=" + str(r1) + "," + str(r2) + "," + str(r3) + ",b=" + str(b1) + "," + str(b2) + "," + str(b3) + ",t=" + str(t1) + "," + str(t2) + "," + str(t3)
            self.fibo_ok3 = self.fibo_ok3 + 1




class StockCodes:
    def __init__(self):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")

    def get(self):
        cursor = self.connection.cursor()
        cursor.execute( "select stockCode from stockMasterFull where nk225flag='1'")
        #cursor.execute( "select stockCode from stockMasterFull")
        result = cursor.fetchall()
        codes=[]
        for x in result:
            codes.append(x[0])
        return(codes)

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    stockCode = "6758"
    #ff=FiboFan(stockCode,0.01)
    #ff.calc()

    #exit(0)

    if argc >= 2:
        stockCode = argvs[1]

    print "|zigzag|fibo_allnum|fibo_num|fibo_ok 61|fibo_ok 50|fibo_ok 38|ratio|"
    print "|---:|---:|---:|---:|---:|---:|---:|"
    sc=StockCodes()
    stockCodes=sc.get()
    for x in range(1,10):
        zigzag=0.01*x
        fibo_allnum=0
        fibo_num=0
        fibo_ok1=0
        fibo_ok2=0
        fibo_ok3=0
        for stockCode in stockCodes:
            fibo=FiboFan(stockCode,zigzag)
            fibo.calc()
            fibo_allnum=fibo_allnum+fibo.fibo_allnum
            fibo_ok1=fibo_ok1+fibo.fibo_ok1
            fibo_ok2=fibo_ok2+fibo.fibo_ok2
            fibo_ok3=fibo_ok3+fibo.fibo_ok3
            fibo_num=fibo_num+fibo.fibo_num
            ratio=0
            if fibo_num>0:
                ratio=(float(fibo_ok1) + float(fibo_ok2) + float(fibo_ok3)) / float(fibo_num)
        print "|"+str(zigzag)+"|"+str(fibo_allnum)+"|"+str(fibo_num)+"|"+str(fibo_ok1)+"|"+str(fibo_ok2)+"|"+str(fibo_ok3)+"|"+str(ratio)+"|"
