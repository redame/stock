# coding:utf-8
from TrainData import *
import time
from datetime import datetime
import sys
import json
from multiprocessing import Process, Queue, Pool

def createTestData(stockCode):
    result = {}
    sql = u"select date, oprice, high, low, cprice from ST_priceHistAdj where stockCode=%s and date>='2016-06-01' order by date desc " % stockCode
    #print sql
    connector = MySQLdb.connect(host="live.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com", db="live", user="root", passwd="fintechlabo", charset="utf8")
    cursor = connector.cursor()
    cursor.execute(sql)
    fetchData = cursor.fetchall()
    tempData = []
    print range(len(fetchData) - 1, 0, -1)
    for i in range(len(fetchData) - 1, 0, -1):
        data = fetchData[i]
        tempData.append( [int(time.mktime(data[0].timetuple())), data[1], data[2], data[3], data[4]] )
        result = tempData
    cursor.close()
    #print result
    return (stockCode, result)
if __name__ == "__main__":
    stockCode="6758"
    if(len(sys.argv) == 2):
        #stockNum = sys.argv[1]
        stockCode=sys.argv[1]
    #else:
    #    stockNum = None
    # createTestData(TrainData.getCodes(stockNum))
    #codes = TrainData.getCodes(None)
    # createTestData(TrainData.getCodes(300))
    #pool = Pool(1)
    #array = pool.map(createTestData, codes)
    #array = pool.map(createTestData, stockCode)
     
    inputData = {}
    #for code, hist in array:
    #    print code
    #    inputData[code] = hist
    (stockCode,array)=createTestData(stockCode)
    inputData[stockCode]=array
    fname="../data/StockPriceOHLC.txt."+stockCode
    f = open(fname, 'w')
    f.write(json.dumps(inputData))
    f.close()

    print "the end"
