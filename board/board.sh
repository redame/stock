#!/bin/sh

. /etc/profile.d/SYBASE.sh 
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/ssl/lib:/opt/sybase/ODBC-12_5/lib:/opt/sybase/OCS-12_5/lib:/opt/sybase/OCS-12_5/lib3p:/opt/sybase/SQLRemote/lib:/opt/sybase/$SYBASE_FTS/lib:/opt/sybase/$SYBASE_FTS/verity/_ilnx21/bin:/opt/sybase/$SYBASE_FTS/verity/_ilnx21/filters:/opt/sybase/ASE-12_5/lib::/usr/local/cula/lib64:/usr/java/jdk1.5.0_19/jre/lib/amd64:/usr/java/jdk1.5.0_19/jre/lib/adm64/server:/usr/local/cuda/lib:/usr/local/cuda/cudaprof/bin:/usr/local/cuda/lib64:/usr/lib64/R/library/rJava/jri/
export PATH=/usr/java/jdk1.8.0_45/bin:/home/admin/.pyenv/shims:/home/admin/.pyenv/bin:/usr/local/rbenv/shims:/usr/local/rbenv/bin:/opt/python/bin:/usr/kerberos/bin:/usr/java/jdk1.5.0_19/bin:/opt/sybase/OCS-12_5/bin:/opt/sybase/RPL-12_5/bin:/opt/sybase/$SYBASE_FTS/bin:/opt/sybase/JS-12_5/bin:/opt/sybase/ASE-12_5/bin:/opt/sybase/ASE-12_5/install:/usr/local/bin:/bin:/usr/bin:/opt/erlang/bin:/opt/maven/bin:/usr/local/node/bin:/opt/rabbitmq/sbin/:/opt/scala/bin:/opt/sbt/bin:/opt/activator/.:/opt/activator/bin:/usr/local/cuda/bin:/usr/local/cuda/cudaprof/bin:/home/admin/.composer/vendor/bin:/home/admin/bin


cd /home/admin/news/board
LOCK=/var/lock/board.lock
if [ -f $LOCK ];then
  exit 1
fi
touch $LOCK

codes=`cat codes.txt`

for code in $codes;do
  url=`ruby boardurl.rb $code`
  for i in `seq 2 100`;do
    echo "  ruby board.rb /var/lib/news/board $code $url/$i"
    ruby board.rb /var/lib/news/board $code $url/$i
    if [ $? = 1 ];then
      break
    fi
    sleep 1
  done
done

rm -rf $LOCK
exit 0
