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

connector = MySQLdb.connect(host="live.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com", db="live", user="root", passwd="fintechlabo", charset="utf8")
UP_FLAG = "up"
DOWN_FLAG = "down"
def epcochToDatetime(epoch):
    return datetime.fromtimestamp(epoch)

def getWinningRate(stockCode, targetDate, targetPrice,rikaku,songiri,term):
    """7日後の日付"""
    #futureDay = datetime.fromtimestamp(hoge.mktime((targetDate.year, targetDate.month , targetDate.day + 7, 0, 0, 0, 0, 0, 0)))
    #sql = u"select oprice, high, low, cprice from ST_priceHistAdj where stockCode=%s and date > '%s' and date <= '%s'" % (stockCode, targetDate, futureDay)
    sql = u"select oprice, high, low, cprice from live.ST_priceHistAdj where stockCode='%s' and date > '%s' order by date asc limit %s" % (stockCode, targetDate, term)
    cursor = connector.cursor()
    cursor.execute(sql)
    fetchPrice =  map(lambda item: list(item), cursor.fetchall())
    if len(fetchPrice)!=term:
      return (None,None,None)

    winFlag = False
    kakuteiFlag = False
    for ohlc in fetchPrice:
        if(ohlc[1] > targetPrice * (1 + rikaku)):
            winFlag = True
            kakuteiFlag = True
            break
        if(ohlc[2] < targetPrice *( 1 - songiri)):
            winFlag = False
            kakuteiFlag = True
            break
    lastPrice = fetchPrice[len(fetchPrice) - 1][1]
    isWin = winFlag if(kakuteiFlag) else lastPrice - targetPrice > 0

    # calc std
    cp=numpy.array(map(lambda x:x[3],fetchPrice))
    volat=numpy.std((cp[1:term]-cp[0:term-1])/cp[0:term-1])
    return ((lastPrice - targetPrice) / targetPrice,volat, isWin)


def run(patternName, patternId, upDownFlag,rikaku,songiri,term, stockCode):
    #connector = cursor.cursor()
    cursor=connector.cursor()
    sql = u"select stockCode, signalTime, price,lineId from fintech.chartSignal where patternId=%s and upDownFlag = '%s' and stockCode='%s'" % (patternId, upDownFlag,stockCode)
    cursor.execute(sql)
    fetchData = cursor.fetchall()
    #connector.close()
    cursor.close()
    targetRateArray = []
    isWinArray = []
    totalNum = len(fetchData)
    for data in fetchData:
        targetRate, volat, winRate = getWinningRate(data[0], data[1], data[2],rikaku,songiri, term)
        if targetRate is None :
          continue
        x = connector.cursor()
        print "targetRate="+str(targetRate)+",volat="+str(volat)+",winRate="+str(winRate)
        x.execute("replace into fintech.chartSimulation values (%s,%s,%s,%s,%s,%s,%s,%s,%s)",(patternId,data[0],data[3],rikaku,songiri,term,upDownFlag,targetRate,volat))
        connector.commit()
        x.close()
        #connector.close()
        

        targetRateArray.append(targetRate)
        isWinArray.append(winRate)
    #価格がない場合
    if(len(targetRateArray) == 0):
        print "nai", patternId
        return
    x = connector.cursor()
    winRate = float(len(filter(lambda item: item == True, isWinArray)))/float(len(isWinArray))
    try:
        x.execute("replace INTO fintech.chartWinRate(patternId, winRate, targetRate, sigma, upDownFlag, total,stockCode) VALUES (%s, %s, %s, %s, %s, %s,%s)",
                  (patternId, winRate, numpy.mean(targetRateArray), numpy.std(targetRateArray), upDownFlag, totalNum,stockCode))
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
    if(argc == 8):
        run(argvs[1], int(argvs[2]), argvs[3], float(argvs[4]), float(argvs[5]) ,int(argvs[6]), argvs[7])
    #else:
    #  rikaku=0.05
    #  songiri=0.05
    #  term=5
    #  run("ascendingTriangle", 2, UP_FLAG,rikaku,songiri,term)
    #  run("ascendingTriangle", 2, DOWN_FLAG,rikaku,songiri,term)
    #  #ペナント型
    #  run("pennant", 3, UP_FLAG,rikaku,songiri)
    #  run("pennant", 3, DOWN_FLAG,rikaku,songiri)
    #  # #下降三角
    #  #run("descendingTriangle", 4, DOWN_FLAG)
    #  #長方形
    #  #run("box", 5, UP_FLAG)
    #  #run("box", 5, DOWN_FLAG)
    #  #チャネル・アップ
    #  #run("chanelUp", 6, UP_FLAG)
    #  #run("chanelUp", 6, DOWN_FLAG)
    #  #チャネル・ダウン
    #  #run("chanelDown", 7, UP_FLAG)
    #  #上昇エッジ
    #  #run("ascendingWedge", 9, UP_FLAG)
    #  #下降エッジ
    #  #run("descendingWedge", 10, DOWN_FLAG)
    #  #run("headAndShoulder", 11, DOWN_FLAG)
    # #run("headAndShoulderBottom", 12, UP_FLAG)
