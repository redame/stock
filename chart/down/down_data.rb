#!/bin/env ruby -w
# coding:utf-8

# deplacated , see to down_data.R

require "mysql"

class DownData
  def initialize
    @mysql=Mysql.connect("zaaa16d.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
    @stockCodes=[]
    @step=5
    @limit=0.2
    @outfile="down.txt"
    File.unlink(@outfile) if File.exists?(@outfile)
  end
  def exec
    get_codes
    @stockCodes.each do |stockCode|
      check_data(stockCode)
    end
  end

  def check_data(stockCode)
p stockCode
    topix=[]
    prices=[]
    dates=[]
    stmt=@mysql.prepare("select p.date,p.cprice,i.cprice from ST_priceHistAdj p ,indexHist i where p.date=i.date and i.indexCode='751' and p.date>='2000-01-04' and p.date<='2010-12-31' and p.stockCode=? order by date desc")
    res=stmt.execute(stockCode)
    res.each do |tuple|
      dates.push(tuple[0].to_s)
      prices.push(tuple[1].to_f)
    end

    for i in 20...(dates.size-@step) do
      now=prices[i]
      next if now < 100.0
      for j in (i+1)...(i+@step) do
        prev=prices[j]
        ret=((now-prev)/prev)
        if ret<=-@limit then
#p "i="+i.to_s+",j="+j.to_s+",now="+now.to_s+",prev="+prev.to_s
          n5ret=check_after(i,5,prices,now)
          n10ret=check_after(i,10,prices,now)
          n15ret=check_after(i,15,prices,now)
          n20ret=check_after(i,20,prices,now)
          write(ret,stockCode,dates[j],prev,dates[i],now,dates[i-5],prices[i-5],n5ret,dates[i-10],prices[i-10],n10ret,dates[i-15],prices[i-15],n15ret,dates[i-20],prices[i-20],n20ret)
          break
        end
      end
    end
  end
  def check_after(i,n,prices,edprice)
    return (prices[i-n]-edprice)/edprice
  end
  def write(ret,stockCode,stdate,stprice,eddate,edprice,date5,price5,ret5,date10,price10,ret10,date15,price15,ret15,date20,price20,ret20)
    open(@outfile,"a") do |io|
      io.puts stockCode+"\t"+stdate+"\t"+stprice.to_s+"\t"+eddate+"\t"+edprice.to_s+"\t"+ret.to_s+"\t"+date5.to_s+"\t"+price5.to_s+"\t"+ret5.to_s+"\t"+date10.to_s+"\t"+price10.to_s+"\t"+ret10.to_s+"\t"+date15.to_s+"\t"+price15.to_s+"\t"+ret15.to_s+"\t"+date20.to_s+"\t"+price20.to_s+"\t"+ret20.to_s+"\n"
    end
  end
  def get_codes
    stmt=@mysql.prepare("select distinct stockCode from ST_priceHistAdj")
    res=stmt.execute()
    res.each do |tuple|
      @stockCodes.push(tuple[0])
    end
  end
end

if __FILE__ == $0 then
  DownData.new.exec
end
