#!/bin/env python
# coding:utf-8

# http://qiita.com/ynakayama/items/2efd2578fab73760c6e0



import sys
import MySQLdb

import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc
import talib as ta
import numpy as np
import time
import pandas as pd

# http://qiita.com/ynakayama/items/6a472e5ebbe9365186bd

class DecisionTree:
    def __init__(self):
        self.fromDate="2016-01-01"
        self.toDate="2016-03-31"
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")

    def calc(self):
        codes=self.get_codes()
        ohlcs=self.get_ohlcs(codes)
        idxes={}
        for code in codes:
            idxes[code]=self.return_index(np.asarray(ohlcs[code])[:,4])

    def get_codes(self):
        cursor=self.connection.cursor()
        cursor.execute("select stockCode from stockMasterFull where nk225Flag='1' ")
        result = cursor.fetchall()
        codes=[]
        for row in result:
            codes.append(row[0])
        return(codes)

    def get_ohlcs(self,codes):
        cursor=self.connection.cursor()
        ohlcs={}
        for code in codes:
            cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s and date<=%s ",[code,self.fromDate,self.toDate])
            result = cursor.fetchall()
            ohlc=[]
            for row in result:
                tmp = time.mktime(row[0].timetuple())
                ohlc.append((tmp, row[1], row[2], row[3], row[4], row[5]))  # unix time
            ohlcs[code]=ohlc
        return ohlcs

    def return_index(self,close):
        returns = pd.Series(close).pct_change()  # 騰落率を求める
        ret_index = (1 + returns).cumprod()  # 累積積を求める
        ret_index[0] = 1  # 最初の値を 1.0 にする
        return ret_index



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)