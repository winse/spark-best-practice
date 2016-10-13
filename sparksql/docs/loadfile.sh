hive> show create table goods_base_info;
...
  'hdfs://hadoop-master2:9000/user/hive/warehouse/spark.db/goods_base_info'

----

[hadoop@cu2 lf]$ hdfs dfs -ls /user/hive/warehouse/spark.db
Found 4 items
drwxr-xr-x   - hadoop supergroup          0 2016-09-18 10:44 /user/hive/warehouse/spark.db/goods_base_info
drwxr-xr-x   - hadoop supergroup          0 2016-09-18 10:45 /user/hive/warehouse/spark.db/goods_sale_info
drwxr-xr-x   - hadoop supergroup          0 2016-09-18 10:41 /user/hive/warehouse/spark.db/store_base_info
drwxr-xr-x   - hadoop supergroup          0 2016-09-18 10:42 /user/hive/warehouse/spark.db/store_credit_info

----

[hadoop@cu2 lf]$ hdfs dfs -put goods_base_info*.txt /user/hive/warehouse/spark.db/goods_base_info/
[hadoop@cu2 lf]$ hdfs dfs -put goods_sale_info*.txt /user/hive/warehouse/spark.db/goods_sale_info/
[hadoop@cu2 lf]$ hdfs dfs -put store_base_info*.txt /user/hive/warehouse/spark.db/store_base_info/
[hadoop@cu2 lf]$ hdfs dfs -put store_credit_info*.txt /user/hive/warehouse/spark.db/store_credit_info/

OR

## OK
load data local inpath 'goods_base_info-*.txt' overwrite into table goods_base_info;
load data local inpath 'goods_sale_info-*.txt' overwrite into table goods_sale_info;
load data local inpath 'store_base_info-*.txt' overwrite into table store_base_info;
load data local inpath 'store_credit_info-*.txt' overwrite into table store_credit_info;
