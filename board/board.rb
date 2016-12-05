#!/bin/env ruby
# coding:utf-8

require "open-uri"
require "nokogiri"
require "json"
require "nkf"
require "date"

class YahooBoard
  def initialize(outdir)
    @outdir=outdir
p @outdir
  end

  def exec(code,topurl)
p topurl
    url=topurl
    while true
      exit 1 if !get_data(code,url)
      url=prev_url(url)
p url
      break if url==nil or url==0
      sleep 1
    end
    exit 0
  end

  def get_data(code,url)
p "code="+code.to_s+",url="+url.to_s
begin
    iswrite=false
    doc=Nokogiri::HTML open url
    lst=doc.xpath('//div[@id="cmtlst"]').xpath('.//ul[@class="commentList"]/li')
    lst.each do |v|
      hash=Hash.new
      ele=v.xpath('.//div[@class="comment"]')
      #num=trim(ele.xpath('.//span[@class="comNum"]').text).to_i
      num=ele.xpath('.//span[@class="comNum"]').text.strip.gsub(/\（.*\）/,"")
p "num="+num.to_s
      next if num == 0 

      filename=getfilename(url,num);
      next if File.exists?(filename)

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
      write(filename,hash)
      iswrite=true
    end
rescue => e
      p e
      p $!    
      p $@
      return false
end
p "iswrite="+iswrite.to_s
      return iswrite
  end

  def getfilename(url,num)
    path=@outdir+url.gsub(/^.*\/message/,"").gsub(/\?.*$/,"")
    filename=path+"/"+num.to_s+".json"
    return filename
  end

  def write(filename,hash)
    path=File.dirname(filename)
    #path=@outdir+url.gsub(/^.*\/message/,"")
    FileUtils.mkdir_p(path)
    #open(path+"/"+num.to_s+".json","w") do |f|
    open(filename,"w") do |f|
      f.puts(JSON.generate(hash))
    end
  end

  def trim(s)
    s.chomp.gsub(/"/,"").gsub(/\n/,"").gsub(/\r/,"").gsub(/ /,"").gsub(/<br>/,"")
  end

  def prev_url(url)
p "prev_url-->"+url
    doc=Nokogiri::HTML open url
    #lst=doc.xpath('//div[@id="threadHd"]').xpath('./ul/li[@class="threadBefore"]/a')
    #lst=doc.xpath('//div[@id="threadHd"]').xpath('./ul/li[@class="threadBefore"]/a')
    lst=doc.xpath('//div[@id="toppg"]/div/ul').xpath("./li[2]/a")
p lst

    lst.each do |v|
      return v["href"]
    end
    return nil
  end


  # 6月11日 16:53
  def conv_ymd(ymd)
# "ymd=2015年4月28日 06:22"
#p "ymd="+ymd
    if ymd.include?("年") then
      dt=ymd.gsub(/年/,"-").gsub(/月/,"-").gsub(/日/,"")+":00"
      return Date.parse(dt).strftime("%Y-%m-%d %H:%M:%S")
    else
      dt=Time.now.year.to_s+"-"+ymd.gsub(/月/,"-").gsub(/日/,"")+":00"
      return Date.parse(dt).strftime("%Y-%m-%d %H:%M:%S")
    end
  end

end


if __FILE__ == $0 then
  if ARGV[0] == nil or ARGV[1] == nil or ARGV[2] == nil then
    p "usage:"+$0 + " outdir code url"
  end
  YahooBoard.new(ARGV[0]).exec(ARGV[1],ARGV[2])
end
