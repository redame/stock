#!/bin/sh


export LD_LIBRARY_PATH=/opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-CentOS-linux/4.8.2/::/usr/local/cuda/lib64:/opt/openssl/lib:/usr/local/lib:/usr/local/ssl/lib:/opt/sybase/ODBC-12_5/lib:/opt/sybase/OCS-12_5/lib:/opt/sybase/OCS-12_5/lib3p:/opt/sybase/SQLRemote/lib:/opt/sybase/$SYBASE_FTS/lib:/opt/sybase/$SYBASE_FTS/verity/_ilnx21/bin:/opt/sybase/$SYBASE_FTS/verity/_ilnx21/filters:/opt/sybase/ASE-12_5/lib::/usr/local/cula/lib64:/usr/java/jdk1.5.0_19/jre/lib/amd64:/usr/java/jdk1.5.0_19/jre/lib/adm64/server:/usr/local/cuda/lib:/usr/local/cuda/cudaprof/bin:/usr/local/cuda/lib64:/usr/lib64/R/library/rJava/jri/
export PATH=/opt/rh/devtoolset-2/root/usr/bin/:/usr/local/cuda/bin:/usr/local/rbenv/versions/2.2.2/bin:/usr/java/jdk1.8.0_45/bin:/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/lib64/qt-3.3/bin:/usr/kerberos/bin:/usr/java/jdk1.5.0_19/bin:/opt/ant/bin:/opt/sybase/OCS-12_5/bin:/opt/sybase/RPL-12_5/bin:/opt/sybase/$SYBASE_FTS/bin:/opt/sybase/JS-12_5/bin:/opt/sybase/ASE-12_5/bin:/opt/sybase/ASE-12_5/install:/usr/local/bin:/bin:/usr/bin:/opt/erlang/bin:/opt/maven/bin:/usr/local/node/bin:/opt/rabbitmq/sbin/:/opt/scala/bin:/opt/sbt/bin:/opt/activator/.:/opt/activator/bin:/usr/local/cuda/bin:/usr/local/cuda/cudaprof/bin:/home/admin/.composer/vendor/bin:/home/admin/bin:/usr/libexec/mecab/
export C_INCLUDE_PATH=/opt/rh/devtoolset-2/root/usr/include/::/usr/local/ssl/include
export JAVA_HOME=/usr/java/jdk1.8.0_45
export LANG=ja_JP.UTF-8

tables="
ptnPBDoubleBottom
ptnPBDoubleTop
ptnPBDownChannel
ptnPBFallingTriangle
ptnPBFallingWedge
ptnPBHeadAndShoulderBottom
ptnPBHeadAndShoulderTop
ptnPBRisingTriangle
ptnPBRisingWedge
ptnPBTripleBottom
ptnPBTripleTop
ptnPBUpChannel
"

for tbl in $tables;do
  mysql -uroot -hlocalhost << Eof
use fintech
;
truncate table $tbl
;
Eof
done


python patternPB.py

python patternPBDel.py

python patternPBNowResult.py
