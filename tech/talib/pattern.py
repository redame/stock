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


# パターンを計算しDB格納

class PatternCalcurator:
    def __init__(self,fromDate,toDate):
        self.connection = MySQLdb.connect(host="localhost",db="live",user="root",passwd="")
        self.fromDate=fromDate
        self.toDate = toDate

        self.connection2 = MySQLdb.connect(host="localhost",db="fintech",user="root",passwd="")
    def calc(self,stockCode):
        cursor=self.connection.cursor()
        cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s and date<=%s",(stockCode,self.fromDate,self.toDate))
        result = cursor.fetchall()

        ohlc=[]
        for row in result:
            ohlc.append((row[0],row[1],row[2],row[3],row[4],row[5]))
        cursor.close()

        oprice=np.asfarray(np.asarray(ohlc)[:,1])
        hprice=np.asfarray(np.asarray(ohlc)[:,2])
        lprice=np.asfarray(np.asarray(ohlc)[:,3])
        cprice=np.asfarray(np.asarray(ohlc)[:,4])
        # cat a |awk '{print "self.__write(\""$1"\",stockCode,ohlc,ta."$1"(oprice,hprice,lprice,cprice))"}'

        self.__write("CDL2CROWS", stockCode, ohlc, ta.CDL2CROWS(oprice, hprice, lprice, cprice))
        self.__write("CDL3BLACKCROWS", stockCode, ohlc, ta.CDL3BLACKCROWS(oprice, hprice, lprice, cprice))
        self.__write("CDL3INSIDE", stockCode, ohlc, ta.CDL3INSIDE(oprice, hprice, lprice, cprice))
        self.__write("CDL3LINESTRIKE", stockCode, ohlc, ta.CDL3LINESTRIKE(oprice, hprice, lprice, cprice))
        self.__write("CDL3OUTSIDE", stockCode, ohlc, ta.CDL3OUTSIDE(oprice, hprice, lprice, cprice))
        self.__write("CDL3STARSINSOUTH", stockCode, ohlc, ta.CDL3STARSINSOUTH(oprice, hprice, lprice, cprice))
        self.__write("CDL3WHITESOLDIERS", stockCode, ohlc, ta.CDL3WHITESOLDIERS(oprice, hprice, lprice, cprice))
        self.__write("CDLABANDONEDBABY", stockCode, ohlc, ta.CDLABANDONEDBABY(oprice, hprice, lprice, cprice))
        self.__write("CDLADVANCEBLOCK", stockCode, ohlc, ta.CDLADVANCEBLOCK(oprice, hprice, lprice, cprice))
        self.__write("CDLBELTHOLD", stockCode, ohlc, ta.CDLBELTHOLD(oprice, hprice, lprice, cprice))
        self.__write("CDLBREAKAWAY", stockCode, ohlc, ta.CDLBREAKAWAY(oprice, hprice, lprice, cprice))
        self.__write("CDLCLOSINGMARUBOZU", stockCode, ohlc, ta.CDLCLOSINGMARUBOZU(oprice, hprice, lprice, cprice))
        self.__write("CDLCONCEALBABYSWALL", stockCode, ohlc, ta.CDLCONCEALBABYSWALL(oprice, hprice, lprice, cprice))
        self.__write("CDLCOUNTERATTACK", stockCode, ohlc, ta.CDLCOUNTERATTACK(oprice, hprice, lprice, cprice))
        self.__write("CDLDARKCLOUDCOVER", stockCode, ohlc, ta.CDLDARKCLOUDCOVER(oprice, hprice, lprice, cprice))
        self.__write("CDLDOJI", stockCode, ohlc, ta.CDLDOJI(oprice, hprice, lprice, cprice))
        self.__write("CDLDOJISTAR", stockCode, ohlc, ta.CDLDOJISTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLDRAGONFLYDOJI", stockCode, ohlc, ta.CDLDRAGONFLYDOJI(oprice, hprice, lprice, cprice))
        self.__write("CDLENGULFING", stockCode, ohlc, ta.CDLENGULFING(oprice, hprice, lprice, cprice))
        self.__write("CDLEVENINGDOJISTAR", stockCode, ohlc, ta.CDLEVENINGDOJISTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLEVENINGSTAR", stockCode, ohlc, ta.CDLEVENINGSTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLGAPSIDESIDEWHITE", stockCode, ohlc, ta.CDLGAPSIDESIDEWHITE(oprice, hprice, lprice, cprice))
        self.__write("CDLGRAVESTONEDOJI", stockCode, ohlc, ta.CDLGRAVESTONEDOJI(oprice, hprice, lprice, cprice))
        self.__write("CDLHAMMER", stockCode, ohlc, ta.CDLHAMMER(oprice, hprice, lprice, cprice))
        self.__write("CDLHANGINGMAN", stockCode, ohlc, ta.CDLHANGINGMAN(oprice, hprice, lprice, cprice))
        self.__write("CDLHARAMI", stockCode, ohlc, ta.CDLHARAMI(oprice, hprice, lprice, cprice))
        self.__write("CDLHARAMICROSS", stockCode, ohlc, ta.CDLHARAMICROSS(oprice, hprice, lprice, cprice))
        self.__write("CDLHIGHWAVE", stockCode, ohlc, ta.CDLHIGHWAVE(oprice, hprice, lprice, cprice))
        self.__write("CDLHIKKAKE", stockCode, ohlc, ta.CDLHIKKAKE(oprice, hprice, lprice, cprice))
        self.__write("CDLHIKKAKEMOD", stockCode, ohlc, ta.CDLHIKKAKEMOD(oprice, hprice, lprice, cprice))
        self.__write("CDLHOMINGPIGEON", stockCode, ohlc, ta.CDLHOMINGPIGEON(oprice, hprice, lprice, cprice))
        self.__write("CDLIDENTICAL3CROWS", stockCode, ohlc, ta.CDLIDENTICAL3CROWS(oprice, hprice, lprice, cprice))
        self.__write("CDLINNECK", stockCode, ohlc, ta.CDLINNECK(oprice, hprice, lprice, cprice))
        self.__write("CDLINVERTEDHAMMER", stockCode, ohlc, ta.CDLINVERTEDHAMMER(oprice, hprice, lprice, cprice))
        self.__write("CDLKICKING", stockCode, ohlc, ta.CDLKICKING(oprice, hprice, lprice, cprice))
        self.__write("CDLKICKINGBYLENGTH", stockCode, ohlc, ta.CDLKICKINGBYLENGTH(oprice, hprice, lprice, cprice))
        self.__write("CDLLADDERBOTTOM", stockCode, ohlc, ta.CDLLADDERBOTTOM(oprice, hprice, lprice, cprice))
        self.__write("CDLLONGLEGGEDDOJI", stockCode, ohlc, ta.CDLLONGLEGGEDDOJI(oprice, hprice, lprice, cprice))
        self.__write("CDLLONGLINE", stockCode, ohlc, ta.CDLLONGLINE(oprice, hprice, lprice, cprice))
        self.__write("CDLMARUBOZU", stockCode, ohlc, ta.CDLMARUBOZU(oprice, hprice, lprice, cprice))
        self.__write("CDLMATCHINGLOW", stockCode, ohlc, ta.CDLMATCHINGLOW(oprice, hprice, lprice, cprice))
        self.__write("CDLMATHOLD", stockCode, ohlc, ta.CDLMATHOLD(oprice, hprice, lprice, cprice))
        self.__write("CDLMORNINGDOJISTAR", stockCode, ohlc, ta.CDLMORNINGDOJISTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLMORNINGSTAR", stockCode, ohlc, ta.CDLMORNINGSTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLONNECK", stockCode, ohlc, ta.CDLONNECK(oprice, hprice, lprice, cprice))
        self.__write("CDLPIERCING", stockCode, ohlc, ta.CDLPIERCING(oprice, hprice, lprice, cprice))
        self.__write("CDLRICKSHAWMAN", stockCode, ohlc, ta.CDLRICKSHAWMAN(oprice, hprice, lprice, cprice))
        self.__write("CDLRISEFALL3METHODS", stockCode, ohlc, ta.CDLRISEFALL3METHODS(oprice, hprice, lprice, cprice))
        self.__write("CDLSEPARATINGLINES", stockCode, ohlc, ta.CDLSEPARATINGLINES(oprice, hprice, lprice, cprice))
        self.__write("CDLSHOOTINGSTAR", stockCode, ohlc, ta.CDLSHOOTINGSTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLSHORTLINE", stockCode, ohlc, ta.CDLSHORTLINE(oprice, hprice, lprice, cprice))
        self.__write("CDLSPINNINGTOP", stockCode, ohlc, ta.CDLSPINNINGTOP(oprice, hprice, lprice, cprice))
        self.__write("CDLSTALLEDPATTERN", stockCode, ohlc, ta.CDLSTALLEDPATTERN(oprice, hprice, lprice, cprice))
        self.__write("CDLSTICKSANDWICH", stockCode, ohlc, ta.CDLSTICKSANDWICH(oprice, hprice, lprice, cprice))
        self.__write("CDLTAKURI", stockCode, ohlc, ta.CDLTAKURI(oprice, hprice, lprice, cprice))
        self.__write("CDLTASUKIGAP", stockCode, ohlc, ta.CDLTASUKIGAP(oprice, hprice, lprice, cprice))
        self.__write("CDLTHRUSTING", stockCode, ohlc, ta.CDLTHRUSTING(oprice, hprice, lprice, cprice))
        self.__write("CDLTRISTAR", stockCode, ohlc, ta.CDLTRISTAR(oprice, hprice, lprice, cprice))
        self.__write("CDLUNIQUE3RIVER", stockCode, ohlc, ta.CDLUNIQUE3RIVER(oprice, hprice, lprice, cprice))
        self.__write("CDLUPSIDEGAP2CROWS", stockCode, ohlc, ta.CDLUPSIDEGAP2CROWS(oprice, hprice, lprice, cprice))
        self.__write("CDLXSIDEGAP3METHODS", stockCode, ohlc, ta.CDLXSIDEGAP3METHODS(oprice, hprice, lprice, cprice))

        self.connection.close()
        self.connection2.close()

    def __write(self,pattern,stockCode,ohlc,values):
        adr=0
        for value in values:
            if value != 0:
                date=ohlc[adr][0].strftime("%Y-%m-%d")
                self.__write_to_db(date,stockCode,pattern,value)
            adr=adr+1

    def __write_to_db(self,date,stockCode,pattern,value):
        print date+","+stockCode+","+pattern+","+str(value)
        cursor=self.connection2.cursor()
        cursor.execute("replace into fintech.talibPattern(date,stockCode,pattern,value) values(%s,%s,%s,%s)",(date,stockCode,pattern,value))
        self.connection2.commit()
        cursor.close()


class Executor:
    def __init__(self,fromDate,toDate):
        self.connection = MySQLdb.connect(host="localhost",db="live",user="root",passwd="")
        self.fromDate=fromDate
        self.toDate=toDate


    def calc(self):
        cursor=self.connection.cursor()
        cursor.execute("select distinct stockCode from ST_priceHistAdj where date>=%s and date<=%s order by stockCode",(self.fromDate,self.toDate))
        stockCodes = cursor.fetchall()
        for stockCode in stockCodes:
            print stockCode[0]
            PatternCalcurator(self.fromDate,self.toDate).calc(stockCode[0])
        cursor.close()
        self.connection.close()

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate='2000-01-01'
    toDate = '2010-12-31'
    Executor(fromDate,toDate).calc()
