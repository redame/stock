#!/bin/env python
# coding:utf-8

import MySQLdb
import sys
import numpy as np
from qrzigzag import peak_valley_pivots


# ラインの間にろうそくがどれだけあるか率

class PatternCheck:
    def __init__(self, stockCode, zigzag, ashi, table, fromDate,toDate):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.stockCode=stockCode
        self.zigzag=zigzag
        self.ashi=ashi
        self.table=table
        self.fromDate=fromDate
        self.toDate=toDate

    def __ptnCheckCandleBetweenLine(self, ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x):
        upper_cnt = 0
        for x in range(st_x, ed_x + 1):
            line_upper = ((ed_ly1 - st_ly1) / (ed_lx1 - st_lx1)) * (x - st_lx1) + st_ly1
            if ohlc[x][2] < line_upper:
                upper_cnt = upper_cnt + 1

        lower_cnt = 0
        for x in range(st_x, ed_x + 1):
            line_lower = ((ed_ly2 - st_ly2) / (ed_lx2 - st_lx2)) * (x - st_lx2) + st_ly2
            if ohlc[x][3] > line_lower:
                lower_cnt = lower_cnt + 1

        upper_ratio = float(upper_cnt) / float(ed_lx1 + 1 - st_lx1)  # ok ratio
        lower_ratio = float(lower_cnt) / float(ed_lx2 + 1 - st_lx2)  # ok ratio
        return (upper_ratio,lower_ratio)

    def __chk_ptn(self,ptnTable):
        cursor = self.connection.cursor()
        cursor.execute("select date,oprice,high,low,cprice from live."+self.table+" where stockCode=%s and date between %s and %s order by date",(self.stockCode,self.fromDate,self.toDate))
        ohlc=cursor.fetchall()

        cursor = self.connection.cursor()
        cursor.execute("select line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,date_from,date_to from "+ptnTable+" where stockCode=%s and zigzag=%s and ashi=%s order by date_to desc ",(self.stockCode,self.zigzag,self.ashi))
        data = cursor.fetchall()
        for item in data:
            st_lx1=tuple(x[0] for x in ohlc).index(item[0])
            st_ly1=item[1]
            ed_lx1=tuple(x[0] for x in ohlc).index(item[2])
            ed_ly1=item[3]
            st_lx2=tuple(x[0] for x in ohlc).index(item[4])
            st_ly2=item[5]
            ed_lx2=tuple(x[0] for x in ohlc).index(item[6])
            ed_ly2=item[7]
            st_x=tuple(x[0] for x in ohlc).index(item[8])
            ed_x=tuple(x[0] for x in ohlc).index(item[9])
            (upper_ratio,lower_ratio)=self.__ptnCheckCandleBetweenLine(ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x)
            cursor.execute("replace into ptnCheckRatio values (%s,%s,%s,%s,%s,%s,%s,%s)",(ptnTable,self.stockCode,self.zigzag,item[8],item[9],self.ashi,upper_ratio,lower_ratio))
            print ("ptnTable="+ptnTable+",stockCode="+self.stockCode+",zigzag="+str(self.zigzag)+",upper="+str(upper_ratio)+",lower="+str(lower_ratio))
            self.connection.commit()
        cursor.close()


    def check(self):
        self.__chk_ptn("ptnDoubleBottom")
        self.__chk_ptn("ptnDoubleTop")
        self.__chk_ptn("ptnDownChannel")
        self.__chk_ptn("ptnFallingTriangle")
        self.__chk_ptn("ptnFallingWedge")
        #self.__chk_ptn("ptnHeadAndShoulderBottom")
        #self.__chk_ptn("ptnHeadAndShoulderTop")
        self.__chk_ptn("ptnRisingTriangle")
        self.__chk_ptn("ptnRisingWedge")
        self.__chk_ptn("ptnTripleBottom")
        self.__chk_ptn("ptnTripleTop")
        self.__chk_ptn("ptnUpChannel")

class Calcurator:
    def __init__(self, fromDate, toDate, ashi):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="")
        self.fromDate = fromDate
        self.toDate = toDate
        self.ashi = ashi
        self.table = "ST_priceHistAdj"
        if self.ashi == "m":
            self.table = "ST_priceHistMonthly"
        elif self.ashi == "w":
            self.table = "ST_priceHistWeekly"

    def execute(self):
        cursor = self.connection.cursor()
        cursor.execute("select stockCode from live.stockMasterFull where nk225Flag='1' order by stockCode")
        stockCodes = cursor.fetchall()
        for stockCode in stockCodes:
            for i in range(1, 11):
                zigzag = i * 0.01
                PatternCheck(stockCode[0], zigzag, self.ashi, self.table,self.fromDate,self.toDate).check()

        cursor.close()
        self.connection.close()


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate = "2000-01-01"
    toDate = "2015-12-31"
    ashi = "w"
    Calcurator(fromDate, toDate, ashi).execute()
    ashi = "m"
    Calcurator(fromDate, toDate, ashi).execute()
    ashi = "d"
    Calcurator(fromDate, toDate, ashi).execute()


