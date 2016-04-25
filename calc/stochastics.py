#!/bin/env python
# -*- coding:utf-8 -*-

import datetime
import numpy
import talib
import urllib3

import os
import json


TECH="Stochastics"

def makeTechnicalFunc(inputData,ohlc,k,d):
	fileName="../outputData/"+TECH+"/"+inputData+"@k="+str(k)+"&d="+str(d)+".json"
	try:
		hi=ohlc[:,2].astype(float)
		lo=ohlc[:,3].astype(float)
		cl=ohlc[:,4].astype(float)
		fastk,fastd=talib.STOCHF(hi,lo,cl,fastk_period=k, fastd_period=d)
		result=[]
		result.append(fastk.tolist())
		result.append(fastd.tolist())
		f=open(fileName,"w")
		f.write(json.dumps(tuple(result)).replace("NaN","null"))	
		f.close()
	except:
		length=len(ohlc[:,1])
		msg="ohlc="+length+",n="+n
		message(msg)
		ary=[]
		for var in range(0,length):
			ary.append(None)
		f=open(fileName,"w")
		f.write(json.dumps(ary))
		f.close()
	

def makeTechnical(inputData):
	url="http://fs14.qr.com/technicals/inputData.php?dataName="+inputData+".json"
	proxy=urllib3.ProxyManager("http://zaan15p.qr.com:8080")
	res=proxy.request("GET",url)
	jstr=res.data.decode("UTF-8")
	jstr=jstr.replace('\r','').replace('\t','').replace('\n','')
	ohlc=numpy.asarray(json.loads(jstr))
	techdir="../outputData/"+TECH
	if not os.path.exists(techdir):
		os.mkdir(techdir)	
	makeTechnicalFunc(inputData,ohlc,14,3)


if __name__ == "__main__":
	makeTechnical("0Flat360_0")
	makeTechnical("0testOfTest")
	makeTechnical("1Step001_0")
	makeTechnical("1Step003_0")
	makeTechnical("1Step006_0")
	makeTechnical("1Step036_0")
	makeTechnical("1Step360_0")
	makeTechnical("2Impulse060_0")
	makeTechnical("3Reg150_0")
	makeTechnical("4ATR100_1_0")
	makeTechnical("4ATR100_2_0")
	makeTechnical("4ATR100_3_0")
	makeTechnical("Normal_0")
