#!/bin/sh

. /etc/profile
HDFS="hdfs dfs"

streaming_dir="/spark/streaming"
temp_file="test.log"

#$HDFS -rm -r "$streaming_dir/*"
#$HDFS -mkdir -p $streaming_dir/tmp/

while true ; do
  # error message print to stdout??
  scala -cp joda-time-2.9.3.jar WebLogGeneration.scala > $temp_file
  
  tmplog="access.`date +'%s'`.log"
  $HDFS -put $temp_file $streaming_dir/tmp/$tmplog
  $HDFS -mv  $streaming_dir/tmp/$tmplog $streaming_dir/

  echo "`date +"%F %T"` put $tmplog to HDFS succed。"
  
  sleep 1
done

rm $temp_file 2>/dev/null