#!/bin/sh


codes="
DOW
GSPC
IXIC
DAX
FTSE
JPY=X
GBPUSD=X
EURUSD=X
TNX
GC=F
CL=F
"
for code in $codes;do
Rscript hist_dow.R $code  
done
