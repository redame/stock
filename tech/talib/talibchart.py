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


# チャートサンプル

class Chart:
    def __init__(self):
        self.connection = MySQLdb.connect(host="localhost",db="live",user="root",passwd="")
        self.fromDate='2005-01-01'
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

        self.__draw_chart(ohlc,fdate,ddate)

    def __draw_chart(self,ohlc,fdate,ddate):
        fig, (axT, axB) = plt.subplots(nrows=2,sharex=True)

        open=np.asarray(ohlc)[:,1]
        high=np.asarray(ohlc)[:,2]
        low=np.asarray(ohlc)[:,3]
        close=np.asarray(ohlc)[:,4]
        step=int(len(close)/5)

        # graph上のfloat型の日付と、表示文字列を紐付けている
        plt.xticks(fdate[::step],[x.strftime('%Y-%m-%d') for x in ddate][::step])

        #ax = axT.subplot()
        candlestick_ohlc(axT,ohlc)

        # 5 日単純移動平均を求める
        #sma5 = ta.SMA(close, timeperiod=5)
        #plt.plot(sma5,label="SMA5")


        axT.plot(ta.HT_TRENDLINE(close),label="TRENDLINE")


        # trendline
        #line=self.interpolation(100,200,3000,3500,len(close))
        #plt.plot(line,label="line")

        ret=ta.CDL2CROWS(open,high,low,close)
        print ret
        ret=ta.CDLMARUBOZU(open,high,low,close)
        print ret

        axT.set_xlabel('Date')
        axT.set_ylabel('Price')
        axT.set_title("title")
        axT.legend()

        macd,macdsignal,macdhist=ta.MACD(close)

        axB.plot(macd,label="MACD")
        axB.plot(macdhist,label="MACD-Hist")
        axB.plot(macdsignal,label="MACD-Signal")
        axB.set_xlabel("Date")
        axB.legend()
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
