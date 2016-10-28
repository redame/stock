#!bin/env python
# coding:utf-8
import pandas
import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc


#http://blanktar.jp/blog/2015/12/python-matplotlib-candles-chart.html

dat = pandas.read_csv('USDJPY.csv', parse_dates=['日付'])  # ファイルの読み込み。
dat = dat[-50:]  # データが多すぎるので減らす。

dates = dat['日付']  # あとでつかう。

tmp = dat['日付'].values.astype('datetime64[D]')  # ナノ秒精度とか無意味なので、精度を日単位まで落とす。
dat['日付'] = tmp.astype(float)  # Datetime64形式だと使えないので、floatに変換。

plt.xticks(  # 横軸の値と表示の対応の設定。[::5]はラベルを1週間ごとにするために使っている。
	dat['日付'][::5],
	[x.strftime('%Y-%m-%d') for x in dates][::5]
)
plt.grid()

ax = plt.subplot()
candlestick_ohlc(  # グラフを作る。
	ax,
	dat.values,  # 入力データ。左から順に、始値、高値、安値、終値にする。その後にデータが続いてても良いらしい。
	width=0.7,  # 棒の横幅。今回は日単位の精度に落としてあるので、0.7日分の幅になる。
	colorup='skyblue',
	colordown='black'
)

plt.show()