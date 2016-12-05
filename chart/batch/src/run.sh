#!/bin/sh

#/home/ec2-user/.pyenv/shims/python getAllStockPrice.py
python getAllStockPrice.py
cd trendline
bash ./start.sh
cd ../winRate
python calcWinRate.py
