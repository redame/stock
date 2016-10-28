# coding:utf-8

import MySQLdb
import numpy
import numpy, gzip, pickle

from datetime import *

class TrainData:
    connector = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="", charset="utf8")
    @classmethod
    def readData(cls, filepath):
        """
        MNSIT data set reader.
        returns (images, labels, length)
        """
        f = open(filepath, "r")

        result = [[], []]
        for row in f:
            arrayData = row.split("\t")
            priceStrDatas = arrayData[0].replace("[", "").replace("]", "")
            priceDatas = map(lambda n: float(n), priceStrDatas.split(","));
            result[0].append(TrainData.normalization(priceDatas))
            result[1].append(int(arrayData[1].replace("\n", "")))
        f.close()
        return (result[0],  result[1])
    @classmethod
    def readDataTwo(cls, filepath):
        """
        MNSIT data set reader.
        returns (images, labels, length)
        """
        f = open(filepath, "r")

        result = [[], []]
        for row in f:
            arrayData = row.split("\t")
            priceStrDatas = eval(arrayData[0])
            tempArray = []
            priceDatas = map(lambda n: n[1], priceStrDatas)
            for i in range(len(priceDatas)):
                tempArray.append((priceStrDatas[i][0], priceDatas[i]))
            result[0].append(tempArray)
            result[1].append(int(arrayData[1].replace("\n", "")))

        f.close()
        return (result[0],  result[1])
    @classmethod
    def readDataTwoThree(cls, filepath):
        """
        MNSIT data set reader.
        returns (images, labels, length)
        """
        f = open(filepath, "r")

        result = [[], []]
        for row in f:
            arrayData = row.split("\t")
            priceStrDatas = eval(arrayData[0])
            tempArray = []
            priceDatas = map(lambda n: n[1], priceStrDatas)
            for i in range(len(priceDatas)):
                tempArray.append((priceStrDatas[i][0], priceDatas[i]))
            result[0].append(tempArray)
            result[1].append(int(arrayData[1].replace("\n", "")))

        f.close()
        return result[0]

    @classmethod
    def createTrainData(cls, correctCodes, wrongCodes):
        result = []
        for correctCode in correctCodes:
            sql = u"select cprice from live.ST_priceHistAdj where stockCode=%s and date > DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)" %correctCode
            cursor = TrainData.connector.cursor()
            cursor.execute(sql)
            result.append([cursor.fetchall(), 1])
        for wrongcode in wrongCodes:
            sql = u"select cprice from live.ST_priceHistAdj where stockCode=%s and date > DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)" %wrongcode
            cursor = TrainData.connector.cursor()
            cursor.execute(sql)
            result.append([cursor.fetchall(), 0])

        train = map(lambda n: map(lambda m: m[0], n[0]), result)
        trainResult = map(lambda n: n[1], result)

        cursor.close()
        TrainData.writeText('train.txt', train, trainResult)

    @classmethod
    def createTestData(cls, exceptStockCode):
        testCodes = TrainData.getRandomCodes(exceptStockCode, 200)
        result = []
        for testCode in testCodes:
            sql = u"select cprice from live.ST_priceHistAdj where stockCode=%s and date > DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)" % testCode
            cursor = TrainData.connector.cursor()
            cursor.execute(sql)
            result.append([cursor.fetchall(), testCode])
        train = map(lambda n: map(lambda m: m[0], n[0]), result)
        trainResult = map(lambda n: n[1], result)

        TrainData.writeText('test.txt', TrainData.normalization(train), trainResult)

    @classmethod
    def createTestData2(cls, stockCode, startDate, endDate):
        sql = u"select cprice from live.ST_priceHistAdj where stockCode=%s and date between '%s' and '%s'" % (stockCode, startDate, endDate)
        cursor = TrainData.connector.cursor()
        cursor.execute(sql)
        return TrainData.normalization(map(lambda cprice: cprice[0], cursor.fetchall()))

    @classmethod
    def writeText(cls, filePath, train, result):
        f = open(filePath, 'w')
        lenData = len(train)
        for i in range(lenData):
            f.write(str(train[i])+"\t"+str(result[i])+"\n")
        f.close()

    @classmethod
    def getRandomCodes(cls, stockCodes, stockNum):
        sql = u"select stockCode from live.stockMasterFull where stockCode not in ("+",".join(map(str, stockCodes))+") order by rand() limit " +str(stockNum)+""
        cursor = TrainData.connector.cursor()
        cursor.execute(sql)

        randomCodes = map(lambda n: n[0], cursor.fetchall())

        return randomCodes

    @classmethod
    def getCodes(cls, stockNum):
        limitState = ""
        if(stockNum is not None):
            limitState = " order by rand() limit " +str(stockNum)
        sql = u"select stockCode from live.stockMasterFull" + limitState + " where nk225Flag='1'"
        cursor = TrainData.connector.cursor()
        cursor.execute(sql)

        randomCodes = map(lambda n: n[0], cursor.fetchall())

        return randomCodes
    @classmethod
    def to_formatted_array(cls, number):
        """
        3 -> (0,0,0,1,0,0,0,0,0,0)
        """
        ret = numpy.zeros(10)
        ret[number] = 1
        return ret

    @classmethod
    def normalization(cls, cpriceDatas):
        maxCprice = numpy.max(cpriceDatas)
        minCprice = numpy.min(cpriceDatas)
        if((maxCprice - minCprice) == 0):
            return map(lambda cprice: 0.5, cpriceDatas)
        else:
            return map(lambda cprice: (cprice - minCprice)/ (maxCprice - minCprice), cpriceDatas)
