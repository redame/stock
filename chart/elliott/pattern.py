#!/bin/env python
# coding:utf-8


# for
import MySQLdb
import sys
import numpy as np
from qrzigzag import peak_valley_pivots


class Pattern:
    def __init__(self, stockCode, fromDate, toDate, zigzag, ashi, table):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="")
        self.connection2 = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.fromDate = fromDate
        self.toDate = toDate
        self.zigzag = zigzag
        self.PB_ADR = 7  # address of peak bottom flag in ohlc
        self.stockCode = stockCode
        self.figure = 0
        self.ashi = ashi
        self.table = table
        self.TOL=0.02 #  平行とみなす誤差範囲
        print "(" + str(stockCode) + ")," +str(self.ashi)+ "," + fromDate + " - " + toDate + ",zigzag=" + str(self.zigzag)

    def calc(self):
        ohlc = self.__peakbottom(self.stockCode)
        if ohlc is None:
            return

        for i in range(0, len(ohlc)):
            if ohlc[i][self.PB_ADR] == 0:  # start from peak or bottom
                continue

            pnts = self.__get_points(ohlc, i, 9)
            if pnts is not None:
                try:
                    (prices, dates) = self.__get_prices(ohlc, pnts)
                    self.__ptnHeadAndShoulderTop(ohlc,pnts,prices,dates)
                    self.__ptnHeadAndShoulderBottom(ohlc,pnts,prices,dates)
                    self.__ptnTripleTop(ohlc,pnts,prices,dates)
                    self.__ptnTripleBottom(ohlc,pnts,prices,dates)
                    self.__ptnRisingTriangle(ohlc,pnts,prices,dates)
                    self.__ptnFallingTriangle(ohlc,pnts,prices,dates)
                    self.__ptnRisingWedge( ohlc, pnts, prices, dates)
                    self.__ptnFallingWedge( ohlc, pnts, prices, dates)
                    self.__ptnUpChannel( ohlc, pnts, prices, dates)
                    self.__ptnDownChannel( ohlc, pnts, prices, dates)
                    self.__ptnDoubleTop( ohlc, pnts, prices, dates)
                    self.__ptnDoubleBottom( ohlc, pnts, prices, dates)
                except:
                    print "Unexpected error:", sys.exc_info()[0]



    def __ptnHeadAndShoulderTop(self,ohlc,pnts,prices,dates):
        # ０点目はボトム
        if ohlc[pnts[0]][self.PB_ADR]!=-1:
            return
        # 線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line1_price=(prices[2]+prices[4])/2

        # 0点目は下の線以下
        if prices[0] > line1_price:
            return
        # 6点目は下線の下
        if prices[6] > line1_price:
            return

        # 1点目　＜　３点目　、５点目　＜　３点目
        if prices[1] > prices[3]:
            return
        if prices[5] > prices[3]:
            return

        # ラインの始点は０点目のX位置から、終点は6点目のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[6]
        line1_edPrice=line1_stPrice

        self.__write_to_db("replace into ptnHeadAndShoulderTop values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],dates[6],prices[6],self.ashi))
        return


    def __ptnHeadAndShoulderBottom(self,ohlc,pnts,prices,dates):
        # ０点目はピーク
        if ohlc[pnts[0]][self.PB_ADR]!=1:
            return
        # 線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line1_price=(prices[2]+prices[4])/2

        # 0点目は線以上
        if prices[0] < line1_price:
            return
        # 6点目は線以上
        if prices[6] < line1_price:
            return

        # 1点目　>　３点目　、５点目　>　３点目
        if prices[1] < prices[3]:
            return
        if prices[5] < prices[3]:
            return

        # ラインの始点は０点目のX位置から、終点は6点目のX位置
        # line1 上線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[6]
        line1_edPrice=line1_stPrice

        self.__write_to_db("replace into ptnHeadAndShoulderBottom values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],dates[6],prices[6],self.ashi))
        return

    def __ptnTripleTop(self,ohlc,pnts,prices,dates):
        # ０点目はボトム
        if ohlc[pnts[0]][self.PB_ADR]!=-1:
            return
        # 上の線は誤差範囲内のY位置
        if abs(max(prices[1],prices[3],prices[5])-min(prices[1],prices[3],prices[5]))/min(prices[1],prices[3],prices[5]) > self.TOL:
            return
        line1_price=(max(prices[1],prices[3],prices[5])+min(prices[1],prices[3],prices[5]))/2
        # 下の線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line2_price=(prices[2]+prices[4])/2
        # 0点目は下の線以下
        if prices[0] > line2_price:
            return
        # 6点目は下の線以下
        if prices[6] > line2_price:
            return
        # ラインの始点は０点目のX位置から、終点は6点目のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[6]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=line2_price
        line2_edDate=line1_edDate
        line2_edPrice=line2_stPrice
        self.__write_to_db("replace into ptnTripleTop values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],dates[6],prices[6],self.ashi))
        return

    def __ptnTripleBottom(self,ohlc,pnts,prices,dates):
        # ０点目はピーク
        if ohlc[pnts[0]][self.PB_ADR]!=1:
            return
        # 上の線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line1_price=(prices[2]+prices[4])/2

        # 下の線は誤差範囲内のY位置
        if abs(max(prices[1],prices[3],prices[5])-min(prices[1],prices[3],prices[5]))/min(prices[1],prices[3],prices[5]) > self.TOL:
            return
        line2_price=(max(prices[1],prices[3],prices[5])+min(prices[1],prices[3],prices[5]))/2

        # 0点目は上の線以上
        if prices[0] < line1_price:
            return
        # 6点目は上の線以上
        if prices[6] < line1_price:
            return

        # ラインの始点は０点目のX位置から、終点は6点目のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[6]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=line2_price
        line2_edDate=line1_edDate
        line2_edPrice=line2_stPrice
        self.__write_to_db("replace into ptnTripleBottom values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],dates[6],prices[6],self.ashi))
        return

    def __ptnRisingTriangle(self,ohlc,pnts,prices,dates):
        # ０点目はボトム
        if ohlc[pnts[0]][self.PB_ADR]!=-1 :
            return
        # 上の線は誤差範囲内のY位置
        if abs(prices[1]-prices[3])/prices[1] > self.TOL:
            return
        # 下の線の傾き
        slope=(prices[4]-prices[2])/(pnts[4]-pnts[2])
        if slope <= self.TOL :
            return
        # 2個先の頂点のX位置を越える前にクロスすること
        if (prices[1]-prices[2])/slope+pnts[2] > pnts[6]:
            return
        # 0点目は下の直線の下側にあること
        if slope*(pnts[0]-pnts[2])+prices[2] < prices[0]:
            return
        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=(prices[1]+prices[3])/2
        line1_edDate=dates[5]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=slope*(pnts[0]-pnts[2])+prices[2]
        line2_edDate=line1_edDate
        line2_edPrice=slope*(pnts[5]-pnts[2])+prices[2]
        self.__write_to_db("replace into ptnRisingTriangle values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return

    def __ptnFallingTriangle(self,ohlc,pnts,prices,dates):
        # ０点目はピーク
        if ohlc[pnts[0]][self.PB_ADR]!=1 :
            return
        # 下の線は誤差範囲内のY位置
        if abs(prices[1]-prices[3])/prices[1] > self.TOL:
            return
        # 上の線の傾き
        slope=(prices[4]-prices[2])/(pnts[4]-pnts[2])
        if slope >= -self.TOL :
            return
        # 2個先の頂点のX位置を越える前にクロスすること
        if (prices[1]-prices[2])/slope+pnts[2] > pnts[6]:
            return
        # 0点目は下の直線の上側にあること
        if slope*(pnts[0]-pnts[2])+prices[2] > prices[0]:
            return
        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 下線,line2 上線
        line1_stDate=dates[0]
        line1_stPrice=(prices[1]+prices[3])/2
        line1_edDate=dates[5]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=slope*(pnts[0]-pnts[2])+prices[2]
        line2_edDate=line1_edDate
        line2_edPrice=slope*(pnts[5]-pnts[2])+prices[2]
        self.__write_to_db("replace into ptnFallingTriangle values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return

    def __ptnRisingWedge(self,ohlc,pnts,prices,dates):

        # 下の線は誤差範囲以上のY位置
        if abs(prices[1]-prices[3])/prices[1] < self.TOL:
            return
        # 上の線は誤差範囲以上のY位置
        if abs(prices[4]-prices[2])/prices[2] < self.TOL:
            return

        slope1=slope2=0

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            # 上の線の傾き
            slope1=(prices[3]-prices[1])/(pnts[3]-pnts[1])
            # 下の線の傾き
            slope2 = (prices[4] - prices[2]) / (pnts[4] - pnts[2])
        else:
            # 上の線の傾き
            slope1=(prices[4]-prices[2])/(pnts[4]-pnts[2])
            # 下の線の傾き
            slope2 = (prices[3] - prices[1]) / (pnts[3] - pnts[1])

        if slope1 <= 0:
            return
        if slope2 <= 0:
            return

        # 下のラインの傾きが上のラインの傾きより大きい（絶対値）
        # slope1は上の線
        if abs(slope1) > abs(slope2):
            return

        # 下の線と上の線は平行でない
        if abs(abs(slope1) - abs(slope2))/abs(slope2) < self.TOL:
            return

        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_edDate=dates[5]
        line2_stDate=line1_stDate
        line2_edDate = line1_edDate

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR] == 1:
            line1_stPrice = slope1 * (pnts[0] - pnts[1]) + prices[1]
            line1_edPrice = slope1 * (pnts[5] - pnts[1]) + prices[1]
            line2_stPrice = slope2 * (pnts[0] - pnts[2]) + prices[2]
            line2_edPrice = slope2 * (pnts[5] - pnts[2]) + prices[2]
        else:
            line2_stPrice = slope2 * (pnts[0] - pnts[1]) + prices[1]
            line2_edPrice = slope2 * (pnts[5] - pnts[1]) + prices[1]
            line1_stPrice = slope1 * (pnts[0] - pnts[2]) + prices[2]
            line1_edPrice = slope1 * (pnts[5] - pnts[2]) + prices[2]

        self.__write_to_db("replace into ptnRisingWedge values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return


    def __ptnFallingWedge(self,ohlc,pnts,prices,dates):

        # 下の線は誤差範囲以上のY位置
        if abs(prices[1]-prices[3])/prices[1] < self.TOL:
            return
        # 上の線は誤差範囲以上のY位置
        if abs(prices[4]-prices[2])/prices[2] < self.TOL:
            return

        slope1=slope2=0
        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            # 上の線の傾き
            slope1=(prices[3]-prices[1])/(pnts[3]-pnts[1])
            # 下の線の傾き
            slope2 = (prices[4] - prices[2]) / (pnts[4] - pnts[2])
        else:
            # 上の線の傾き
            slope1=(prices[4]-prices[2])/(pnts[4]-pnts[2])
            # 下の線の傾き
            slope2 = (prices[3] - prices[1]) / (pnts[3] - pnts[1])

        if slope1 >= 0:
            return
        if slope2 >= 0:
            return

        # 上のラインの傾きが下のラインの傾きより大きい（絶対値）
        # slope1は上の線
        if abs(slope1) < abs(slope2):
            return

        # 下の線と上の線は平行でない
        if abs(abs(slope1) - abs(slope2))/abs(slope2) < self.TOL:
            return

        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_edDate=dates[5]
        line2_stDate=line1_stDate
        line2_edDate = line1_edDate

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            line1_stPrice=slope1*(pnts[0]-pnts[1])+prices[1]
            line1_edPrice=slope1*(pnts[5]-pnts[1])+prices[1]
            line2_stPrice=slope2*(pnts[0]-pnts[2])+prices[2]
            line2_edPrice=slope2*(pnts[5]-pnts[2])+prices[2]
        else:
            line2_stPrice=slope2*(pnts[0]-pnts[1])+prices[1]
            line2_edPrice=slope2*(pnts[5]-pnts[1])+prices[1]
            line1_stPrice=slope1*(pnts[0]-pnts[2])+prices[2]
            line1_edPrice=slope1*(pnts[5]-pnts[2])+prices[2]

        self.__write_to_db("replace into ptnFallingWedge values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return



    def __ptnUpChannel(self,ohlc,pnts,prices,dates):

        # 下の線は誤差範囲以上のY位置
        if abs(prices[1]-prices[3])/prices[1] < self.TOL:
            return
        # 上の線は誤差範囲以上のY位置
        if abs(prices[4]-prices[2])/prices[2] < self.TOL:
            return

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            # 上の線の傾き
            slope1=(prices[3]-prices[1])/(pnts[3]-pnts[1])
            # 下の線の傾き
            slope2 = (prices[4] - prices[2]) / (pnts[4] - pnts[2])
        else:
            # 上の線の傾き
            slope1=(prices[4]-prices[2])/(pnts[4]-pnts[2])
            # 下の線の傾き
            slope2 = (prices[3] - prices[1]) / (pnts[3] - pnts[1])

        # 上の線の傾き
        if slope1 <= 0:
            return
        # 下の線の傾き
        if slope2 <= 0:
            return

        # 下の線と上の線は平行
        if abs(abs(slope1) - abs(slope2))/abs(slope2) > self.TOL:
            return


        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_edDate=dates[5]
        line2_stDate=line1_stDate
        line2_edDate=line1_edDate

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            line1_stPrice=slope1*(pnts[0]-pnts[1])+prices[1]
            line1_edPrice=slope1*(pnts[5]-pnts[1])+prices[1]
            line2_stPrice=slope2*(pnts[0]-pnts[2])+prices[2]
            line2_edPrice=slope2*(pnts[5]-pnts[2])+prices[2]
        else:
            line2_stPrice=slope1*(pnts[0]-pnts[1])+prices[1]
            line2_edPrice=slope1*(pnts[5]-pnts[1])+prices[1]
            line1_stPrice=slope2*(pnts[0]-pnts[2])+prices[2]
            line1_edPrice=slope2*(pnts[5]-pnts[2])+prices[2]

        self.__write_to_db("replace into ptnUpChannel values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return

    def __ptnDownChannel(self,ohlc,pnts,prices,dates):

        # 下の線は誤差範囲以上のY位置 Y軸平行でない
        if abs(prices[1]-prices[3])/prices[1] < self.TOL:
            return
        # 上の線は誤差範囲以上のY位置 Y軸平行でない
        if abs(prices[4]-prices[2])/prices[2] < self.TOL:
            return

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            # 上の線の傾き
            slope1=(prices[3]-prices[1])/(pnts[3]-pnts[1])
            # 下の線の傾き
            slope2 = (prices[4] - prices[2]) / (pnts[4] - pnts[2])
        else:
            # 上の線の傾き
            slope1=(prices[4]-prices[2])/(pnts[4]-pnts[2])
            # 下の線の傾き
            slope2 = (prices[3] - prices[1]) / (pnts[3] - pnts[1])

        # 上の線の傾き
        if slope1 >= 0:
            return
        # 下の線の傾き
        if slope2 >= 0:
            return

        # 下の線と上の線は平行
        if abs(abs(slope1) - abs(slope2))/abs(slope2) > self.TOL:
            return

        # ラインの始点は０点目のX位置から、終点は1個先のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_edDate=dates[5]
        line2_stDate=line1_stDate
        line2_edDate=line1_edDate

        # 1点目はピーク slope1は上の線
        if ohlc[pnts[1]][self.PB_ADR]==1 :
            line1_stPrice=slope1*(pnts[0]-pnts[1])+prices[1]
            line1_edPrice=slope1*(pnts[5]-pnts[1])+prices[1]
            line2_stPrice=slope2*(pnts[0]-pnts[2])+prices[2]
            line2_edPrice=slope2*(pnts[5]-pnts[2])+prices[2]
        else:
            line2_stPrice=slope1*(pnts[0]-pnts[1])+prices[1]
            line2_edPrice=slope1*(pnts[5]-pnts[1])+prices[1]
            line1_stPrice=slope2*(pnts[0]-pnts[2])+prices[2]
            line1_edPrice=slope2*(pnts[5]-pnts[2])+prices[2]

        self.__write_to_db("replace into ptnDownChannel values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],dates[5],prices[5],self.ashi))
        return

    def __ptnDoubleTop(self,ohlc,pnts,prices,dates):
        # ０点目はボトム
        if ohlc[pnts[0]][self.PB_ADR]!=-1:
            return
        # 上の線は誤差範囲内のY位置
        if abs(prices[1]-prices[3])/prices[3] > self.TOL:
            return
        line1_price=(prices[1]+prices[3])/2
        # ５点目と３点めは大きくずれている、トリプルトップにならない
        if abs(prices[3]-prices[5])/prices[5] < self.TOL:
            return

        # 下の線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line2_price=(prices[2]+prices[4])/2
        # 0点目は下の線以下
        if prices[0] > line2_price:
            return
        # 4点目は下の線以下
        if prices[4] > line2_price:
            return

        # ラインの始点は０点目のX位置から、終点4点目のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[4]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=line2_price
        line2_edDate=line1_edDate
        line2_edPrice=line2_stPrice
        self.__write_to_db("replace into ptnDoubleTop values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],self.ashi))
        return

    def __ptnDoubleBottom(self,ohlc,pnts,prices,dates):
        # ０点目はピーク
        if ohlc[pnts[0]][self.PB_ADR]!=1:
            return
        # 上の線は誤差範囲内のY位置
        if abs(prices[2]-prices[4])/prices[2] > self.TOL:
            return
        line1_price=(prices[2]+prices[4])/2

        # 下の線は誤差範囲内のY位置
        if abs(prices[1]-prices[3])/prices[1] > self.TOL:
            return
        line2_price=(prices[1]+prices[3])/2

        # ５点目と３点めは大きくずれている、トリプルにならない
        if abs(prices[3]-prices[5])/prices[5] < self.TOL:
            return

        # 0点目は上の線以上
        if prices[0] > line1_price:
            return
        # 4点目は上の線以上
        if prices[4] > line1_price:
            return

        # ラインの始点は０点目のX位置から、終点は6点目のX位置
        # line1 上線,line2 下線
        line1_stDate=dates[0]
        line1_stPrice=line1_price
        line1_edDate=dates[4]
        line1_edPrice=line1_stPrice
        line2_stDate=line1_stDate
        line2_stPrice=line2_price
        line2_edDate=line1_edDate
        line2_edPrice=line2_stPrice
        self.__write_to_db("replace into ptnDoubleBottom values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",(self.stockCode,self.zigzag,line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,dates[0],prices[0],dates[1],prices[1],dates[2],prices[2],dates[3],prices[3],dates[4],prices[4],self.ashi))
        return










    def __write_to_db(self, sql,tuple):
        print(sql)
        print(tuple)
        cursor = self.connection2.cursor()
        cursor.execute(sql, tuple)
        self.connection2.commit()
        cursor.close()



    def __get_prices(self, ohlc, pnts):
        prices = []
        dates = []
        for i in range(0, len(pnts)):

            # ピークは高値
            if ohlc[pnts[i]][self.PB_ADR] == 1:
                prices.append(ohlc[pnts[i]][2])
            # ボトムは安値
            else:
                prices.append(ohlc[pnts[i]][3])
            dates.append(ohlc[pnts[i]][6].strftime("%Y-%m-%d"))
        return (prices, dates)

    def __get_points(self, ohlc, i, num):
        if ohlc[i][self.PB_ADR] != 0:
            pnts = []
            pnts.append(i)
            for k in range(1, num):
                pnt = self.__get_point(ohlc, pnts[-1])
                if pnt is None:
                    return None
                pnts.append(pnt)
            return (pnts)
        return None

    def __get_point(self, ohlc, i):
        if i is None:
            return None

        for j in range(i + 1, len(ohlc)):
            if ohlc[j][self.PB_ADR] != 0:
                return (j)
        return (None)

    def __peakbottom(self, stockCode):
        cursor = self.connection.cursor()
        cursor.execute(
            "select date,oprice,high,low,cprice,volume from " + self.table + " where stockCode=%s and date>=%s and date<=%s",
            [stockCode, self.fromDate, self.toDate])
        result = cursor.fetchall()

        ohlc = []
        adr = 0
        for row in result:
            # no,open,high,low,close,volume,date,peakbottom
            ohlc.append([adr, row[1], row[2], row[3], row[4], row[5], row[0], 0, ])
            adr = adr + 1

        if len(ohlc) == 0:
            return None

        cursor.close()
        open = np.asarray(ohlc)[:, 1]
        high = np.asarray(ohlc)[:, 2]
        low = np.asarray(ohlc)[:, 3]
        close = np.asarray(ohlc)[:, 4]
        try:
            pivots = peak_valley_pivots(open, high, low, close, self.zigzag, -self.zigzag)
            adr = 0
            for p in pivots:
                ohlc[adr][self.PB_ADR] = p
                adr = adr + 1
            return (ohlc)
        except:
            print "peak_valley_pivots ERROR"
            return None

    def __interpolation(self, stx, edx, sty, edy, ohlc):
        close = np.asarray(ohlc)[:, 4]
        line = np.empty(len(close))
        line[:] = np.NAN
        b = (edy - sty) / (edx - stx)
        for x in range(stx, edx + 1):
            line[x] = b * (x - stx) + sty
        return (line)


class Calcurator:
    def __init__(self, fromDate, toDate, ashi, zigzag):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="")
        self.fromDate = fromDate
        self.toDate = toDate
        self.ashi = ashi
        self.table = "ST_priceHistAdj"
        if self.ashi == "m":
            self.table = "ST_priceHistMonthly"
        elif self.ashi == "w":
            self.table = "ST_priceHistWeekly"
        self.zigzag=zigzag

    def execute(self):
        cursor = self.connection.cursor()
        #cursor.execute(
        #    "select distinct stockCode from " + self.table + " where date>=%s and date<=%s  order by stockCode ",
        #    (self.fromDate, self.toDate))
        cursor.execute("select stockCode from live.stockMasterFull where nk225Flag='1' order by stockCode")
        stockCodes = cursor.fetchall()
        for stockCode in stockCodes:
            Pattern(stockCode[0], self.fromDate, self.toDate, self.zigzag, self.ashi, self.table).calc()

        cursor.close()
        self.connection.close()


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate = "2000-01-01"
    toDate = "2015-12-31"

    #Pattern("3103", fromDate, toDate, 0.1, "m", "ST_priceHistMonthly").calc()
    ashi = "w"
    Calcurator(fromDate, toDate, ashi, 0.04).execute()
    Calcurator(fromDate, toDate, ashi, 0.06).execute()
    Calcurator(fromDate, toDate, ashi, 0.08).execute()
    Calcurator(fromDate, toDate, ashi, 0.10).execute()
    Calcurator(fromDate, toDate, ashi, 0.12).execute()
    ashi = "m"
    Calcurator(fromDate, toDate, ashi,0.05).execute()
    Calcurator(fromDate, toDate, ashi,0.10).execute()
    Calcurator(fromDate, toDate, ashi,0.15).execute()
    Calcurator(fromDate, toDate, ashi,0.20).execute()
    Calcurator(fromDate, toDate, ashi,0.25).execute()
    ashi = "d"
    Calcurator(fromDate, toDate, ashi,0.01).execute()
    Calcurator(fromDate, toDate, ashi, 0.02).execute()
    Calcurator(fromDate, toDate, ashi, 0.03).execute()
    Calcurator(fromDate, toDate, ashi, 0.04).execute()
    Calcurator(fromDate, toDate, ashi, 0.05).execute()



