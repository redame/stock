#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

url="http://textream.yahoo.co.jp/message/1009204/a59a5aba5a4a5dea1bca5afa5a8a5a2a5ia5a4a5sa5ba/1"

    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@id="cmtlst"]').xpath('.//ul[@class="commentList"]/li')
p lst
