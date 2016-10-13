create database spark;
use spark;

create table if not exists store_base_info (
store_id string,
store_name string,
is_tmall tinyint,
location_city string
)
-- PARTITIONED BY (day string)
row format delimited fields terminated by '\0'
stored as
inputformat 'org.apache.hadoop.mapred.TextInputFormat'
outputformat 'org.apache.hadoop.hive.ql.io.RCFileOutputFormat'
;

create table if not exists store_credit_info (
store_id string,
credit_as_seller int,
score_goods_desc int,
score_service_manner int,
score_express_speed int,
info_update_date date
)
row format delimited fields terminated by '\0'
stored as
inputformat 'org.apache.hadoop.mapred.TextInputFormat'
outputformat 'org.apache.hadoop.hive.ql.io.RCFileOutputFormat'
;

create table if not exists goods_base_info (
goods_id string,
goods_name string,
store_id string,
class_one string,
class_two string,
class_three string,
info_acquire_date date,
date_added date
)
row format delimited fields terminated by '\0'
stored as
inputformat 'org.apache.hadoop.mapred.TextInputFormat'
outputformat 'org.apache.hadoop.hive.ql.io.RCFileOutputFormat'
;

create table if not exists goods_sale_info (
goods_id string,
data_date date,
price int,
day_sale_count_total int
)
row format delimited fields terminated by '\0'
stored as
inputformat 'org.apache.hadoop.mapred.TextInputFormat'
outputformat 'org.apache.hadoop.hive.ql.io.RCFileOutputFormat'
;
