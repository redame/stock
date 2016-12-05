#!/bin/env python
# coding:utf-8

import MySQLdb
import sys

import talib as ta
import numpy as np


# パターンを計算しDB格納

class TechnicalCalcurator:
    def __init__(self,fromDate,toDate):
        self.connection = MySQLdb.connect(host="localhost",db="stock",user="stock",passwd="")
        self.fromDate=fromDate
        self.toDate = toDate

        self.connection2 = MySQLdb.connect(host="localhost",db="stock",user="stock",passwd="")
    def calc(self,code):
        cursor=self.connection.cursor()
        cursor.execute("select date,open,high,low,close,volume from histDaily where code=%s and date>=%s and date<=%s",(code,self.fromDate,self.toDate))
        result = cursor.fetchall()

        ohlc=[]
        for row in result:
            ohlc.append((row[0],row[1],row[2],row[3],row[4],row[5]))
        cursor.close()

        oprice=np.asfarray(np.asarray(ohlc)[:,1])
        hprice=np.asfarray(np.asarray(ohlc)[:,2])
        lprice=np.asfarray(np.asarray(ohlc)[:,3])
        cprice=np.asfarray(np.asarray(ohlc)[:,4])
        volume=np.asfarray(np.asarray(ohlc)[:,5])
        # cat a |awk '{print "self.__write(\""$1"\",code,ohlc,ta."$1"(oprice,hprice,lprice,cprice))"}'
        print ta.AROON(hprice,lprice)



        self.connection.close()
        self.connection2.close()

    def __write(self,pattern,code,ohlc,values):
        adr=0
        for value in values:
            if value != 0:
                date=ohlc[adr][0].strftime("%Y-%m-%d")
                self.__write_to_db(date,code,pattern,value)
            adr=adr+1

    def __write_to_db(self,date,code,pattern,value):
        print date+","+code+","+pattern+","+str(value)
        cursor=self.connection2.cursor()
        cursor.execute("replace into talibTechnical(date,code,technical,value) values(%s,%s,%s,%s)",(date,code,pattern,value))
        self.connection2.commit()
        cursor.close()


class Executor:
    def __init__(self,fromDate,toDate):
        self.connection = MySQLdb.connect(host="localhost",db="live",user="root",passwd="")
        self.fromDate=fromDate
        self.toDate=toDate


    def calc(self):
        cursor=self.connection.cursor()
        cursor.execute("select distinct code from ST_priceHistAdj where date>=%s and date<=%s",(self.fromDate,self.toDate))
        codes = cursor.fetchall()
        for code in codes:
            print code[0]
            TechnicalCalcurator(self.fromDate,self.toDate).calc(code[0])
        cursor.close()
        self.connection.close()

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate='2000-01-01'
    toDate = '2010-12-31'
    #Executor(fromDate,toDate).calc()
    TechnicalCalcurator(fromDate,toDate).calc("6758")
