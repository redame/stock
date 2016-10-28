#!/bin/env python
# coding:utf-8

# https://www.gaitameonline.com/academy_chart13.jsp
# ●第1、3、5波の上昇で第3波が一番短くなることはない。
# ●第1波の上昇を完全に打ち消すような第2波の下落はない。
# ●第4波の下落が第1波の波の頂点を下回ることはない。
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


# http://zaaf01d/trac/chart/svn/trunk/technicals/python/aroonIndicator.py
# http://qiita.com/ynakayama/items/897cc932008bd5c0e452
# http://tatabox.hatenablog.com/entry/2015/05/31/225133
class Elliott:
    def __init__(self, stockCode, fromDate, toDate, zigzag, ashi, table):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="")
        self.connection2 = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.fromDate = fromDate
        self.toDate = toDate
        self.zigzag_upper = zigzag
        self.zigzag_lower = -zigzag
        self.PB_ADR = 7  # address of peak bottom flag in ohlc
        self.stockCode = stockCode
        self.figure = 0
        self.ashi = ashi
        self.table = table
        print "(" + str(stockCode) + ")," + fromDate + " - " + toDate

    def calc(self):
        ohlc = self.__peakbottom(self.stockCode)
        if ohlc is None:
            return
        self.__calc_elliot(ohlc)

    def __calc_elliot(self, ohlc):
        for i in range(0, len(ohlc)):
            if ohlc[i][self.PB_ADR] != -1:  # start from bottom
                continue
            pnts = self.__get_elliot_points(ohlc, i)
            # print(pnts)
            if pnts is None:
                continue

            (prices, dates) = self.__get_prices(ohlc, pnts)
            lines = self.__check_elliot(ohlc, prices, pnts)
            if lines is not None:
                print prices
                # self.__draw_chart(ohlc,lines)
                self.__write_to_db(dates, prices)

    def __write_to_db(self, dates, prices):
        print self.stockCode + "," + str(self.zigzag_upper) + "," + dates[0] + "," + dates[8]
        cursor = self.connection2.cursor()
        cursor.execute(
            "replace into fintech.elliott values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (
            self.stockCode, self.zigzag_upper, dates[0], prices[0], dates[1], prices[1], dates[2], prices[2], dates[3],
            prices[3], dates[4], prices[4], dates[5], prices[5], dates[6], prices[6], dates[7], prices[7], dates[8],
            prices[8], self.ashi))
        self.connection2.commit()
        cursor.close()

    def __draw_chart(self, ohlc_full, lines_full):

        ## ちょうどいい感じの幅にする
        stx = 0
        edx = len(ohlc_full)
        for i in range(0, len(lines_full[0])):

            if (not np.isnan(lines_full[0][i])):
                stx = i
                break
        for i in range(len(lines_full[-1]) - 1, 0, -1):
            if (not np.isnan(lines_full[-1][i])):
                edx = i
                break

        MARGIN = 30
        if stx - MARGIN > 0:
            stx = stx - MARGIN
        if edx + MARGIN < len(ohlc_full):
            edx = edx + MARGIN
        ohlc = ohlc_full[stx:edx]
        for i in range(0, len(ohlc)):
            ohlc[i][0] = i
        lines = []
        for l in lines_full:
            lines.append(l[stx:edx])

        close = np.asarray(ohlc)[:, 4]
        step = int(len(ohlc) / 5)
        fdate = np.asarray(range(0, edx - stx))
        ddate = np.asarray(ohlc)[:, 6]

        plt.figure(self.figure)
        self.figure = self.figure + 1
        # graph上のfloat型の日付と、表示文字列を紐付けている
        plt.xticks(fdate[::step], [x.strftime('%Y-%m-%d') for x in ddate][::step])

        ax = plt.subplot()
        candlestick_ohlc(ax, ohlc)

        # trendline
        for line in lines:
            plt.plot(line)

        plt.xlabel('Date')
        plt.ylabel('Price')
        plt.title("title")
        # ax.legend().set_visible(False)
        plt.legend()
        # plt.show()
        filename = self.stockCode + "_" + str(ohlc[0][6].strftime('%Y-%m-%d')) + ".png"
        print(filename)
        plt.savefig("images/" + filename)

    def __check_elliot(self, ohlc, prices, pnts):
        # print prices
        # ●第1波の上昇を完全に打ち消すような第2波の下落はない。
        if not (prices[0] < prices[2] and prices[2] < prices[4]):
            return None
        if not (prices[1] < prices[3] and prices[3] < prices[5]):
            return None
        if not (prices[5] > prices[7]):
            return None
        if not (prices[6] > prices[8]):
            return None

        # ●第1、3、5波の上昇で第3波が一番短くなることはない。
        # 1点目と６点目でX、Y方向を標準化
        ydiff = prices[5] - prices[0]
        xdiff = pnts[5] - pnts[0]
        wave1 = ((prices[1] - prices[0]) / ydiff) ** 2 + ((pnts[1] - pnts[0]) / xdiff) ** 2
        wave3 = ((prices[3] - prices[2]) / ydiff) ** 2 + ((pnts[3] - pnts[2]) / xdiff) ** 2
        wave5 = ((prices[5] - prices[4]) / ydiff) ** 2 + ((pnts[5] - pnts[4]) / xdiff) ** 2
        if (wave1 > wave3 and wave5 > wave3):
            return None

        # ●第4波の下落が第1波の波の頂点を下回ることはない。
        if not (prices[4] > prices[1]):
            return None

        lines = []
        for i in range(0, 8):
            lines.append(self.__interpolation(pnts[i], pnts[i + 1], prices[i], prices[i + 1], ohlc))
        return (lines)

    def __get_prices(self, ohlc, pnts):
        prices = []
        dates = []
        for i in range(0, len(pnts)):
            if i % 2 == 1:  # oods = bottom
                prices.append(ohlc[pnts[i]][2])
            else:  # even = peak
                prices.append(ohlc[pnts[i]][3])
            dates.append(ohlc[pnts[i]][6].strftime("%Y-%m-%d"))
        return (prices, dates)

    def __get_elliot_points(self, ohlc, i):
        if ohlc[i][self.PB_ADR] != 0:
            pnts = []
            pnts.append(i)
            for k in range(1, 9):
                # print str(i)+","+str(k)
                pnt = self.__get_point(ohlc, pnts[-1])
                # print pnt
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
            pivots = peak_valley_pivots(open, high, low, close, self.zigzag_upper, self.zigzag_lower)
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
        cursor.execute(
            "select distinct stockCode from " + self.table + " where date>=%s and date<=%s  order by stockCode ",
            (self.fromDate, self.toDate))
        stockCodes = cursor.fetchall()
        for stockCode in stockCodes:
            for i in range(1, 21):
                zigzag = i * 0.01
                print stockCode[0] + "," + str(zigzag)
                Elliott(stockCode[0], self.fromDate, self.toDate, zigzag, self.ashi, self.table).calc()

        cursor.close()
        self.connection.close()


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate = "2000-01-01"
    toDate = "2015-12-31"
    ashi = "w"
    # Elliott("1347",fromDate,toDate,0.06,"w","ST_priceHistWeekly").calc()
    Calcurator(fromDate, toDate, ashi).execute()
    ashi = "m"
    Calcurator(fromDate, toDate, ashi).execute()
    ashi = "d"
    Calcurator(fromDate, toDate, ashi).execute()
