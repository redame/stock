#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"
require "aws-sdk"
require "tmpdir"

class YahooNews
  def initialize(outdir)
    @outdir=outdir
  end

  def exec(key)
    doc=Nokogiri::HTML open 'http://news.yahoo.co.jp/hl?c='+key
    lst=doc.xpath('//div[@class="articleList"]').xpath('.//ul[@class="listBd"]/li')
    hash=nil
    lst.each do |node|
begin
      hash=Hash.new
      node.xpath('.//a').map do |v|
        hash["href"]=v["href"] # href
      end
      fname=hash["href"].gsub(/^.*?a=/,"")
      ymd=fname.gsub(/-.*$/,"")
      ymd=conv_ymd(ymd)
      return if File.exists?(@outdir+"/"+ymd+"/"+key+"/"+fname)

      hash["title"]=node.xpath('.//a').text #title
      next if !get_body?(hash,ymd)
      write(hash,ymd,key,fname)
      sleep (1)
rescue => e
p $!
p e 
p hash
end
    end
  end
  def conv_ymd(ymd)
    yy=ymd[0,4]
    if yy.to_i > Time.now.year then
      yy=Time.now.year.to_s
      return yy.to_s+ymd[4,2]+ymd[6,2]
    else
      return ymd
    end
    
  end
  def make_time(ymd,tim)
    s=ymd[0,4]+"-"+ymd[4,2]+"-"+ymd[6,2]+" "
    h=tim.gsub(/時.*$/,"").to_i
    if h<10 then
      hs="0"+h.to_s
    else
      hs=h.to_s
    end
    m=tim.gsub(/^.*時/,"").gsub(/分/,"").to_i
    if m<10 then
      ms="0"+m.to_s
    else
      ms=m.to_s
    end
    return s+hs+":"+ms+":00"
  end
  def write(hash,ymd,key,fname)
    FileUtils.mkdir_p(@outdir+"/"+ymd+"/"+key)
    open(@outdir+"/"+ymd+"/"+key+"/"+fname,"w") do |f|
      f.puts(JSON.generate(hash))
    end
p fname
  end
  def get_body?(hash,ymd)
      doc=Nokogiri::HTML open hash["href"]
      mn=doc.xpath('//div[@id="main"]')
      src=NKF.nkf("-w",mn.xpath('.//p[@class="source"]/a').text.gsub(/\n/,""))
      hash["source"]=src
      return false if src == nil or src == ""
      tim=NKF.nkf("-w",mn.xpath('.//p[@class="source"]/text()').text.gsub(/\n/,"")).gsub(/配信/,"").gsub(/^.*\)/,"")
      hash["time"]=make_time(ymd,tim)
      hash["body"]=NKF.nkf("-w",mn.xpath('.//p[@class="ynDetailText"]').text.gsub(/\n/,""))
      return true
  end

end


if __FILE__ == $0 then
  if ARGV[0] == nil or ARGV[1] == nil then
    p "usage:"+$0 + " outdir category"
  end
  YahooNews.new(ARGV[0]).exec(ARGV[1])
end
