#!/bin/env python
# coding:utf-8

import sys
import json
import time as hoge
from datetime import datetime
import MySQLdb
import numpy
#from batch.src.TrainData import *

#rikaku = 0.05
#songiri = 0.05

connector = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="", charset="utf8")
UP_FLAG = "up"
DOWN_FLAG = "down"
def epcochToDatetime(epoch):
    return datetime.fromtimestamp(epoch)

def getWinningRate(stockCode, targetDate, targetPrice,rikaku,songiri,term):
    """7日後の日付"""
    #futureDay = datetime.fromtimestamp(hoge.mktime((targetDate.year, targetDate.month , targetDate.day + 7, 0, 0, 0, 0, 0, 0)))
    #sql = u"select oprice, high, low, cprice from ST_priceHistAdj where stockCode=%s and date > '%s' and date <= '%s'" % (stockCode, targetDate, futureDay)
    sql = u"select oprice, high, low, cprice from ST_priceHistAdj where stockCode=%s and date > '%s' order by date asc limit %s" % (stockCode, targetDate, term)
    cursor = connector.cursor()
    cursor.execute(sql)
    fetchPrice =  map(lambda item: list(item), cursor.fetchall())
    if len(fetchPrice)!=term:
      return (None,None,None)

    winFlag = False
    kakuteiFlag = False
    ret=None
    for ohlc in fetchPrice:
        if(ohlc[1] > targetPrice * (1 + rikaku)):
            winFlag = True
            kakuteiFlag = True
            ret=rikaku
            break
        if(ohlc[2] < targetPrice *( 1 - songiri)):
            winFlag = False
            kakuteiFlag = True
            ret=-songiri
            break
    lastPrice = fetchPrice[len(fetchPrice) - 1][1]
    isWin = winFlag if(kakuteiFlag) else lastPrice - targetPrice > 0

    # calc std
    cp=numpy.array(map(lambda x:x[3],fetchPrice))
    volat=numpy.std((cp[1:term]-cp[0:term-1])/cp[0:term-1])
    if ret is None:
        ret=(lastPrice - targetPrice) / targetPrice 
    return (ret,volat, isWin)


def run(patternName, patternId, upDownFlag,rikaku,songiri,term):
    cursor = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="", charset="utf8")
    connector = cursor.cursor()
    sql = u"select stockCode, signalTime, price,lineId from chartPatternSignal2 where patternId=%s and upDownFlag = '%s'" % (patternId, upDownFlag)
    connector.execute(sql)
    fetchData = connector.fetchall()
    connector.close()
    cursor.close()
    targetRateArray = []
    isWinArray = []
    totalNum = len(fetchData)
    for data in fetchData:
        targetRate, volat, winRate = getWinningRate(data[0], data[1], data[2],rikaku,songiri, term)
        if targetRate is None :
          continue

        connector = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="", charset="utf8")
        x = connector.cursor()
        x.execute("replace into chartSimulation values (%s,%s,%s,%s,%s,%s,%s,%s,%s)",(patternId,data[0],data[3],rikaku,songiri,term,upDownFlag,targetRate,volat))
        connector.commit()
        x.close()
        connector.close()
        

        targetRateArray.append(targetRate)
        isWinArray.append(winRate)
    #価格がない場合
    if(len(targetRateArray) == 0):
        print "nai", patternId
        return
    connector = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="", charset="utf8")
    x = connector.cursor()
    winRate = float(len(filter(lambda item: item == True, isWinArray)))/float(len(isWinArray))
    try:
        x.execute("DELETE FROM chartWinRate WHERE patternId = %s and upDownFlag = %s", (patternId, upDownFlag) )
        x.execute("INSERT INTO chartWinRate(patternId, winRate, targetRate, sigma, upDownFlag, total) VALUES (%s, %s, %s, %s, %s, %s)",
                  (patternId, winRate, numpy.mean(targetRateArray), numpy.std(targetRateArray), upDownFlag, totalNum))
        connector.commit()
    except ValueError:
        print("error!!", ValueError)
        x.rollback()
    x.close()
    connector.close()

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    print argvs
    if(argc == 4):
    #    run(argvs[1], argvs[2], argvs[3], argvs[4], argvs[5] ,argvs[6])
    #else:
      #rikaku=0.05
      #songiri=0.05
      #term=5
      rikaku=float(argvs[1])
      songiri=float(argvs[2])
      term=int(argvs[3])
      run("ascendingTriangle", 2, UP_FLAG,rikaku,songiri,term)
      run("ascendingTriangle", 2, DOWN_FLAG,rikaku,songiri,term)
      #ペナント型
      run("pennant", 3, UP_FLAG,rikaku,songiri,term)
      run("pennant", 3, DOWN_FLAG,rikaku,songiri,term)
      # #下降三角
      #run("descendingTriangle", 4, DOWN_FLAG)
      #長方形
      #run("box", 5, UP_FLAG)
      #run("box", 5, DOWN_FLAG)
      #チャネル・アップ
      #run("chanelUp", 6, UP_FLAG)
      #run("chanelUp", 6, DOWN_FLAG)
      #チャネル・ダウン
      #run("chanelDown", 7, UP_FLAG)
      #上昇エッジ
      #run("ascendingWedge", 9, UP_FLAG)
      #下降エッジ
      #run("descendingWedge", 10, DOWN_FLAG)

      #run("headAndShoulder", 11, DOWN_FLAG)
      #run("headAndShoulderBottom", 12, UP_FLAG)
