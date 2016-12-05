#!/bin/env python
# coding:utf-8

# calcurate fibonatti retracement

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

class FiboRet:
    def __init__(self,stockCode,zigzag):
        self.tol=0.04
        self.fibo1=0.618
        self.fibo2=0.5
        self.fibo3=0.382
        self.stockCode=stockCode
        self.zigzag=zigzag
        self.pb = PeakBottom(self.zigzag)
        self.fibo_allnum=0 #  peak bottom の全ての数　
        self.fibo_num=0  # 初期点をつきぬける
        self.fibo_ok1=0
        self.fibo_ok2 = 0
        self.fibo_ok3 = 0

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
                self.calc_fiboret(p1,p2,p3,p4)

    def get_point(self, i):
        for j in range(i, len(self.pb.pivots)):
            if self.pb.pivots[j] != 0:
                return(j)
        return(None)

    def calc_fiboret(self,p1,p2,p3,p4):
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

        fibo=self.check_fibo(r1,r2,r3,r4)
        #if fibo is not None:
            #print self.stockCode + "," + str(self.zigzag) + "," + str(fibo) + "," + str(self.pb.ohlc[p1][0])



    def check_fibo(self,r1,r2,r3,r4):
        if (r1>r2 and r2>r4) or (r1<r2 and r4>r2):   # 初期点を突き抜ける場合
            dif1=abs(r2-r1)
            dif2=abs(r3-r2)
            ratio=dif2/dif1
            self.fibo_num=self.fibo_num+1
            if ratio > (self.fibo1 - self.tol) and ratio < (self.fibo1 + self.tol):  # 61.8%で反発、反落
                self.fibo_ok1 = self.fibo_ok1 + 1
                return self.fibo1
            elif ratio > (self.fibo2 - self.tol) and ratio < (self.fibo2 + self.tol): # 50%で反発、反落
                self.fibo_ok2 = self.fibo_ok2 + 1
                return self.fibo2
            elif ratio > (self.fibo3 - self.tol) and ratio < (self.fibo3 + self.tol): # 38.2%で反発、反落
                self.fibo_ok3 = self.fibo_ok3 + 1
                return self.fibo3
        return(None)  # それ以外


class StockCodes:
    def __init__(self):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")

    def get(self):
        cursor = self.connection.cursor()
        #cursor.execute( "select stockCode from stockMasterFull where nk225flag='1'")
        cursor.execute( "select stockCode from stockMasterFull")
        result = cursor.fetchall()
        codes=[]
        for x in result:
            codes.append(x[0])
        return(codes)

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    stockCode = "6758"

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
            fibo=FiboRet(stockCode,zigzag)
            fibo.calc()
            fibo_ok1=fibo_ok1+fibo.fibo_ok1
            fibo_ok2=fibo_ok2+fibo.fibo_ok2
            fibo_ok3=fibo_ok3+fibo.fibo_ok3
            fibo_num=fibo_num+fibo.fibo_num
            fibo_allnum=fibo_allnum+fibo.fibo_allnum
        print "|"+str(zigzag)+"|"+str(fibo_allnum)+"|"+str(fibo_num)+"|"+str(fibo_ok1)+"|"+str(fibo_ok2)+"|"+str(fibo_ok3)+"|"+str((float(fibo_ok1)+float(fibo_ok2)+float(fibo_ok3))/float(fibo_num))+"|"
