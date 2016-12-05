# coding:utf-8
from TrainData import *
import time
from datetime import datetime
import sys
import json
from multiprocessing import Process, Queue, Pool

def createTestData(stockCode):
    result = {}
    sql = u"select date, oprice, high, low, cprice from ST_priceHistAdj where stockCode=%s order by date desc " % stockCode
    connector = MySQLdb.connect(host="zaaa16d.qr.com", db="live", user="root", passwd="", charset="utf8")
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
    return (stockCode, result)
if __name__ == "__main__":
    if(len(sys.argv) == 2):
        stockNum = sys.argv[1]
    else:
        stockNum = None
    # createTestData(TrainData.getCodes(stockNum))
    codes = TrainData.getCodes(None)
    # createTestData(TrainData.getCodes(300))
    pool = Pool(8)
    array = pool.map(createTestData, codes)
    inputData = {}
    for code, hist in array:
        print code
        inputData[code] = hist
    f = open('../../data/StockPriceOHLC.txt', 'w')
    f.write(json.dumps(inputData))
    f.close()

    print "the end"
