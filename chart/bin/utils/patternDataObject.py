# coding:utf-8

class PatternDataObject:
    def __init__(self, code, identifyPos, identifyTime, price, upperLine, downLine, patternId, upDown):
        self.code = code
        self.identifyPos = identifyPos
        self.identifyTime = identifyTime
        self.price = price
        self.upperLine = upperLine
        self.downLine = downLine
        self.patternId = patternId
        self.upDown = upDown
class UpDown:
    up = "up"
    down = "down"
    make = "make"


class Line2:
    def __init__(self, start, end):
        self.start = start
        self.end = end

class Position:
    ##
    #priceは高値か安値の奴。
    ##
   def __init__(self, unixTime, price, xIndex, yIndex):
       self.unixTime = unixTime
       self.price = price
       self.xIndex = xIndex
       self.yIndex = yIndex

class PosXY:
    def __init__(self, xIndex, yIndex):
        self.xIndex = xIndex
        self.yIndex = yIndex
