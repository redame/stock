# coding:utf-8


#from batch.src.TrainData import *
from itertools import repeat
import pylab as plt
import json
import itertools
#from itertools import *
#from batch.src.patternDataObject import *
#from calcTriangleSignal import *
from multiprocessing import Process, Queue, Pool
#from headAndShoulder import *
import time
import sys
import os
from functools import partial
import MySQLdb
from datetime import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../utils')
import zigzag
import lineUtils
import arrayUtils
import peakBottom

import calcTriangleSignal
import headAndShoulder

flag_win32 = False
try:
    os.uname()
except AttributeError:
    flag_win32 = True
rangeSlopDef = lambda lowerSlop, upperSlop : lambda inputSlop : (lowerSlop is None or lowerSlop <= inputSlop) and (upperSlop is None or inputSlop <= upperSlop)
def epcochToDatetime(epoch):
    return datetime.fromtimestamp(epoch)
def calcExe(stockCode, priceData, patternId, hasVertexX, isLatest):
    penant = calcTriangleSignal.TrendLineCalculator()
    processedData = priceData
    #1年でそう見える様に分母を20 * 10 としてみる
    fortyFiveLine = float(1) / 200
    precision = fortyFiveLine / 10
    if(patternId == 3):
        """pennant"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData, rangeSlopDef(None, -fortyFiveLine), rangeSlopDef(fortyFiveLine, None), hasVertexX, isLatest))
    elif(patternId == 2):
        """ascendingTrinangle"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData, rangeSlopDef(-fortyFiveLine/5, 0), rangeSlopDef(fortyFiveLine, None), hasVertexX, isLatest))
    elif(patternId == 4):
        """descendingTrinangle"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData, rangeSlopDef(None, -fortyFiveLine), rangeSlopDef(0, fortyFiveLine/5), hasVertexX, isLatest))
    elif(patternId == 5):
        """box"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData, rangeSlopDef(-precision, precision), rangeSlopDef(-precision, precision), hasVertexX, isLatest))
    elif(patternId == 6):
        """chanelUp"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData,
                                                          rangeSlopDef(fortyFiveLine - precision, fortyFiveLine + precision),
                                                          rangeSlopDef(fortyFiveLine - precision,  fortyFiveLine + precision),
                                                          hasVertexX,
                                                          isLatest))
    elif(patternId == 7):
        """chanelDown"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData,
                                                          rangeSlopDef(-fortyFiveLine - precision, -fortyFiveLine + precision),
                                                          rangeSlopDef(-fortyFiveLine - precision, -fortyFiveLine + precision),
                                                          hasVertexX,
                                                          isLatest))
    elif(patternId == 9):
        """ascendingWedge"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData,
                                                          rangeSlopDef(fortyFiveLine/5, fortyFiveLine),
                                                          rangeSlopDef(fortyFiveLine, None),
                                                          False,
                                                          isLatest))
    elif(patternId == 10):
        """descendingWedge"""
        return (processedData, penant.calcPatternPosition(stockCode, processedData,
                                                          rangeSlopDef(None, -fortyFiveLine),
                                                          rangeSlopDef(-fortyFiveLine, -fortyFiveLine/5 - precision),
                                                          hasVertexX,
                                                          isLatest))
    elif(patternId == 11):
        """headAndShoulder"""
        calculator = headAndShoulder.HeadAndShoulder()
        return (processedData, calculator.calcPatternPosition(stockCode, processedData))
    elif(patternId == 12):
        """headAndShoulder"""
        calculator = headAndShoulder.HeadAndShoulder()
        return (processedData, calculator.IcalcPatternPosition(stockCode, processedData))

def plotChart(resultObj, patternName, stockPriceDataObj):
    print resultObj[0].identifyPos
    for patternData in resultObj:
        processedData = stockPriceDataObj[patternData.code]
        plt.boxplot(map(lambda res: (res[1], res[2], res[3], res[4]), processedData))
        plt.plot([patternData.upperLine.startX + 1, patternData.upperLine.endX + 1], [patternData.upperLine.startPriceY, patternData.upperLine.endPriceY])
        plt.plot([patternData.downLine.startX + 1, patternData.downLine.endX + 1], [patternData.downLine.startPriceY, patternData.downLine.endPriceY])
        plt.axvline(x = patternData.identifyPos + 1, color='red')
        plt.savefig("../demoImg/%s/%s" % (patternName, patternData.code))
        plt.clf()


def run(patternName, patternId, hasVertexX, isLatest):
    f = open("../../../data/StockPriceOHLC.txt", "r")
    resultRaw = []
    priceStrDatas = {}
    for row in f:
        priceStrDatas = json.loads(row)
    f.close()
    jobs = []



#    tempObj = []
#    counter = 0
#    for stockCode, priceData in priceStrDatas.items():
#        processedData, patternDataObjects =calcExe(stockCode, priceData, patternId, hasVertexX, isLatest)
#        print patternDataObjects
#        if(len(patternDataObjects) > 0):
#            counter += 1
#            stockCode = patternDataObjects[0].code
#            print stockCode
#            tempObj.append(patternDataObjects)


    pool = Pool(processes=4)
    start = time.time()
    for stockCode, priceData in priceStrDatas.items():
        jobs.append(pool.apply_async(calcExe, [stockCode, priceData, patternId, hasVertexX, isLatest]))
    tempObj = []
    counter = 0
    for k in jobs:
        processedData, patternDataObjects = k.get()
        print patternDataObjects
        if(len(patternDataObjects) > 0):
            counter += 1
            stockCode = patternDataObjects[0].code
            print stockCode
            tempObj.append(patternDataObjects)
            """描画はライブラリの関係上windowsの時のみとする"""
        if(flag_win32):
            if(counter > 10):
                break
    flatten=lambda i,d=-1:[a for b in i for a in(flatten(b,d-(d>0))if hasattr(b,'__iter__')and d else(b,))]
    elapsed_time = time.time() - start
    connector = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="", charset="utf8")
    x = connector.cursor()
    tempObj = flatten(tempObj)

    if(flag_win32 and len(tempObj) > 0):
        plotChart(tempObj, patternName, priceStrDatas)
    try:
       x.execute("DELETE FROM chartPatternSignal2 where patternId = %s", (patternId,))
       for temp in tempObj:
           lineID = "%s_%s_%s" %(patternId, temp.code, temp.identifyTime)
           x.execute("DELETE FROM chartPatternLines2 where lineID = %s", (lineID,))
           x.execute("INSERT INTO chartPatternSignal2(patternId, stockCode, signalTime, price, lineID, upDownFlag) VALUES (%s, %s, %s, %s, %s, %s)",
                     (patternId, temp.code, epcochToDatetime(temp.identifyTime), temp.price, lineID, temp.upDown))
           x.execute("INSERT INTO chartPatternLines2(lineID, startTime, startPrice, endTime, endPrice) VALUES (%s, %s, %s, %s, %s)",
                     (lineID, epcochToDatetime(temp.upperLine.startTime), temp.upperLine.startPriceY, epcochToDatetime(temp.upperLine.endTime), temp.upperLine.endPriceY))
           x.execute("INSERT INTO chartPatternLines2(lineID, startTime, startPrice, endTime, endPrice) VALUES (%s, %s, %s, %s, %s)",
                     (lineID, epcochToDatetime(temp.downLine.startTime), temp.downLine.startPriceY, epcochToDatetime(temp.downLine.endTime), temp.downLine.endPriceY))
       connector.commit()
    except ValueError:
       print("error!!", ValueError)
       connector.rollback()
    connector.close()
    print ("elapsed_time:{0}".format(elapsed_time)) + "[sec]"
    pool.close()
    pool.terminate()
    print "the end"

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    print argvs
    if(argc == 4):
        run(argvs[1], argvs[2], argvs[3], argvs[4])
    else:
        run("ascendingTriangle", 2, True, False)
        # ペナント型
        run("pennant", 3, True, False)
        # #下降三角
        run("descendingTriangle", 4, True, False)
        # #長方形
        run("box", 5, False, False)
        # #チャネル・アップ
        run("chanelUp", 6, False, False)
        # #チャネル・ダウン
        run("chanelDown", 7, False, False)
        # #上昇エッジ
        run("ascendingWedge", 9, True, False)
        # #下降エッジ
        run("descendingWedge", 10, True, False)
        # ヘッドアンドショルダー
        run("headAndShoulder", 11, None, None)
        # ヘッドアンドショルダー・ボトム
        run("headAndShoulderBottom", 12, None, None)
    quit()
    print "ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!"
