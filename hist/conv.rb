#!/bin/env ruby
require "date"

f=open(ARGV[0])
f.each{|line|
  cnt=0
  s=""
  line.chomp.split("\t").each{|l|
    if cnt==0 then
      dt=Date.parse(l)
      s=dt.strftime("%Y-%m-%d")
    else
      s=s+"\t"+l
    end
    cnt=cnt+1
  }
  print s+"\n"
}

