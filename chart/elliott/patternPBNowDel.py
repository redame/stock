#!/bin/env python
# coding:utf-8


# 不要なパターンをDBから削除
import MySQLdb
import sys


class PatternDel:
    def __init__(self,  ashi):
        self.connection = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.ashi = ashi
        self.ptnList=[
            "ptnNowPBTripleTop",
            "ptnNowPBTripleBottom",
            "ptnNowPBRisingTriangle",
            "ptnNowPBFallingTriangle",
            "ptnNowPBUpChannel",
            "ptnNowPBDownChannel",
            "ptnNowPBDoubleTop",
            "ptnNowPBDoubleBottom",
            "ptnNowPBRisingWedge",
            "ptnNowPBFallingWedge",
            "ptnNowPBHeadAndShoulderTop",
            "ptnNowPBHeadAndShoulderBottom"
                 ]

    def __del_other_table(self,stockCode,base_idx):
        #self.__not_now_ptn(stockCode,base_idx)
        for i in range(3, 20, 1):
            self.__priority_to_old_data(stockCode,base_idx,i)
        self.__priority_to_small_pb_term(stockCode,base_idx)
        self.__priority_ptn_list(stockCode,base_idx)
        return

    def __not_now_ptn(self,stockCode,base_index):
        ptnTable=self.ptnList[base_index].replace("Now","")
        cursor=self.connection.cursor()
        cursor.execute("select date_from,date_to,pb_term from "+self.ptnList[base_index]+" where stockCode=%s and ashi=%s",(stockCode,self.ashi,))
        data=cursor.fetchall()
        for item in data:
            date_from=item[0]
            date_to=item[1]
            pb_term=item[2]
            cursor.execute("select * from "+ptnTable+" where stockCode=%s and ashi=%s and date_from=%s and date_to=%s and pb_term=%s",(stockCode,self.ashi,date_from,date_to,pb_term,))
            if cursor.rowcount > 0:
                cursor.execute("delete from "+self.ptnList[base_index]+" where stockCode=%s and ashi=%s and date_from=%s and date_to=%s and pb_term=%s",(stockCode,self.ashi,date_from,date_to,pb_term,))
                print(cursor._last_executed)
                print(cursor.rowcount)
                self.connection.commit()
        cursor.close()

    def __priority_ptn_list(self,stockCode,base_idx):
        print("priority_ptn_list,stockCode="+stockCode+","+str(base_idx)+":"+self.ptnList[base_idx])
        cursor=self.connection.cursor()
        cursor.execute("select date_from,date_to from "+self.ptnList[base_idx]+ " where stockCode=%s and ashi=%s order by date_from asc",(stockCode,self.ashi,))
        dates=cursor.fetchall()
        for date in dates:
            date_from=date[0]
            date_to=date[1]
            for i in range(base_idx+1,len(self.ptnList)):
                cursor.execute("delete from " + self.ptnList[i] + " where date_from >=%s and date_from<%s and stockCode=%s and ashi=%s ",(date_from, date_to, stockCode, self.ashi,))
                print(cursor._last_executed)
                print(cursor.rowcount)

                cursor.execute("delete from " + self.ptnList[i] + " where date_to > %s and date_to<=%s and stockCode=%s and ashi=%s ",(date_from, date_to, stockCode, self.ashi,))
                print(cursor._last_executed)
                print(cursor.rowcount)

                self.connection.commit()
        cursor.close()
        return

    def __priority_to_old_data(self,stockCode,base_idx,pb_term):
        print("priority_to_old_data,stockCode="+stockCode+","+str(base_idx)+":"+self.ptnList[base_idx]+",pb_term="+str(pb_term))
        cursor=self.connection.cursor()
        cursor.execute("select date_from,date_to from "+self.ptnList[base_idx]+" where stockCode=%s and ashi=%s and pb_term=%s order by date_from asc",(stockCode,self.ashi,pb_term,))
        dates=cursor.fetchall()
        for date in dates:
            date_from=date[0]
            date_to=date[1]
            # priority to old data
            cursor.execute("delete from " + self.ptnList[base_idx] + " where date_from >%s and date_to<%s and stockCode=%s and ashi=%s and pb_term=%s and date_from != %s and date_to != %s",(date_from, date_to, stockCode, self.ashi, pb_term,date_from,date_to,))
            print(cursor._last_executed)
            print(cursor.rowcount)
            cursor.execute("delete from " + self.ptnList[base_idx] + " where date_to > %s and date_to<%s and stockCode=%s and ashi=%s and pb_term=%s and date_from != %s and date_to != %s",(date_from, date_to, stockCode, self.ashi, pb_term, date_from, date_to,))
            print(cursor._last_executed)
            print(cursor.rowcount)
            self.connection.commit()
        cursor.close()
        return

    def __priority_to_small_pb_term(self,stockCode,base_idx):
        print("riority_to_big_pb_term,stockCode="+stockCode+","+str(base_idx)+":"+self.ptnList[base_idx])
        cursor = self.connection.cursor()
        for i in range(3, 20):
            cursor.execute("select date_from,date_to from "+self.ptnList[base_idx]+" where stockCode=%s and ashi=%s and pb_term=%s",(stockCode,self.ashi,i,))
            dates=cursor.fetchall()
            for date in dates:
                date_from=date[0]
                date_to=date[1]
                # pb_termの小が優先、大でかぶっているものは削除
                for pb_term in range(i+1, 20):
                    cursor.execute("delete from " + self.ptnList[base_idx] + " where date_from >=%s and date_to<%s and stockCode=%s and ashi=%s and pb_term=%s",(date_from, date_to, stockCode, self.ashi, pb_term,))
                    print(cursor._last_executed)
                    print(cursor.rowcount)

                    cursor.execute("delete from " + self.ptnList[base_idx] + " where date_to > %s and date_to<=%s and stockCode=%s and ashi=%s and pb_term=%s",(date_from, date_to, stockCode, self.ashi, pb_term,))
                    print(cursor._last_executed)
                    print(cursor.rowcount)

                    self.connection.commit()
        cursor.close()
        return

    def execute(self):
        cursor = self.connection.cursor()
        cursor.execute("select stockCode from live.stockMasterFull where nk225Flag='1' order by stockCode")
        stockCodes = cursor.fetchall()
        for stockCode in stockCodes:
            for i in range(0, len(self.ptnList)):
                self.__del_other_table(stockCode[0],i)
                
        cursor.close()
        self.connection.close()
        return

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    PatternDel("d").execute()
    PatternDel("w").execute()
    PatternDel("m").execute()


