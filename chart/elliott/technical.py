#!/bin/env python
# coding:utf-8

import talib as ta
import MySQLdb
import sys
import numpy as np
import math

class Technical:
    def __init__(self):
        self.con = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")
        self.startDate="2001-01-01"
        self.endDate="2015-12-31"

    def calc(self):
        cursor=self.con.cursor()
        cursor.execute("select distinct stockCode from ST_priceHistAdj where date >= %s and date<= %s ",(self.startDate,self.endDate))
        res=cursor.fetchall()
        for i in range(0,len(res)):
            stockCode=res[i]
            self.calc_tech(stockCode)

    def calc_tech(self,stockCode):
        ohlc=self.__get_data(stockCode)
        self.__calc_technicals(stockCode,ohlc)


    def __get_data(self,stockCode):
        cursor=self.con.cursor()
        cursor.execute("select date_format(date,'%%Y-%%m-%%d') as date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date >= %s and date<= %s order by date",(stockCode,self.startDate,self.endDate))
        res=cursor.fetchall()
        self.con.commit()

        date=[]
        openingPrice=[]
        highPrice=[]
        lowPrice=[]
        closingPrice=[]
        for i in range(0,len(res)):
            date.append(res[i][0])
            openingPrice.append(res[i][1])
            highPrice.append(res[i][2])
            lowPrice.append(res[i][3])
            closingPrice.append(res[i][4])
        ohlc=(date,np.asarray(openingPrice),np.asarray(highPrice),np.asarray(lowPrice),np.asarray(closingPrice))
        return ohlc

    def val(self,v):
        if math.isnan(v):
            return None
        else:
            return v

    def __calc_technicals(self,stockCode,ohlc):
        date=ohlc[0]
        rsi=ta.RSI(ohlc[4])
        aroon=ta.AROON(ohlc[2],ohlc[3])
        aroon_osc=ta.AROONOSC(ohlc[2],ohlc[3])
        macd=ta.MACD(ohlc[4])
        willr=ta.WILLR(ohlc[2],ohlc[3],ohlc[4])
        atr=ta.ATR(ohlc[2],ohlc[3],ohlc[4])
        for i in range(0,len(date)):
            cur=self.con.cursor()
            cur.execute("replace into fintech.technical values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(stockCode,date[i],self.val(rsi[i]),self.val(aroon[0][i]),self.val(aroon[1][i]),self.val(aroon_osc[i]),self.val(macd[0][i]),self.val(macd[1][i]),self.val(macd[2][i]),self.val(willr[i]),self.val(atr[i])))
            self.con.commit()



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    Technical().calc()