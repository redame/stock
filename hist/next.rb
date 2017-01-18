#!/bin/env ruby

require "date"

ymd=ARGV[0]

dt=Date.parse(ymd)
ndt=dt+1
print ndt.strftime("%Y-%m-%d")
