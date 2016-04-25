#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

url="http://textream.yahoo.co.jp/message/1006502/elbcg/55?offset=266&rv=1&back=1"
    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@id="cmtlst"]').xpath('.//ul[@class="commentList"]/li')
    lst.each do |v|
      ele=v.xpath('.//div[@class="comment"]')

      uele=ele.xpath('./div/p[@class="comWriter"]/span[starts-with(@class,"emotionLabel")]')
p uele
if uele.size>0 then
p uele.attribute("class").text.gsub(/emotionLabel/,"").gsub(/ /,"")
end
    end
      
