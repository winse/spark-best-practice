[hadoop@cu2 spark-1.6.0-bin-2.6.3]$ ll conf/
total 48
-rw-r--r-- 1 hadoop hadoop  987 Jan  9  2016 docker.properties.template
-rw-r--r-- 1 hadoop hadoop 1105 Jan  9  2016 fairscheduler.xml.template
lrwxrwxrwx 1 hadoop hadoop   36 Mar 24 20:18 hive-site.xml -> /home/hadoop/hive/conf/hive-site.xml
-rw-rw-r-- 1 hadoop hadoop   68 Mar 25 19:44 java-opts.back
-rw-r--r-- 1 hadoop hadoop 1734 Jan  9  2016 log4j.properties.template
-rw-r--r-- 1 hadoop hadoop 6671 Jan  9  2016 metrics.properties.template
-rw-r--r-- 1 hadoop hadoop  865 Jan  9  2016 slaves.template
-rw-r--r-- 1 hadoop hadoop 1292 Jan  9  2016 spark-defaults.conf.template
-rwxr-xr-x 1 hadoop hadoop 4447 Mar 25 20:15 spark-env.sh
-rwxr-xr-x 1 hadoop hadoop 4209 Jan  9  2016 spark-env.sh.template

[hadoop@cu2 spark-1.6.0-bin-2.6.3]$ bin/spark-sql --driver-class-path lib/mysql-connector-java-5.1.34.jar
...
spark-sql> use spark;
spark-sql> show tables;
goods_base_info false
goods_sale_info false
store_base_info false
store_credit_info       false


----
[hadoop@cu2 spark-2.0.0-bin-2.6.3]$ ll conf/
total 36
-rw-r--r-- 1 hadoop hadoop  987 Oct  9 09:50 docker.properties.template
-rw-r--r-- 1 hadoop hadoop 1105 Oct  9 09:50 fairscheduler.xml.template
lrwxrwxrwx 1 hadoop hadoop   50 Oct 13 21:21 hive-site.xml -> /data/opt/apache-hive-1.2.1-bin/conf/hive-site.xml
-rw-r--r-- 1 hadoop hadoop 2025 Oct  9 09:50 log4j.properties.template
-rw-r--r-- 1 hadoop hadoop 7239 Oct  9 09:50 metrics.properties.template
-rw-r--r-- 1 hadoop hadoop  865 Oct  9 09:50 slaves.template
-rw-r--r-- 1 hadoop hadoop 1292 Oct  9 09:50 spark-defaults.conf.template
-rwxrwxr-x 1 hadoop hadoop   50 Oct 13 21:15 spark-env.sh
-rwxr-xr-x 1 hadoop hadoop 3861 Oct  9 09:50 spark-env.sh.template

[hadoop@cu2 spark-2.0.0-bin-2.6.3]$ bin/spark-sql --driver-class-path ~/hive/lib/mysql-connector-java-5.1.34.jar --master yarn-client



计算最近7天销量最高的商家
spark-sql> select
         > b.store_id, c.store_name, sum(a.day_sale_count_total) sale_total_num, sum(a.day_sale_count_total * a.price) sale_total_money, avg(a.price) avg_price
         > from
         > goods_sale_info a
         > left join goods_base_info b on a.goods_id = b.goods_id
         > left join store_base_info c on b.store_id = c.store_id
         > where
         > a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())), 7)
         > group by b.store_id, c.store_name
         > order by sale_total_num desc
         > limit 10
         > ;

793375733       闪魔旗舰店      113854313118    1227057988754
2024058652      古尚古旗舰店    64515244814     601058216187
1114511827      荣耀官方旗舰店  55353389952     80292893056768
1714128138      小米官方旗舰店  39423344445     39723513477339
898146183       carkoci旗舰店   37911700728     337497894459
2616970884      苏宁易购官方旗舰店      31917975242     94274638660288
268451883       三际数码官方旗舰店      28135768782     50447152647744
2103641754      趣乐数码专营店  21871252422     172043813961
2656269899      光帆数码科技    20799747198     65680770582
2456114960      捷斯纳旗舰店    20640563860     126998132390
Time taken: 63.28 seconds, Fetched 10 row(s)
16/10/13 21:45:51 INFO CliDriver: Time taken: 63.28 seconds, Fetched 10 row(s)

计算最近7天上线新品最多的10家店铺 <- date_added没采集到数据
select
a.store_id, b.store_name, count(distinct(a.goods_id)) new_goods_num
from goods_base_info a
left join store_base_info b on a.store_id = b.store_id
where
a.date_added >= date_sub(to_date(from_unixtime(unix_timestamp())), 7)
and a.date_added < to_date(from_unixtime(unix_timestamp()))
group by a.store_id, b.store_name
order by new_goods_num desc
limit 10;

计算最近7天相对之前7天销量增长最快的店铺（这个跑了好久）
select
b.store_id,
c.store_name,
sum(case
-- 最近一个周期
when a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())), 7) then a.day_sale_count_total
-- 减去前一个周期
else 0-a.day_sale_count_total
end ) sale_total_inc
from
goods_sale_info a
left join goods_base_info b on a.goods_id = b.goods_id
left join store_base_info c on b.store_id = c.store_id
where
-- 取最近两个周期
a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())), 7+7)
group by b.store_id, c.store_name
order by sale_total_inc desc
limit 10;

1114511827      荣耀官方旗舰店  6720310912
1714128138      小米官方旗舰店  6159208371
1831416010      韩诺旗舰店      4431667769
2616970884      苏宁易购官方旗舰店      2450255412
2103641754      趣乐数码专营店  1185108345
2975892770      gusgu古尚古专卖店       1074518340
2455420587      第一卫旗舰店    931975517
1805134965      雷瑞斯数码专营店        879995249
2253539763      sprintfox旗舰店 728349478
2024058652      古尚古旗舰店    689070887
Time taken: 830.214 seconds, Fetched 10 row(s)
16/10/13 22:09:55 INFO CliDriver: Time taken: 830.214 seconds, Fetched 10 row(s)


计算一上市就热卖的商品 <- date_added没采集到
select
b.goods_id, sum(a.day_sale_count_total) sale_total_num, b.goods_name
from
goods_sale_info a
left join goods_base_info b on a.goods_id = b.goods_id
where
a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())), 30)
and b.date_added >= date_sub(to_date(from_unixtime(unix_timestamp())), 30)
and a.data_date >= b.date_added
and a.data_date <= date_add(b.date_added, 7)
group by b.goods_id, b.goods_name
order by sale_total_num desc
limit 10;

计算分类交易量最高的10个商品
select
a.goods_id, sum(a.day_sale_count_total) sale_total, b.goods_name
from
goods_sale_info a
left join goods_base_info b on a.goods_id = b.goods_id
-- where
-- a.data_date >= '2015-05-02' and a.data_date <= '2015-05-04'
-- and b.class_one = '女装男装' and b.class_two = '女式上装'
group by a.goods_id, b.goods_name
order by sale_total desc
limit 10;

41006014012     473112024       古尚古 iphone6钢化玻璃膜 苹果6s钢化膜 I6六防指纹7手机贴膜4.7
41581287114     368235036       闪魔 iphone6钢化玻璃膜 苹果6s钢化膜 I6六防指纹前后7手机膜4.7
45534580560     345110608       小米4钢化膜max红米note2note3米note/3S/5/4C/4S/2A/3x/pro膜1S
530665775918    293770069       新科 苹果数据线iphone6加长5s手机6s苹果5充电线器6Plus六快充i7
42077920512     270111248       品炫iphone6手机壳6s苹果6Plus手机壳透明超薄硅胶防摔i6P保护套
41437478446     232387458       古尚古 iphone6plus钢化玻璃膜 苹果6s钢化膜 6手机贴膜保护膜5.5
537773176199    232374721       古尚古 iphone6plus钢化玻璃膜 苹果6s钢化膜 7全屏覆盖3D蓝光5.5
537545327366    210419600       古尚古 iphone6手机壳6s苹果6plus手机壳硅胶透明超薄六保护套软
41741730442     209610576       carkoci iPhone6钢化膜 苹果6s钢化膜 I6六抗蓝光前后7手机膜4.7
42503346960     178416183       闪魔 iphone6plus钢化玻璃膜 苹果6splus钢化膜 6sp手机贴膜5.5
Time taken: 26.032 seconds, Fetched 10 row(s)
16/10/13 22:14:12 INFO CliDriver: Time taken: 26.032 seconds, Fetched 10 row(s)

计算最近7天，相对之前7天，销量增长最多的商品
select
a.goods_id,
b.goods_name,
sum(case
-- 最近一个周期
when a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())), 7) then a.day_sale_count_total
-- 减去前一个周期
else 0-a.day_sale_count_total
end ) sale_total_inc
from
goods_sale_info a left join goods_base_info b on a.goods_id = b.goods_id
where
a.data_date >= date_sub(to_date(from_unixtime(unix_timestamp())),7+7)
group by a.goods_id, b.goods_name
order by sale_total_inc desc
limit 10;

537545327366    古尚古 iphone6手机壳6s苹果6plus手机壳硅胶透明超薄六保护套软     18292560
534715680661    【送49元保护壳 现货】华为honor/荣耀 荣耀8智能手机  官方正品     8430708
538020792012    韩诺 iPhone6手机壳 苹果6s保护套硅胶6plus防摔外壳磨砂新款硬6p    7342340
527054225872    第一卫iPhone7钢化膜苹果6S全屏覆盖抗蓝光6手机纳米防爆高清贴膜    7301790
537651658430    古尚古 iPhone6 7 数据线6s苹果5 5s加长 安卓手机6Plus充电线器     6139776
536940360683    捷纳斯 iphone6plus钢化玻璃膜 苹果6s钢化膜 7手机贴膜保护膜5.5    6046832
41047193981     奢姿 iPhone6钢化膜 苹果6s钢化玻璃膜 I6六全屏覆盖7手机贴膜4.7    5600040
41440692173     Q果 iphone6手机壳6s苹果6plus手机壳硅胶透明简约软胶防摔潮男女    5310624
537451059663    日韩iPhone6plus手机壳指环支架 苹果6s硅胶7p软套创意潮女款挂绳    4078502
527287172243    【直降200】正品智能手机Xiaomi/小米 小米手机5 全网通标准版       3857130
Time taken: 17.737 seconds, Fetched 10 row(s)
16/10/13 22:15:58 INFO CliDriver: Time taken: 17.737 seconds, Fetched 10 row(s)
