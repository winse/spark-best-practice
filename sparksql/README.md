## 功能

使用nodejs获取数据，然后用sparksql分析

## 使用说明

* 执行 `npm install` 下载依赖
* 添加定时任务，多采集几天的数据

```
[hadoop@cu2 spark-2.0.0-bin-2.6.3]$ crontab -l
0 4 * * * ( cd ~/lf/taobao; node crawler.js >> nohup.log  )

[hadoop@cu2 taobao]$ ls -l | head -n 20
total 89452
drwxrwxr-x   3 hadoop hadoop    4096 Sep 20 17:01 com
-rw-r--r--   1 hadoop hadoop    5432 Sep 19 19:34 crawler.js
-rw-r--r--   1 hadoop hadoop 1878060 Sep 20 04:08 goods_base_info-2016-09-19.txt
-rw-r--r--   1 hadoop hadoop 1873623 Sep 21 04:08 goods_base_info-2016-09-20.txt
-rw-r--r--   1 hadoop hadoop 1651515 Sep 22 04:08 goods_base_info-2016-09-21.txt
-rw-r--r--   1 hadoop hadoop 1874240 Sep 23 04:08 goods_base_info-2016-09-22.txt
-rw-r--r--   1 hadoop hadoop 1872323 Sep 24 04:08 goods_base_info-2016-09-23.txt
-rw-r--r--   1 hadoop hadoop 1874603 Sep 25 04:07 goods_base_info-2016-09-24.txt
-rw-r--r--   1 hadoop hadoop 1874094 Sep 26 04:09 goods_base_info-2016-09-25.txt
-rw-r--r--   1 hadoop hadoop 1874394 Sep 27 04:07 goods_base_info-2016-09-26.txt
-rw-r--r--   1 hadoop hadoop 1879359 Sep 28 04:07 goods_base_info-2016-09-27.txt
-rw-r--r--   1 hadoop hadoop 1879323 Sep 29 04:08 goods_base_info-2016-09-28.txt
-rw-r--r--   1 hadoop hadoop 1878474 Sep 30 04:08 goods_base_info-2016-09-29.txt
-rw-r--r--   1 hadoop hadoop 1878090 Oct  1 04:08 goods_base_info-2016-09-30.txt
-rw-r--r--   1 hadoop hadoop 1879981 Oct  2 04:07 goods_base_info-2016-10-01.txt
-rw-r--r--   1 hadoop hadoop 1875418 Oct  3 04:07 goods_base_info-2016-10-02.txt
-rw-r--r--   1 hadoop hadoop 1876027 Oct  4 04:08 goods_base_info-2016-10-03.txt
-rw-r--r--   1 hadoop hadoop 1877423 Oct  5 04:08 goods_base_info-2016-10-04.txt
-rw-r--r--   1 hadoop hadoop 1882137 Oct  6 04:08 goods_base_info-2016-10-05.txt
```

* 然后添加hive的数据表，查看 `docs/createtable.sql`;
* 然后把已经采集好的数据上传到HDFS，参见 `docs/loadfile.sh`;
* 最后通过sql来进行数据汇总统计，参见 `docs/spark.sh`.
