#!/bin/env python
# coding:utf-8

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
    def __init__(self,stockCode):
        self.fromDate="2015-01-01"
        self.toDate="2015-03-31"
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")
        cursor=self.connection.cursor()
        cursor.execute("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode=%s and date>=%s limit 35 ",[stockCode,self.fromDate])
        result = cursor.fetchall()
        self.ohlc=[]
        for row in result:
            tmp = time.mktime(row[0].timetuple())
            self.ohlc.append((tmp, row[1], row[2], row[3], row[4], row[5]))  # unix time

    def show(self):
        ax = plt.subplot()
        candlestick_ohlc(ax,self.ohlc)
        plt.legend()
        plt.show()

    #http://qiita.com/ynakayama/items/6a472e5ebbe9365186bd
    def calc(self):
        # リターンインデックスを教師データを取り出す
        train_X, train_y = self.train_data()
        print train_X
        print train_y
        # 決定木のインスタンスを生成
        from sklearn import tree
        clf = tree.DecisionTreeClassifier()
        # 学習させる
        clf.fit(train_X, train_y)
        test_y = []
        arr = self.return_index()
        # 過去 30 日間のデータでテストをする
        for i in np.arange(0,15):
            s = i + 14
            # リターンインデックスのt全く同じ期間をテストとして分類させてみる
            test_X = arr[i:s].values
            # 結果を格納して返す
            result = clf.predict(test_X)
            test_y.append(result[0])
        print(train_y)  # 期待すべき答え
        # => [1 1 1 0 1 1 0 0 0 1 0 1 0 0 0]
        print(np.array(test_y))  # 分類器が出した予測
        # => [1 1 1 0 1 1 0 0 0 1 0 1 0 0 0]

    def train_data(self):
        arr=self.return_index()
        train_X = []
        train_y = []
        # 30 日間のデータを学習、 1 日ずつ後ろにずらしていく
        for i in np.arange(0,15):
            s = i + 14 # 14 日間の変化を素性にする
            feature = arr[i:s].values

            if feature[len(feature)-1] < arr[s]: # その翌日、株価は上がったか？
                train_y.append(1) # YES なら 1 を
            else:
                train_y.append(0) # NO なら 0 を
            train_X.append(feature)
        # 上げ下げの結果と教師データのセットを返す
        return np.array(train_X), np.array(train_y)

    def return_index(self):
        ohlc=np.asarray(self.ohlc)
        returns = pd.Series(ohlc[:,4]).pct_change()  # 騰落率を求める
        ret_index = (1 + returns).cumprod()  # 累積積を求める
        ret_index[0] = 1  # 最初の値を 1.0 にする
        return ret_index

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    dt=DecisionTree("6758")
    #print np.asarray(dt.ohlc)[:,4]
    #idx=dt.return_index()
    #print idx
    dt.calc()