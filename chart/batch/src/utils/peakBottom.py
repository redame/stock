# coding:utf-8

#from fn import _
from arrayUtils import ArrayUtils

class PeakBottom:
    @classmethod
    def calc(cls, histData):
        peakPos = []
        bottomPos = []
        peakBottomPos = []
        heightVector = list(map(_[2], histData))
        lowVector = list(map(_[3], histData))
        PEAK_BOTTOM_TERM = 10
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
        #交互に登場させる
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
                            peakBottomPos = ArrayUtils.splice(peakBottomPos, i - 1, 1)
                            peakPos = ArrayUtils.splice(peakPos, i - 1, 1)
                            bottomPos = ArrayUtils.splice(bottomPos, i - 1, 1)
                        else:
                            peakBottomPos = ArrayUtils.splice(peakBottomPos, i, 1)
                            peakPos = ArrayUtils.splice(peakPos, i, 1)
                            bottomPos = ArrayUtils.splice(bottomPos, i, 1)
                        breaked = True
                        break
                    p0 = p1
                if (not breaked):
                    break
        tempFunc = lambda posArray, flagArray: filter(lambda pos: pos != len(histData) - 1, list(map(_[0], filter(_[1] == 1, zip(posArray, flagArray)))))
        return tempFunc(peakBottomPos, peakPos), tempFunc(peakBottomPos, bottomPos)
