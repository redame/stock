#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

class BoardUrl

  def exec(code)
    doc=Nokogiri::HTML open 'http://textream.yahoo.co.jp/search?query='+code
    lst=doc.xpath('//div[@id="trdlst"]').xpath('.//li[@class="cf"]/dl/dt/a')
    lst.each do |v|
      print v["href"]
      return
    end

  end

end


if __FILE__ == $0 then
  if ARGV[0] == nil then
    p "usage:"+$0 + " code"
  end
  BoardUrl.new.exec(ARGV[0])
end
