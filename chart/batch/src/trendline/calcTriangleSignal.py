# coding:utf-8

#from batch.src.TrainData import *
#from batch.src.utils.lineUtils import *
#from fn import _
#from fn.op import zipwith
from itertools import repeat
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

class TrendLineCalculator:

    '''
    パターンの中にあるトレンドラインとポジションを識別する
    '''
    def calcPatternPosition(self, stockCode, resultRaw, upperLineSlopFn, lowerLineSlopFn, hasVertexX, isLatest):
        result = resultRaw

        fortyFiveLine = float(1) / float(len(result))
        patternDataObjects = []
        #rangeArray = range(len(result) - 1, len(result)) if isLatest else range(1, len(result))
        # add step , 
        rangeArray = range(len(result) - 1, len(result) , 10) if isLatest else range(1, len(result))

        for currentPos in rangeArray:
            peakPoses, bottomPoses = self.calcPeakBottomPoint(result[0: currentPos])
            filter_peak_poses = filter(lambda pos: pos < currentPos, peakPoses)
            filter_bottom_poses = filter(lambda pos: pos < currentPos, bottomPoses)
            #スタート地点の計算
            peakStartTerm = self.getTrendStartPosition(currentPos, filter_peak_poses)
            bottomStartTerm = self.getTrendStartPosition(currentPos, filter_bottom_poses)
            startTerm = min(peakStartTerm, bottomStartTerm)
            registLines = self.drawTrendLine(filter_peak_poses, result, True, startTerm, currentPos)
            supportLines = self.drawTrendLine(filter_bottom_poses, result, False, startTerm, currentPos)
            slopRegists = []
            """-----------------------------上のトレンドライン------------------------------------"""
            for line in filter(lambda hoge: self.isDrawLine(hoge, peakStartTerm, currentPos), registLines):
                slopNumber = self.getSlopNumber(line[0], line[1])
                if(upperLineSlopFn(slopNumber)):
                    slopRegists.append([line[0], line[1]])
            slopSupports = []
            """-----------------------------下のトレンドライン------------------------------------"""
            for line in filter(lambda hoge: self.isDrawLine(hoge, bottomStartTerm, currentPos), supportLines):
                supportNumber = self.getSlopNumber(line[0], line[1])
                if(lowerLineSlopFn(supportNumber)):
                    slopSupports.append([line[0], line[1]])
            """ここからは上下のトレンドラインがある場合にだけ選別する"""
            if(len(slopSupports) > 0 and len(slopRegists) > 0):
                regArray = slopRegists[0]
                supArray = slopSupports[0]
                #交点
                futureVertexX = self.getFutureVertex(patternDataObject.PosXY(regArray[0][0], regArray[1][0]), patternDataObject.PosXY(regArray[0][1], regArray[1][1]),
                                           patternDataObject.PosXY(supArray[0][0], supArray[1][0]), patternDataObject.PosXY(supArray[0][1], supArray[1][1]))
                narrowPosition = max(filter(lambda index: index <= regArray[0][1], range(len(result))))
                narrowPosition2 = max(filter(lambda index: index <= supArray[0][1], range(len(result))))
                #直近のやつだけ拾ってくる
                if((not hasVertexX or futureVertexX - 3 < currentPos) and (currentPos ==  narrowPosition or currentPos == narrowPosition2)):
                    minPos = supArray[0][0]
                    maxArray = regArray
                    minArray = supArray
                    """ここで長いトレンドラインに合わせる作業を行う"""
                    if(supArray[0][0] > regArray[0][0]):
                        minPos = regArray[0][0]
                        minArray = regArray
                        maxArray = supArray
                    maxArray[1][0] = self.getYPosition(maxArray, minPos)
                    maxArray[0][0] = minPos
                    upDownStr = self.getUpDownStr(result, regArray, supArray, currentPos)
                    patternDataObjects.append(patternDataObject.PatternDataObject(stockCode,
                                                                currentPos,
                                                                resultRaw[currentPos][0],
                                                                resultRaw[currentPos][4],
                                                                #ここでライン
                                                                lineUtils.Line(regArray[0][0], regArray[1][0], regArray[0][1], regArray[1][1],
                                                                     result[regArray[0][0]][0], result[regArray[0][1]][0],
                                                                     regArray[1][0], regArray[1][1]),
                                                                #ここでライン
                                                                lineUtils.Line(supArray[0][0], supArray[1][0], supArray[0][1], supArray[1][1],
                                                                    result[supArray[0][0]][0], result[supArray[0][1]][0],
                                                                    supArray[1][0], supArray[1][1]),
                                                                "penant", upDownStr))
        return patternDataObjects
    def getYPosition(self, lineArray, minPos):
        x1 = lineArray[0][0]
        x2 = lineArray[0][1]
        y1 = lineArray[1][0]
        y2 = lineArray[1][1]
        tyokwusenY = lambda x: ((y2 - y1) / (x2 - x1) )* x  + (y1* x2 - y2*x1)/ (x2 - x1)
        return tyokwusenY(minPos)
    """
    上抜け、下抜け、形成中の判定。
    """
    def getUpDownStr(self, ohlc, regArray, supArray, signalPosition):
        if(ohlc[signalPosition][2] > self.getYPosition(regArray, signalPosition)):
            return patternDataObject.UpDown.up
        elif(ohlc[signalPosition][3] < self.getYPosition(supArray, signalPosition)):
            return patternDataObject.UpDown.down
        else:
            return patternDataObject.UpDown.make

    """
    ピークボトムの座標からトレンドラインを伸ばします
   """
    def drawTrendLine(self, peakBottomPos, inputData, isPeak, startPos, currentPos):
        index = 2 if isPeak else 3
        maxTerm = 30
        peakArray = map(lambda n: [n, inputData[n][index]], peakBottomPos)
        filterFn =  lambda baseY ,i: (inputData[i][1] <= baseY and inputData[i][2] <= baseY and inputData[i][3] <= baseY and inputData[i][4] <= baseY) if isPeak else \
            (inputData[i][1] >= baseY and inputData[i][2] >= baseY and inputData[i][3] >= baseY and inputData[i][4] >= baseY)
        flatten=lambda i,d=-1:[a for b in i for a in(flatten(b,d-(d>0))if hasattr(b,'__iter__')and d else(b,))]
        """
        ピーク（or ボトム）の全通りの配列を生成
       """
        hoge = flatten(list((list(itertools.product([peakArray[i]], filter(lambda item:  peakArray[i][0] - maxTerm < item[0] and item[0] <  peakArray[i][0] + maxTerm, peakArray))) for i in range(len(peakArray)))), 1)
        arrayLen = len(inputData)
        ahoArray = []
        for ha in hoge:
            flag = True
            x1 = ha[0][0]
            x2 = ha[1][0]
            y1 = ha[0][1]
            y2 = ha[1][1]
            xMax = max(x1, x2)
            xMin = min(x1, x2)
            if(x1 < x2):
                tyokusenY = lambda x: ((y2 - y1) / (x2 - x1) )* x  + (y1* x2 - y2*x1)/ (x2 - x1)
                for i in range(xMin, xMax):
                    baseY = tyokusenY(i)
                    if(filterFn(baseY, i)):
                        flag = flag
                    else:
                        flag = False
                        break
                #スタートから下の奴は弾く
                if(flag and x1 != x2 and (startPos < x1 or startPos < x2)):
                    ahoArray.append(([x1, x2], [y1, y2]))
        res = []
        """
        ラインを伸ばす実装
       """
        for foo in ahoArray:
            x1 = foo[0][0]
            x2 = foo[0][1]
            y1 = foo[1][0]
            y2 = foo[1][1]
            xMax = max(x1, x2)
            xMin = min(x1, x2)
            rightFlg = x1 < x2
            tyokusenY = lambda x: ((y2 - y1) / (x2 - x1) )* x  + (y1* x2 - y2*x1)/ (x2 - x1)
            updateMin = xMin
            updateYEdge = y1 if rightFlg else y2
            updateMax = xMax
            updateLeftYEdge =  y2 if rightFlg else y1
            for i in range(xMin, startPos, -1):
                baseY = tyokusenY(i)
                updateMin = i
                updateYEdge = baseY
                if(filterFn(baseY, i)):
                    flag = flag
                else:
                    flag = False
                    break
            for j in range(xMax, currentPos + 1):
                baseY = tyokusenY(j)
                updateMax = j
                updateLeftYEdge = baseY
                if(filterFn(baseY, j)):
                    flag = flag
                else:
                    flag = False
                    break
            newX1 = updateMin if rightFlg else updateMax
            newX2 = updateMax if rightFlg else updateMin
            newY1 = updateYEdge if rightFlg else updateLeftYEdge
            newY2 = updateLeftYEdge if rightFlg else updateYEdge
            res.append(([newX1,  newX2], [newY1, newY2]))
        return res

    MINIMUM_TERM = 10
    """
    トレンドが始まる位置を取得する
    今の一からピークor ボトムが2ついないの位置から始める
   """
    def getTrendStartPosition(self, currentPos, peakOrBottomPoses):
        startTerm = currentPos
        peakCount = 0
        for i in range(currentPos - 1, -1, -1):
            if(len(filter(lambda pos: pos == i, peakOrBottomPoses)) == 1 and peakCount < 2):
                startTerm = i
                peakCount += 1
        return startTerm
    """
    現在位置とラインの描画の制御と関係
    """
    def isDrawLine(self, linePos, startTerm, currentPos):
        return (linePos[0][0] <= startTerm  and linePos[0][1] >= currentPos )
    """
    """
    def calcPeakBottomPoint(self, histData):
        peakPos = []
        bottomPos = []
        peakBottomPos = []
        #heightVector = list(map(_[2], histData))
        #lowVector = list(map(_[3], histData))
        # for python 2
        heightVector = map(lambda x:x[2],histData)
        lowVector = map(lambda x:x[3],histData)
        PEAK_BOTTOM_TERM = 5
        dataLength = len(histData)
        peakBottomTerm = PEAK_BOTTOM_TERM
        for i in range(dataLength):
            h = heightVector[i]
            l = lowVector[i]
            if (h == None or l == None ):
                continue
            p = True
            b = True
            for j in range(i - peakBottomTerm, i):
                if ((j >= 0) and (j < dataLength)):
                    h2 = heightVector[j]
                    l2 = lowVector[j]
                    if (h2 != None):
                        if (h2 > h):
                            p = False
                    if (l2 != None):
                        if (l2 < l):
                            b = False
                    if (not p and not b):
                        break
            if (not p and not b):
                continue
            for j in  range(i + 1, i + peakBottomTerm):
                if (j >= 0 and j < dataLength):
                    h3 = heightVector[j]
                    l3 = lowVector[j]
                    # //ピークの判定
                    if (h3 != None):
                        if (h3 >= h) :
                            p = False
                    # //ボトム判定
                    if (l3 != None):
                        if (l3 <= l):
                            b = False
                    if (not p and not b):
                        break
            # //ピークボトムが存在すれば登録する
            if (p or b):
                # //存在位置
                peakBottomPos.append(i)
                # //ピーク
                if (p):
                    peakPos.append(1)
                else:
                    peakPos.append(0)
                # //ボトム
                if (b):
                    bottomPos.append(1)
                else:
                    bottomPos.append(0)
        # //交互に登場させる
        if (len(peakPos) > 0):
            # if (False):
            while True:
                breaked = False
                p0 = (peakPos[0] == 1)
                for i in range(1, len(peakPos)):
                    p1 = (peakPos[i] == 1)
                    if (p0 == p1):
                        if (p1 and bottomPos[i] == 1):
                            peakPos[i] = 0
                            breaked = True
                            break
                        i0 = peakBottomPos[i - 1]
                        i1 = peakBottomPos[i]
                        v0 = lowVector[i0]
                        v1 = lowVector[i1]
                        if (p1):
                            v0 = heightVector[i0]
                            v1 = heightVector[i1]
                        if ((v0 < v1) == p1):
                            peakBottomPos = self.splice(peakBottomPos, i - 1, 1)
                            peakPos = self.splice(peakPos, i - 1, 1)
                            bottomPos = self.splice(bottomPos, i - 1, 1)
                        else:
                            peakBottomPos = self.splice(peakBottomPos, i, 1)
                            peakPos = self.splice(peakPos, i, 1)
                            bottomPos = self.splice(bottomPos, i, 1)
                        breaked = True
                        break
                    p0 = p1
                if (not breaked):
                    break
        # http://qiita.com/croissant1028/items/94c4b7fd360cfcdef0e4
        # for python2
        #tempFunc = lambda posArray, flagArray: filter(lambda pos: pos != len(histData) - 1, list(map(_[0], filter(_[1] == 1, zip(posArray, flagArray)))))
        tempFunc = lambda posArray, flagArray: filter(lambda pos: pos != len(histData) - 1, map(lambda x: x[0], filter(lambda y: y[1] == 1, zip(posArray, flagArray))))
        return tempFunc(peakBottomPos, peakPos), tempFunc(peakBottomPos, bottomPos)

    def splice(self, array, start, num):
        return array[0: start] + array[start + num: len(array)]

    """
    傾き取得
   """
    def getSlopNumber(self, pos1, pos2):
        return (pos2[0] - pos2[1]) / (pos1[0] - pos1[1])
    """
    将来交点
    """
    def getFutureVertex(self, pos1XYSt, pos1XYEnd, pos2XYSt, pos2XYEnd):
        line1Slop = self.getSlopNumber([pos1XYSt.xIndex, pos1XYEnd.xIndex], [pos1XYSt.yIndex, pos1XYEnd.yIndex])
        line2Slop = self.getSlopNumber([pos2XYSt.xIndex, pos2XYEnd.xIndex], [pos2XYSt.yIndex, pos2XYEnd.yIndex])
        seppen1 = pos1XYEnd.yIndex - line1Slop * pos1XYEnd.xIndex
        seppen2 = pos2XYEnd.yIndex - line2Slop * pos2XYEnd.xIndex
        if(line1Slop == line2Slop):
            return 0
        return (seppen2 - seppen1)/(line1Slop - line2Slop)

##
#データ・コンバータ
##
class DataConverter:
    def __init__(self, histData):
        self.histData = histData

    def normarization(self):
        # for python2
        #self.maxCprice = numpy.max(list(map(_[2], self.histData)))
        #self.minCprice = numpy.min(list(map(_[3], self.histData)))
        self.maxCprice = numpy.max(map(lambda x:x[2], self.histData))
        self.minCprice = numpy.min(map(lambda x:x[3], self.histData))
        if((self.maxCprice - self.minCprice) == 0):
            # return map(lambda cprice: 0.5, cpriceDatas)
            return map(lambda ohlc: [ohlc[0]] + [0.5, 0.5, 0.5, 0.5], self.histData)
        else:
            return map(lambda ohlc: [ohlc[0]] + map(lambda price: (price - self.minCprice)/ (self.maxCprice - self.minCprice), [ohlc[1], ohlc[2], ohlc[3], ohlc[4]]), self.histData)
    def denormarization(self, num):
        return num*(self.maxCprice - self.minCprice) + self.minCprice
