#!/bin/bash -vx

/usr/local/proad/tool/bin/kinit -k -t /usr/local/proad/tool/conf/aduser.keytab aduser
local_path=/a/ngate301/datafeed/1_prod/gaps
hdfs_path=hdfs:///user/aduser/rpp_budget_allocation/gaps
hadoop_path=/usr/local/hdp26/hadoop/bin

#Copy Kakau file
$hadoop_path/hadoop fs -copyFromLocal -f  $local_path/kakaku/kakaku.properties  $hdfs_path

#Copy Criteo file
$hadoop_path/hadoop fs -copyFromLocal -f  $local_path/criteo/criteo.properties $hdfs_path

#Copy Smartnews file
$hadoop_path/hadoop fs -copyFromLocal -f  $local_path/smartnews/smartnews.properties $hdfs_path