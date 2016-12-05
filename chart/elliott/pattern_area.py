#!/bin/env python
# coding:utf-8

import MySQLdb
import sys



# 問題は、zigzagパラメタのどれを使えばしっくり来るかということ
# 評価方法を確立。線で囲まれたあいだのロウソク足面積比率を使う。


class PatternArea:
    def __init__(self,ashi,fromDate,toDate):
        self.con=MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="root", passwd="")
        self.ashi=ashi
        self.fromDate=fromDate
        self.toDate=toDate

    def check(self):
        self.__chk_ptn("ptnDoubleBottom")
        self.__chk_ptn("ptnDoubleTop")
        self.__chk_ptn("ptnDownChannel")
        self.__chk_ptn("ptnFallingTriangle")
        self.__chk_ptn("ptnFallingWedge")
        #self.__chk_ptn("ptnHeadAndShoulderBottom")
        #self.__chk_ptn("ptnHeadAndShoulderTop")
        self.__chk_ptn("ptnRisingTriangle")
        self.__chk_ptn("ptnRisingWedge")
        self.__chk_ptn("ptnTripleBottom")
        self.__chk_ptn("ptnTripleTop")
        self.__chk_ptn("ptnUpChannel")

    def __chk_ptn(self,ptnTable):
        cur = self.con.cursor()
        cur.execute("select stockCode,zigzag from "+ptnTable+" where ashi=%s",(self.ashi,))
        res=cur.fetchall()
        for i in range(0,len(res)):
            stockCode=res[i][0]
            zigzag=res[i][1]
            ohlc=self.__get_ohlc(stockCode)
            self.__calc_ptn(ptnTable,ohlc,stockCode,zigzag)


    def __get_ohlc(self,stockCode):
        table="ST_priceHistAdj"
        if self.ashi == "w":
            table="ST_priceHistWeekly"
        elif self.ashi == "m":
            table="ST_priceHistMonthly"
        cur = self.con.cursor()
        cur.execute("select date,oprice,high,low,cprice from live."+table+" where stockCode=%s and date between %s and %s order by date",(stockCode,self.fromDate,self.toDate))
        ohlc=cur.fetchall()
        return(ohlc)

    def __calc_ptn(self,ptnTable,ohlc,stockCode,zigzag):
        cur=self.con.cursor()
        cur.execute("select line1_stDate,line1_stPrice,line1_edDate,line1_edPrice,line2_stDate,line2_stPrice,line2_edDate,line2_edPrice,date_from,date_to,price_from,price_pre,price_to,price_post from "+ptnTable+" where stockCode=%s and zigzag=%s and ashi=%s order by date_to desc ",(stockCode,zigzag,self.ashi))
        data = cur.fetchall()
        for item in data:
            st_lx1=tuple(x[0] for x in ohlc).index(item[0])
            st_ly1=item[1]
            ed_lx1=tuple(x[0] for x in ohlc).index(item[2])
            ed_ly1=item[3]
            st_lx2=tuple(x[0] for x in ohlc).index(item[4])
            st_ly2=item[5]
            ed_lx2=tuple(x[0] for x in ohlc).index(item[6])
            ed_ly2=item[7]
            st_x=tuple(x[0] for x in ohlc).index(item[8])
            ed_x=tuple(x[0] for x in ohlc).index(item[9])
            st_y=item[10]
            pre_y=item[11]
            st_is_peak=1
            if st_y < pre_y:
                st_is_peak=-1
            ed_y=item[12]
            post_y=item[13]
            ed_is_peak=1
            if ed_y < post_y:
                ed_is_peak=-1

            line_area=self.__calc_line_area(ohlc , st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak,ed_is_peak)
            candle_area=self.__calc_candle_area(ohlc ,st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x,st_is_peak,ed_is_peak)
            print ("ptnTable=" + ptnTable + ",stockCode=" + stockCode + ",zigzag=" + str(zigzag) + ",candle_area=" + str(candle_area) + ",line_area=" + str(line_area))
            cur.execute("replace into ptnCheckArea values(%s,%s,%s,%s,%s,%s,%s,%s)",(ptnTable,stockCode,zigzag,item[8],item[9],self.ashi,candle_area,line_area))
            self.con.commit()

    def __calc_line_area(self,ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak ,ed_is_pak):

        st_y_diff=abs(st_ly1-st_ly2)
        ed_y_diff=abs(ed_ly1-ed_ly2)
        x_diff=ed_x-st_x
        #trapezoid area
        line_area=(float(st_y_diff)+float(ed_y_diff))*float(x_diff)/2.0
        return(line_area)

    def __calc_candle_area(self, ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak,ed_is_peak):
        candle_area=0
        for x in range(st_x,ed_x+1):
            candle_area=candle_area+abs(ohlc[x][1]-ohlc[x][4])

        x_list = self.__pre_to_from_x_cross_line_x(ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak,ed_is_peak)
        for x in x_list:
            candle_area=candle_area+abs(ohlc[x][1]-ohlc[x][4])

        x_list=self.__to_to_post_x_cross_line_x(ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak,ed_is_peak)
        for x in x_list:
            candle_area=candle_area+abs(ohlc[x][1]-ohlc[x][4])

        return (candle_area)

    def __pre_to_from_x_cross_line_x(self,ohlc,st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x, st_is_peak,ed_is_peak):
        x_list=[]
        # line1は必ず上
        # date_pre -> date_from
        if st_is_peak == 1:
            for x in range(st_lx2,st_x):
                y = ((ed_ly2 - st_ly2) / (ed_lx2 - st_lx2)) * (x - st_lx2) + st_ly2
                if min(ohlc[x][1],ohlc[x][4]) > y:
                    x_list.append(x)
        else:
            for x in range(st_lx1,st_x):
                y = ((ed_ly1 - st_ly1) / (ed_lx1 - st_lx1)) * (x - st_lx1) + st_ly1
                if max(ohlc[x][1],ohlc[x][4]) < y:
                    x_list.append(x)
        return x_list

    def __to_to_post_x_cross_line_x(self,ohlc, st_lx1, st_ly1, ed_lx1, ed_ly1, st_lx2, st_ly2, ed_lx2, ed_ly2, st_x, ed_x,st_is_peak,ed_is_peak):
        x_list=[]
        # line1は必ず上
        # date_to -> date_post
        if ed_is_peak == 1:
            for x in range(ed_lx2, ed_x, -1):
                y = ((ed_ly2 - st_ly2) / (ed_lx2 - st_lx2)) * (x - st_lx2) + st_ly2
                if min(ohlc[x][1], ohlc[x][4]) > y:
                    x_list.append (x)
        else:
            for x in range(ed_lx1, st_x, -1):
                y = ((ed_ly1 - st_ly1) / (ed_lx1 - st_lx1)) * (x - st_lx1) + st_ly1
                if max(ohlc[x][1], ohlc[x][4]) < y:
                    x_list.append(x)
        return x_list



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    fromDate = "2000-01-01"
    toDate = "2015-12-31"
    ashi = "w"
    PatternArea(ashi,fromDate,toDate).check()
    ashi = "m"
    PatternArea(ashi, fromDate, toDate).check()
    ashi = "d"
    PatternArea(ashi, fromDate, toDate).check()