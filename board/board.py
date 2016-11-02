#!/bin/env python
# coding:utf-8

import json
import urllib
import time
import re
import os
import sys
import datetime
import lxml.html

class YahooBoard:
    def __init__(self, outdir):
        self.outdir = outdir
        self.date_limit=datetime.datetime.strptime("2015-01-01 00:00:00", '%Y-%m-%d %H:%M:%S')

    def execute(self, code, topurl):

        url = topurl
        while True:
            if self.get_data(code, url) == False:
                return 1
            url = self.prev_url(url)

            if url == None or url == 0:
                break
            time.sleep(1)

        return 0

    def get_data(self, code, url):
        try:
            iswrite = False
            html=urllib.urlopen(url).read()
            html=re.sub("\r","",html)
            html=re.sub("\n","",html)
            html=re.sub("<br.*?>","",html)
            doc = lxml.html.fromstring(html)

            lst = doc.xpath('//div[@id="cmtlst"]/ul[@class="commentList"]/li')

            for v in lst:
                hash = {}
                ele_tmp = v.xpath('.//div[@class="comment"]')
                if len(ele_tmp)==0:
                    continue

                ele=ele_tmp[0]

                num=0
                num_tmp = ele.xpath('.//span[@class="comNum"]/span')
                if len(num_tmp)>0:
                    num=num_tmp[0].text
                    num = int(re.sub(u"（.*\）", "", num))
                else:
                    num_tmp = ele.xpath('.//span[@class="comNum"]')
                    if len(num_tmp) > 0:
                        num = num_tmp[0].text
                        num = int(re.sub(u"（.*\）", "", num))
                if num == 0:
                    continue

                filename = self.getfilename(url, num)
                if os.path.exists(filename):
                    iswrite = True
                    continue

                hash["num"] = num
                hash["stockCode"] = code
                uele = ele.xpath('./div/p[@class="comWriter"]/a/@href')
                for v in uele:
                    hash["user"] = re.sub("^.*?user=", "", v)

                s_tmp=ele.xpath('./div/p/span/a')
                if len(s_tmp)>0:
                    s=s_tmp[0]
                    s=s.text.encode("utf-8")
                    ymd = self.conv_ymd(s)
                    # date limit check
                    if ymd<self.date_limit:
                        return False

                    hash["date"] = ymd.strftime("%Y-%m-%d %H:%M:%S")
                else:
                    continue

                eele = ele.xpath('./div/p[@class="comWriter"]/span[starts-with(@class,"emotionLabel")]/@class')
                if len(eele) > 0:
                    tmp = eele[0]
                    tmp = re.sub("emotionLabel", "", tmp)
                    tmp = re.sub(" ", "", tmp)
                    hash["emotion"] = tmp
                else:
                    hash["emotion"] = ""

                hash["replyto"] = ""
                replyto_tmp = ele.xpath('./p[@class="comReplyTo"]/a')
                if len(replyto_tmp)>0:
                    replyto=replyto_tmp[0]
                    replyto=replyto.text.encode("utf-8")
                    replyto = int(re.sub(">", "", replyto))
                    if replyto != 0:
                        hash["replyto"] = replyto



                body_tmp = ele.xpath('./p[@class="comText"]')
                if len(body_tmp)==0:
                    continue
                body=body_tmp[0]
                print body.text
                body = body.text.encode("utf-8")
                hash["body"] = str(body)

                comLike_tmp = ele.xpath('./div/ul[@class="comLike cf"]')
                hash["positive"] = ""
                hash["negative"] = ""
                if len(comLike_tmp)>0:
                    comLike=comLike_tmp[0]
                    posi = int(comLike.xpath('./li[@class="positive"]/a/span')[0].text)
                    nega = int(comLike.xpath('./li[@class="negative"]/a/span')[0].text)
                    hash["positive"] = posi
                    hash["negative"] = nega
                self.write(filename, hash)
                iswrite = True

        except Exception as e:

            print "Unexpected error:", sys.exc_info()[0]
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            print str(e.args)
            print e.message
            iswrite = False
        return iswrite

    def getfilename(self, url, num):
        path = self.outdir + re.sub("\?.*$", "", re.sub("^.*\/message", "", url))
        filename = path + "/" + str(num) + ".json"
        return filename

    def write(self, filename, hash):
        path = os.path.dirname(filename)
        if not os.path.exists(path):
            os.makedirs(path)
        with open(filename, "w") as f:
            f.write(json.dumps(hash, ensure_ascii=False))

    def trim(self, s):
        tmp = s.rstrip
        tmp = re.sub('"', "", tmp)
        tmp = re.sub("\n", "", tmp)
        tmp = re.sub("\r", "", tmp)
        tmp = re.sub(" ", "", tmp)
        tmp = re.sub("<br>", "", tmp)
        return tmp

    def prev_url(self, url):
        html = urllib.urlopen(url).read()
        doc = lxml.html.fromstring(html)
        li = doc.xpath('//div[@id="toppg"]/div/ul/li')
        lst=li[2].xpath('./a/@href')

        for v in lst:
            return v

        return None

    # 6月11日 16:53
    def conv_ymd(self, ymd):
        # "ymd=2015年4月28日 06:22"
        # p "ymd="+ymd
        if ymd.find("年")>=0:
            dt = re.sub("年", "-", ymd)
            dt = re.sub("月", "-", dt)
            dt = re.sub("日", "", dt) + ":00"
            now = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
            return now
            #return now.strftime("%Y-%m-%d %H:%M:%S")
        else:
            dt = re.sub("月", "-", ymd)
            dt = re.sub("日", "", dt) + ":00"
            dt = datetime.datetime.now().strftime("%Y") + "-" + dt
            now = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
            #return now.strftime("%Y-%m-%d %H:%M:%S")
            return now


if __name__ == '__main__':
    #outdir = sys.argv[1]
    #code = sys.argv[2]
    #url = sys.argv[3]
    outdir="tmp"
    code="9963"
    url="http://textream.yahoo.co.jp/message/1009963/9bebcibea6bbv/1"
    YahooBoard(outdir).execute(code, url)
