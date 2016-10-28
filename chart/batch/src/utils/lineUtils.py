# coding:utf-8
import itertools
import numpy
#from fn import _
from decimal import Decimal

class LineUtils:
    @classmethod
    def drawTrendEtcLine(cls, peakBottomPos, inputData, isPeak, startPos, currentPos, maxTerm):
        index = 2 if isPeak else 3
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
            newX1 = updateMin if rightFlg else updateMax
            newX2 = updateMax if rightFlg else updateMin
            newY1 = updateYEdge if rightFlg else updateLeftYEdge
            newY2 = updateLeftYEdge if rightFlg else updateYEdge
            res.append(Line(newX1, newY1, newX2, newY2, inputData[newX1][0], inputData[newX2][0], newY1, newY2))
        return res
    """
    ピークボトムの座標からトレンドラインを伸ばします
    """
    @classmethod
    def drawTrendLine(cls, peakBottomPos, inputData, isPeak, startPos, currentPos, maxTerm):
        index = 2 if isPeak else 3
        peakArray = map(lambda n: [n, inputData[n][index]], peakBottomPos)
        filterFn =  lambda baseY ,i: (inputData[i][1] <= baseY and inputData[i][2] <= baseY and inputData[i][3] <= baseY and inputData[i][4] <= baseY) if isPeak else \
            (inputData[i][1] >= baseY and inputData[i][2] >= baseY and inputData[i][3] >= baseY and inputData[i][4] >= baseY)
        flatten=lambda i,d=-1:[a for b in i for a in(flatten(b,d-(d>0))if hasattr(b,'__iter__')and d else(b,))]
        """
        ピーク（or ボトム）の全通りの配列を生成
       """
        hoge = flatten(list((list(itertools.product([peakArray[i]], filter(lambda item:  peakArray[i][0] - maxTerm < item[0] and item[0] <  peakArray[i][0] + maxTerm, peakArray))) for i in range(len(peakArray)))), 1)
        arrayLen = len(inputData)
        res = []
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
                for i in range(xMin + 1, xMax - 1):
                    baseY = tyokusenY(i)
                    if(filterFn(baseY, i)):
                        flag = flag
                    else:
                        flag = False
                        break
                #スタートから下の奴は弾く
                if(flag and x1 != x2 and (startPos < x1 or startPos < x2)):
                    res.append(Line(x1, y1, x2, y2, inputData[x1][0], inputData[x2][0], y1, y2))
        return res
    @classmethod
    def extendTrendLine(cls, lines, inputData, isPeak, startPos, currentPos):
        res = []
        """
        ラインを伸ばす実装
       """
        for line in lines:
            x1 = line.startX
            x2 = line.endX
            y1 = line.startY
            y2 = line.endY
            xMax = max(x1, x2)
            xMin = min(x1, x2)
            rightFlg = x1 < x2
            tyokusenY = lambda x: ((y2 - y1) / (x2 - x1) )* x  + (y1* x2 - y2*x1)/ (x2 - x1)
            updateMin = xMin
            updateYEdge = y1 if rightFlg else y2
            updateMax = xMax
            updateLeftYEdge =  y2 if rightFlg else y1
            for i in range(xMin - 1, startPos, -1):
                baseY = tyokusenY(i)
                updateMin = i
                updateYEdge = baseY
                if(not LineUtils.isCrossOhclLine(baseY, i, inputData, isPeak)):
                    break
            for j in range(xMax + 1, currentPos + 1):
                baseY = tyokusenY(j)
                updateMax = j
                updateLeftYEdge = baseY
                if(not LineUtils.isCrossOhclLine(baseY, j, inputData, isPeak)):
                    break
            newX1 = updateMin if rightFlg else updateMax
            newX2 = updateMax if rightFlg else updateMin
            newY1 = updateYEdge if rightFlg else updateLeftYEdge
            newY2 = updateLeftYEdge if rightFlg else updateYEdge
            res.append(Line(newX1, newY1, newX2, newY2, inputData[newX1][0], inputData[newX2][0], newY1, newY2))
        return res

    """
    ヒストリカルデータとラインがクロスするのか判定する
    """
    @classmethod
    def isCrossOhclLine(cls, baseY ,i, inputData, isPeak):
        return (inputData[i][1] <= baseY and inputData[i][2] <= baseY and inputData[i][3] <= baseY and inputData[i][4] <= baseY) if isPeak else (inputData[i][1] >= baseY and inputData[i][2] >= baseY and inputData[i][3] >= baseY and inputData[i][4] >= baseY)
    @classmethod
    def rangeSlopDef(cls, lowerSlop, upperSlop):
        return lambda inputSlop : (lowerSlop is None or lowerSlop <= inputSlop) and (upperSlop is None or inputSlop <= upperSlop)
    """
    ４本値とラインがクロスするかどうか
    """
    # @classmethod
    # def calcLineOHLCCross(cls, histData, line):
    #     filterFn =  lambda baseY ,i: (histData[i][1] <= baseY and histData[i][2] <= baseY and histData[i][3] <= baseY and histData[i][4] <= baseY) or\
    #                                  (histData[i][1] >= baseY and histData[i][2] >= baseY and histData[i][3] >= baseY and histData[i][4] >= baseY)


class Line:
    def __init__(self, startX, startY, endX, endY, startTime, endTime, startPriceY, endPriceY):
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
        self.startTime = startTime
        self.endTime = endTime
        self.startPriceY = startPriceY
        self.endPriceY = endPriceY
    """
    傾き取得
   """
    def getSlopNumber(self):
        return (self.endY - self.startY) / (self.endX - self.startX)

    def getYPoint(self, xIndex):
        return ((self.endY - self.startY) / (self.endX - self.startX) ) * xIndex  + (self.startY * self.endX - self.endY * self.startX)/ (self.endX - self.startX)
##
#データ・コンバータ
##
class DataConverter:
    def __init__(self, histData):
        self.histData = histData

    def normarization(self):
        self.maxCprice = numpy.max(list(map(_[2], self.histData)))
        self.minCprice = numpy.min(list(map(_[3], self.histData)))
        if((self.maxCprice - self.minCprice) == 0):
            # return map(lambda cprice: 0.5, cpriceDatas)
            return map(lambda ohlc: [ohlc[0]] + [0.5, 0.5, 0.5, 0.5], self.histData)
        else:
            return map(lambda ohlc: [ohlc[0]] + map(lambda price: (price - self.minCprice)/ (self.maxCprice - self.minCprice), [ohlc[1], ohlc[2], ohlc[3], ohlc[4]]), self.histData)
    def denormarization(self, num):
        return num*(self.maxCprice - self.minCprice) + self.minCprice
