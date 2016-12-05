#!/bin/env python
# coding:utf-8

import MySQLdb
import sys
import numpy as np


class PatternResult:
    def __init__(self, ashi):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.ashi = ashi

    def __calc_avgstd(self, range):
        avg = None
        std = None
        if len(range) > 0:
            avg = np.average(np.array(range))
            std = np.std(np.array(range))
        return (avg, std)

    # check line1 edprice and price_post
    def __calc_result_upline(self, ptnTable, line_edPrice):
        cursor = self.connection.cursor()
        cursor.execute("select "+line_edPrice+",price_post,price_to from " + ptnTable + " where  ashi=%s   and price_post is not null",
                       (self.ashi,))
        data = cursor.fetchall()
        upCount = 0
        downCount = 0
        upRange = []  # when upcase, up range from price_to to price_post
        downRange = []
        for item in data:
            line_edPrice = item[0]
            price_post = item[1]
            price_to = item[2]
            if line_edPrice < price_post:
                upCount = upCount + 1
                upRange.append((price_post - price_to) / price_to)
            else:
                downCount = downCount + 1
                downRange.append((price_post - price_to) / price_to)

        (upAvg, upStd) = self.__calc_avgstd(upRange)
        (downAvg, downStd) = self.__calc_avgstd(downRange)

        cursor.execute("replace into ptnNowPBResult values (%s,%s,%s,%s,%s,%s,%s,%s)",
                       (ptnTable, self.ashi, upCount, downCount, upAvg, upStd, downAvg, downStd))
        self.connection.commit()
        print(cursor._last_executed)

    # check line2 edprice and price_post
    def __calc_result_downline(self, ptnTable, line_edPrice):
        cursor = self.connection.cursor()
        cursor.execute(
            "select "+line_edPrice+",price_post,price_to from " + ptnTable + " where ashi=%s and price_post is not null",
            ( self.ashi,))
        data = cursor.fetchall()
        upCount = 0
        downCount = 0
        upRange = []  # when upcase, up range from price_to to price_post
        downRange = []
        for item in data:
            line_edPrice = item[0]
            price_post = item[1]
            price_to = item[2]
            if line_edPrice > price_post:
                downCount = downCount + 1
                downRange.append((price_post - price_to) / price_to)
            else:
                upCount = upCount + 1
                upRange.append((price_post - price_to) / price_to)

        (upAvg, upStd) = self.__calc_avgstd(upRange)
        (downAvg, downStd) = self.__calc_avgstd(downRange)

        cursor.execute("replace into ptnNowPBResult values (%s,%s,%s,%s,%s,%s,%s,%s)",
                       (ptnTable, self.ashi, downCount, upCount, downAvg, downStd, upAvg, upStd))
        self.connection.commit()
        print(cursor._last_executed)

    def execute(self):
        self.__calc_result_upline( "ptnPBRisingTriangle", "line1_edPrice")
        self.__calc_result_upline( "ptnPBFallingWedge", "line1_edPrice")
        self.__calc_result_upline( "ptnPBDoubleBottom", "line1_edPrice")
        self.__calc_result_upline( "ptnPBTripleBottom", "line1_edPrice")
        self.__calc_result_upline( "ptnPBDownChannel", "line1_edPrice")

        self.__calc_result_downline( "ptnPBTripleTop", "line2_edPrice")
        self.__calc_result_downline( "ptnPBFallingTriangle", "line2_edPrice")
        self.__calc_result_downline( "ptnPBUpChannel", "line2_edPrice")
        self.__calc_result_downline( "ptnPBDoubleTop", "line2_edPrice")
        self.__calc_result_downline( "ptnPBRisingWedge", "line2_edPrice")

        self.__calc_result_upline( "ptnPBHeadAndShoulderTop", "line1_edPrice")
        self.__calc_result_upline( "ptnPBHeadAndShoulderBottom", "line1_edPrice")




if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    PatternResult("d").execute()
    PatternResult("w").execute()
    PatternResult("m").execute()
