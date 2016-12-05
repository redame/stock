#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

url="http://textream.yahoo.co.jp/message/1009963/9bebcibea6bbv/2"

    doc=Nokogiri::HTML open url
    #lst=doc.xpath('//div[@id="threadHd"]').xpath('./ul/li[@class="threadBefore"]/a')
    lst=doc.xpath('//div[@id="toppg"]/div/ul').xpath("./li[2]/a")
p lst
    lst.each do |v|
      p v["href"]
    end
