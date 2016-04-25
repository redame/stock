
files="
bband
macd
roc
rsi
sma
wma
"

for f in $files;do
  rm -rf ~/stock/work/$f.txt
  R --vanilla < $f.R
done

