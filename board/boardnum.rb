#!/bin/env ruby
# coding:utf-8
# get latest thread number 

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

class BoardUrl

  def exec(url)
    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@class="threadAbout"]').xpath('./h1/a')
    lst.each do |v|
      print File.basename( v["href"])
      return
    end

  end

end


if __FILE__ == $0 then
  if ARGV[0] == nil then
    p "usage:"+$0 + " url"
  end
  BoardUrl.new.exec(ARGV[0])
end
