#!/bin/env python
# coding:utf-8

import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc
import time
import MySQLdb
import sys

import talib as ta
import numpy as np

import pandas as pd
from qrzigzag import peak_valley_pivots, max_drawdown, compute_segment_returns, pivots_to_modes
from qrpeakbottm import calc_peakbottom

#http://qiita.com/5t111111/items/3d9efdbcc630daf0e48f

# http://zaaf01d/trac/chart/svn/trunk/technicals/python/aroonIndicator.py
# http://qiita.com/ynakayama/items/897cc932008bd5c0e452
# http://tatabox.hatenablog.com/entry/2015/05/31/225133
class Chart:
    def __init__(self):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")
        self.fromDate='2008-01-01'
        self.toDate = '2010-12-31'
        np.random.seed(1997)

    def chart(self,stockCode):
        cursor=self.connection.cursor()
        cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s and date<=%s",[stockCode,self.fromDate,self.toDate])
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
        open=np.asarray(ohlc)[:,1]
        high=np.asarray(ohlc)[:,2]
        low=np.asarray(ohlc)[:,3]
        close=np.asarray(ohlc)[:,4]
        step=int(len(close)/5)
        # graph上のfloat型の日付と、表示文字列を紐付けている
        plt.xticks(fdate[::step],[x.strftime('%Y-%m-%d') for x in ddate][::step])

        ax = plt.subplot()
        candlestick_ohlc(ax,ohlc)

        # 5 日単純移動平均を求める
        #sma5 = ta.SMA(close, timeperiod=5)
        #plt.plot(sma5,label="SMA5")

        # trendline
        line=self.interpolation(100,200,3000,3500,len(close))
        plt.plot(line,label="line")

        # zigzag
        #pivots = peak_valley_pivots(open,high,low,close, 0.1, -0.1)
        pivots = calc_peakbottom(open,high,low,close,10)

        #plt.plot(pivots)
        print(pivots)
        ts_pivots = pd.Series(close)
        ts_pivots = ts_pivots[pivots != 0]
        plt.plot(ts_pivots,label="test")
        print (ts_pivots)

        plt.xlabel('Date')
        plt.ylabel('Price')
        plt.title("title")
        plt.legend()
        plt.show()

    def interpolation(self,stx,edx,sty,edy,size):
        line=np.empty(size)
        line[:]=np.NAN
        b=(edy-sty)/(edx-stx)
        for x in range(stx,edx):
            line[x]=b*(x-stx)+sty
        return(line)

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    elli=Chart()
    elli.chart("6758")
