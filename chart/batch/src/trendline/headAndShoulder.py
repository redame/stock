# coding:utf-8

#from batch.src.TrainData import *
#from fn import _
#from fn.op import zipwith
from itertools import repeat
import json
import math
import pylab as plt
import itertools
import numpy

import sys,os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../utils')
import zigzag
import lineUtils
import arrayUtils
import peakBottom
import patternDataObject
#from itertools import *
#from batch.src.patternDataObject import *
#from batch.src.utils.peakBottom import *
#from batch.src.utils.zigzag import *
#from batch.src.utils.lineUtils import *
#from batch.src.patternDataObject import *

class HeadAndShoulder:
    def calcPatternPosition(self, stockCode, processedData):
        patternDataObjects = []

        open = numpy.array(map(lambda item: item[1], processedData))
        high = numpy.array(map(lambda item: item[2], processedData))
        low = numpy.array(map(lambda item: item[3], processedData))
        close = numpy.array(map(lambda item: item[4], processedData))
        #ジグザグの座標を取得
        pivots = zigzag.peak_valley_pivots2(open, high, low, close, 0.05, -0.05)

        pivotPeakPoses = numpy.arange(len(processedData))[pivots == 1]
        pivotBottomPoses = numpy.arange(len(processedData))[pivots == -1]

        for currentPos in range(len(processedData)):
            peakPoses = filter(lambda p: p < currentPos, pivotPeakPoses)
            bottomPoses = filter(lambda p: p < currentPos, pivotBottomPoses)
            peakBottomPosFlag = True
            extreme1 = 0
            extreme2 = 0
            extreme3 = 0
            extreme4 = 0
            extreme5 = 0
            extreme1X = 0
            extreme2X = 0
            extreme3X = 0
            extreme4X = 0
            extreme5X = 0
            if(len(peakPoses) > 2 and len(bottomPoses) > 2):
                if(peakPoses[-1] > bottomPoses[-1]):
                    extreme1X = peakPoses[-1]
                    extreme1 = high[extreme1X]
                    extreme2X = bottomPoses[-1]
                    extreme2 = low[extreme2X]
                    extreme3X = peakPoses[-2]
                    extreme3 = high[extreme3X]
                    extreme4X = bottomPoses[-2]
                    extreme4 = low[extreme4X]
                    extreme5X = peakPoses[-3]
                    extreme5 = high[extreme5X]
                else:
                    peakBottomPosFlag = False
                if(peakBottomPosFlag):
                    extremArray = numpy.array([extreme1, extreme2, extreme3, extreme4, extreme5])
                    withinMean = numpy.mean(extremArray)
                    trendLineRange = numpy.mean([extreme1, extreme5]) - numpy.mean([extreme2, extreme4])
                    peakLineMax = max([extreme1, extreme5])
                #各頂点の位置での判定
                if(extreme3 > extreme5 and
                           extreme3 > extreme1 and
                               math.fabs(extreme5 - extreme1)/ withinMean < 0.015 and
                               math.fabs(extreme4 - extreme2) / withinMean < 0.015 and
                               extreme3 - peakLineMax > trendLineRange * 0.5
                   ):
                    bottomLine = lineUtils.Line(extreme4X, extreme4, extreme2X, extreme2, processedData[extreme4X][0], processedData[extreme2X][0], extreme4, extreme2)
                    #伸ばす
                    bottomLine = lineUtils.LineUtils.extendTrendLine([bottomLine], processedData, False, 0, currentPos)[0]
                    #ピーク
                    peakLine = lineUtils.Line(extreme5X, extreme5, extreme1X, extreme1, processedData[extreme5X][0], processedData[extreme1X][0], extreme5, extreme1)
                    upperFlag = isTwiceUpLine(extreme3X, peakLine, processedData, 1) and isTwiceUpLine(extreme3X, peakLine, processedData, -1)
                    #ボトムの値が上のラインより上にいかない事を確認
                    for pos in range(currentPos, peakLine.endX, -1):
                        if(processedData[pos][2] > peakLine.endPriceY):
                            upperFlag = False
                            break
                    #まぁこちらも
                    for pos in range(bottomLine.startX, peakLine.startX):
                        if(processedData[pos][2] > peakLine.startPriceY):
                            upperFlag = False
                            break
                    if(upperFlag and currentPos <= bottomLine.endX and processedData[currentPos][3] < bottomLine.getYPoint(currentPos)):
                        patternDataObjects.append(patternDataObject.PatternDataObject(stockCode,
                                                                     currentPos,
                                                                     processedData[currentPos][0],
                                                                     processedData[currentPos][4],
                                                                     bottomLine,
                                                                     peakLine,
                                                                     "", "down"))
        return patternDataObjects
    """
   """
    def IcalcPatternPosition(self, stockCode, processedData):
        patternDataObjects = []

        open = numpy.array(map(lambda item: item[1], processedData))
        high = numpy.array(map(lambda item: item[2], processedData))
        low = numpy.array(map(lambda item: item[3], processedData))
        close = numpy.array(map(lambda item: item[4], processedData))
        #ジグザグの座標を取得
        pivots = zigzag.peak_valley_pivots2(open, high, low, close, 0.05, -0.05)


        pivotPeakPoses = numpy.arange(len(processedData))[pivots == 1]
        pivotBottomPoses = numpy.arange(len(processedData))[pivots == -1]

        for currentPos in range(len(processedData)):
            peakPoses = filter(lambda p: p < currentPos, pivotPeakPoses)
            bottomPoses = filter(lambda p: p < currentPos, pivotBottomPoses)
            peakBottomPosFlag = True
            extreme1 = 0
            extreme2 = 0
            extreme3 = 0
            extreme4 = 0
            extreme5 = 0
            extreme1X = 0
            extreme2X = 0
            extreme3X = 0
            extreme4X = 0
            extreme5X = 0
            if(len(peakPoses) > 2 and len(bottomPoses) > 2):
                if(peakPoses[-1] < bottomPoses[-1]):
                    extreme1X = bottomPoses[-1]
                    extreme1 = low[extreme1X]
                    extreme2X = peakPoses[-1]
                    extreme2 = high[extreme2X]
                    extreme3X = bottomPoses[-2]
                    extreme3 = low[extreme3X]
                    extreme4X = peakPoses[-2]
                    extreme4 = high[extreme4X]
                    extreme5X = bottomPoses[-3]
                    extreme5 = low[extreme5X]
                else:
                    peakBottomPosFlag = False
                trendLineRange = 0
                peakLineMax = 0
                if(peakBottomPosFlag):
                    extremArray = numpy.array([extreme1, extreme2, extreme3, extreme4, extreme5])
                    withinMean = numpy.mean(extremArray)
                    trendLineRange = numpy.mean([extreme1, extreme5]) - numpy.mean([extreme2, extreme4])
                    peakLineMax = max([extreme1, extreme5])
                #各頂点の位置での判定
                if(extreme3 < extreme1 and
                           extreme3 < extreme5 and
                               math.fabs(extreme5 - extreme1)/ withinMean < 0.015 and
                               math.fabs(extreme4 - extreme2) / withinMean < 0.015 and
                               math.fabs(extreme3 - peakLineMax) > math.fabs(trendLineRange * 0.5)
                   ):
                    bottomLine = lineUtils.Line(extreme5X, extreme5, extreme1X, extreme1, processedData[extreme5X][0], processedData[extreme1X][0], extreme5, extreme1)
                    #ピーク
                    peakLine = lineUtils.Line(extreme4X, extreme4, extreme2X, extreme2, processedData[extreme4X][0], processedData[extreme2X][0], extreme4, extreme2)
                    #伸ばす
                    peakLine = lineUtils.LineUtils.extendTrendLine([peakLine], processedData, True, 0, currentPos)[0]
                    upperFlag = isTwiceDownLine(extreme3X, bottomLine, processedData, 1) and isTwiceDownLine(extreme3X, bottomLine, processedData, -1)
                    if(upperFlag and currentPos <= peakLine.endX):
                        patternDataObjects.append(patternDataObject.PatternDataObject(stockCode,
                                                                    currentPos,
                                                                    processedData[currentPos][0],
                                                                    processedData[currentPos][4],
                                                                    bottomLine,
                                                                    peakLine,
                                                                    "", "down"))
        return patternDataObjects

def isTwiceUpLine(topX, line, processedData, d):
    resFlag = True
    tempPos = topX
    tempFlag = False
    directionList = range(topX, line.endX) if d == 1 else range(topX, line.startX, -1)
    #２回上限のトレンドラインを超えない
    for peakPos in directionList:
        #高値が一度トップラインから沈む時
        if(processedData[peakPos][3] < line.getYPoint(peakPos)):
            tempPos = peakPos
            tempFlag = True
            break
    if(tempFlag):
        directionList = range(tempPos, line.endX) if d == 1 else range(tempPos, line.startX, -1)
        #２回上限のトレンドラインを超えない
        for peakPos in directionList:
            #高値が一度トップラインから沈む時
            if(processedData[peakPos][3] > line.getYPoint(peakPos)):
                resFlag = False
                break
    return resFlag
def isTwiceDownLine(topX, line, processedData, d):
    resFlag = True
    tempPos = topX
    tempFlag = False
    directionList = range(topX, line.endX) if d == 1 else range(topX, line.startX, -1)
    #２回上限のトレンドラインを超えない
    for peakPos in directionList:
        #高値が一度トップラインから上がる時
        if(processedData[peakPos][2] > line.getYPoint(peakPos)):
            tempPos = peakPos
            tempFlag = True
            break
    if(tempFlag):
        directionList = range(tempPos, line.endX) if d == 1 else range(tempPos, line.startX, -1)
        #２回上限のトレンドラインを超えない
        for peakPos in directionList:
            #高値が一度トップラインから沈む時
            if(processedData[peakPos][2] < line.getYPoint(peakPos)):
                resFlag = False
                break
    return resFlag

def trimSamePointLine(patternDataObjects):
    res = []
    for item in patternDataObjects:
        extractDataObject = item
        upperSameLine = filter(lambda line: line.upperLine.endX == line.upperLine.endX, patternDataObjects)
        if(len(upperSameLine)):
            mostLatestStart = max(map(lambda line: line.upperLine.startX, upperSameLine))
            for removeObj in filter(lambda obj: obj.upperLine.startX != mostLatestStart, patternDataObjects):
                patternDataObjects.remove(removeObj)
            extractDataObject = filter(lambda obj: obj.upperLine.startX == mostLatestStart, patternDataObjects)[0]
        res.append(extractDataObject)
    return res

if __name__ == "__main__":
    calculator = HeadAndShoulder()
    f = open("../toDayPrice/StockPriceOHLC.txt", "r")
    for row in f:
        priceStrDatas = json.loads(row)
    f.close()
    count = 0
    for stockCode, priceData in priceStrDatas.items():
        count += 1
        processedData = priceData
        patternDataObjects = calculator.IcalcPatternPosition(stockCode, processedData)
        plt.boxplot(map(lambda res: (res[1], res[2], res[3], res[4]), processedData))
        for patternData in patternDataObjects:
            plt.plot([patternData.upperLine.startX, patternData.upperLine.endX], [patternData.upperLine.startY, patternData.upperLine.endY])
            plt.plot([patternData.downLine.startX, patternData.downLine.endX], [patternData.downLine.startY, patternData.downLine.endY])
            plt.axvline(x = patternData.identifyPos + 1, color='red')
        plt.savefig("hogehoge-%s.png" % stockCode)
        plt.clf()
