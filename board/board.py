#!/bin/env python
# coding:utf-8

import json
import urllib
import time
import re
import os
import sys
import datetime


class YahooBoard:
    def __init__(self, outdir):
        self.outdir = outdir

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
            doc = urllib.urlopen(url)
            lst = doc.xpath('//div[@id="cmtlst"]').xpath('.//ul[@class="commentList"]/li')
            for v in lst:
                hash = {}
                ele = v.xpath('.//div[@class="comment"]')
                # num=trim(ele.xpath('.//span[@class="comNum"]').text).to_i
                num = ele.xpath('.//span[@class="comNum"]').text.strip
                num = re.sub("（.*\）", "", num)
                if num == 0:
                    continue

                filename = self.getfilename(url, num)
                if os.path.exists(filename):
                    continue

                hash["num"] = num
                hash["stockCode"] = code

                uele = ele.xpath('./div/p[@class="comWriter"]/a')
                for v in uele:
                    hash["user"] = re.sub("^.*?user=", "", str(v["href"]))

                ymd = self.conv_ymd(ele.xpath('./div/p/span/a').text)
                hash["date"] = ymd

                eele = ele.xpath('./div/p[@class="comWriter"]/span[starts-with(@class,"emotionLabel")]')
                if eele.size > 0:
                    tmp = eele.attribute("class").text
                    tmp = re.sub("emotionLabel", "", tmp)
                    tmp = re.sub(" ", "", tmp)
                    hash["emotion"] = tmp
                else:
                    hash["emotion"] = ""

                replyto = ele.xpath('./p[@class="comReplyTo"]/a').text.trim
                replyto = int(re.sub(">", "", replyto))
                if replyto != 0:
                    hash["replyto"] = replyto

                body = ele.xpath('./p[@class="comText"]').text.trim
                hash["body"] = body

                comLike = ele.xpath('./div/ul[@class="comLike cf"]')
                posi = int(comLike.xpath('./li[@class="positive"]/a/span').text)
                nega = int(comLike.xpath('./li[@class="negative"]/a/span').text)
                hash["positive"] = posi
                hash["negative"] = nega
                self.write(filename, hash)
                iswrite = True

        except:
            print "Unexpected error:", sys.exc_info()[0]
            iswrite = False
        return iswrite

    def getfilename(self, url, num):
        path = self.outdir + re.sub("\?.*$", "", re.sub("^.*\/message", "", url))
        filename = path + "/" + num.to_s + ".json"
        return filename

    def write(self, filename, hash):
        path = os.path.dirname(filename)
        # path=@outdir+url.gsub(/^.*\/message/,"")
        os.makedirs(path)
        # open(path+"/"+num.to_s+".json","w") do |f|
        with open(filename, "w") as f:
            f.puts(json.dumps(hash))

    def trim(self, s):
        tmp = s.rstrip
        tmp = re.sub('"', "", tmp)
        tmp = re.sub("\n", "", tmp)
        tmp = re.sub("\r", "", tmp)
        tmp = re.sub(" ", "", tmp)
        tmp = re.sub("<br>", "", tmp)
        return tmp

    def prev_url(self, url):
        doc = urllib.urlopen(url)
        lst = doc.xpath('//div[@id="toppg"]/div/ul').xpath("./li[2]/a")

        for v in lst:
            return v["href"]

        return None

    # 6月11日 16:53
    def conv_ymd(self, ymd):
        # "ymd=2015年4月28日 06:22"
        # p "ymd="+ymd
        if ymd.include("年"):
            dt = re.sub("年", "-", ymd)
            dt = re.sub("月", "-", dt)
            dt = re.sub("日", "", dt) + ":00"
            now = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
            return now.strftime("%Y-%m-%d %H:%M:%S")
        else:
            dt = re.sub("月", "-", ymd)
            dt = re.sub("日", "", dt) + ":00"
            dt = datetime.datetime.now().strftime("%Y") + "-" + dt
            now = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
            return now.strftime("%Y-%m-%d %H:%M:%S")


if __name__ == '__main__':
    #outdir = sys.argv[1]
    #code = sys.argv[2]
    #url = sys.argv[3]
    outdir="tmp"
    code="9963"
    url="http://textream.yahoo.co.jp/message/1009963/9bebcibea6bbv/1"
    YahooBoard(outdir).execute(code, url)
