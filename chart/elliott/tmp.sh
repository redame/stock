
#tables="
# ptnDoubleBottom
# ptnDoubleTop
# ptnDownChannel
# ptnFallingTriangle
# ptnFallingWedge
# ptnHeadAndShoulderBottom
# ptnHeadAndShoulderTop
# ptnRisingTriangle
# ptnRisingWedge
# ptnTripleBottom
# ptnTripleTop
# ptnUpChannel
#"
tables="
elliott
elliottPB
"

for tbl in $tables;do
  mysql -uroot -hlocalhost fintech << Eof
delete from $tbl where stockCode not in (select stockCode from live.stockMasterFull where nk225Flag=1)
;
Eof
done
