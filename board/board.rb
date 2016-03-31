#!/bin/env ruby
# coding:utf-8

#require "aws-sdk"
require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"
require "fileutils"

class YahooBoard
  def initialize(outdir)
    @outdir=outdir
  end

  def exec(code,topurl)
    url=topurl
    while true
      exit 1 if !get_data(code,url)
      url=prev_url(url)
      break if url==nil or url==0
      sleep rand(3)+1
    end
    exit 0
  end

  def get_data(code,url)
p url
begin
    iswrite=false
    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@id="cmtlst"]').xpath('.//ul[@class="commentList"]/li')
    lst.each do |v|
      hash=Hash.new
      ele=v.xpath('.//div[@class="comment"]')
      num=trim(ele.xpath('.//span[@class="comNum"]').text).to_i
      next if num == 0 

      filename,fname=getfilename(url,num);
      next if File.exists?(@outdir+"/"+File.basename(filename)) 

      hash["num"]=num
      hash["stockCode"]=code

      uele=ele.xpath('./div/p[@class="comWriter"]/a')
      uele.each do |v|
        hash["user"]=v["href"].to_s.gsub(/^.*?user=/,"")
      end
      
      ymd=conv_ymd(ele.xpath('./div/p/span/a').text)
      hash["date"]=ymd


      eele=ele.xpath('./div/p[@class="comWriter"]/span[starts-with(@class,"emotionLabel")]')
      if eele.size>0 then
        hash["emotion"]=eele.attribute("class").text.gsub(/emotionLabel/,"").gsub(/ /,"")
      else
        hash["emotion"]=""
      end


      replyto=trim(ele.xpath('./p[@class="comReplyTo"]/a').text).gsub(/>/,"").to_i
      hash["replyto"]=replyto  if replyto != 0

      body=trim(ele.xpath('./p[@class="comText"]').text)
      hash["body"]=body

      comLike=ele.xpath('./div/ul[@class="comLike cf"]')
      posi=comLike.xpath('./li[@class="positive"]/a/span').text.to_i
      nega=comLike.xpath('./li[@class="negative"]/a/span').text.to_i
      hash["positive"]=posi
      hash["negative"]=nega
      write(filename,fname,hash)
      iswrite=true
    end
rescue => e
      p $!
      return false
end
      return iswrite
  end

  def getfilename(url,num)
    path="textream"+url.gsub(/^.*\/message/,"").gsub(/\?.*$/,"")
    filename=path+"/"+num.to_s+".json"
    return filename,num.to_s+".json"
  end

  def write(filename,fname,hash)
p "write="+filename.to_s
    Dir.mktmpdir do |dir|
      fi="#{dir}/"+fname
      open(fi,"w") do |f|
        f.puts(JSON.generate(hash))
      end
      file_open = File.open(fi)
      file_name = File.basename(fi)
      FileUtils.cp(fi,@outdir)
    end

  end

  def trim(s)
    s.chomp.gsub(/"/,"").gsub(/\n/,"").gsub(/\r/,"").gsub(/ /,"").gsub(/<br>/,"")
  end

  def prev_url(url)
    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@id="toppg"]').xpath('.//ul/li[@class="prev"]/a')
    lst.each do |v|
      return v["href"]
    end
    return nil
  end


  # 6月11日 16:53
  #  "2015年5月1日 03:11"
  def conv_ymd(ymd)
    dt=nil
    if ymd.include?("年") then
      dt=ymd.gsub(/年/,"-").gsub(/月/,"-").gsub(/日/,"")+":00"
    else
      dt=Time.now.year.to_s+"-"+ymd.gsub(/月/,"-").gsub(/日/,"")+":00"
    end
    ret= DateTime.parse(dt).strftime("%Y-%m-%d %H:%M:%S")
    return ret
  end

end


if __FILE__ == $0 then
  if ARGV[0] == nil or ARGV[1] == nil  then
    p "usage:"+$0 + " code url [outdir]"
  end
  YahooBoard.new(ARGV[2]).exec(ARGV[0],ARGV[1])
end
