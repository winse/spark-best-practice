## 生成log日志

```
cd gen
sh weblog.sh 
```

## 运行SparkStreaming程序

本地写好scala程序后，直接放到机器然后根据spark程序版本来进行打包。当然本地已经处理好生成jar就更好了。

```
> // IDE编译后，打包。和环境的scala版本不一致，囧
> target\classes>jar cvf weblog.jar com\github\winse\spark\WebLogStreamin*

# 编译
# rm WebLogStreaming.scala
rm -rf com/
rm -rf weblog.jar 

scalac -classpath "/home/hadoop/spark-1.6.0-bin-2.6.3/lib/spark-assembly-1.6.0-hadoop2.6.3-ext-2.1.jar" WebLogStreaming.scala
jar cvf weblog.jar com/github/winse/spark/WebLogStreaming*

# 运行
[hadoop@cu2 spark-1.6.0-bin-2.6.3]$ bin/spark-submit --master local[2] --class com.github.winse.spark.WebLogStreaming ~/streaming/weblog.jar 
```

## 附：SparkStreaming前的测试

先用Spark程序实现功能，再封装成SparkStreaming

```
[hadoop@cu2 spark-1.6.0-bin-2.6.3]$ bin/spark-shell --driver-class-path lib/mysql-connector-java-5.1.34.jar --master local[2]
...
SQL context available as sqlContext.

scala> sc.setLogLevel("WARN")
scala> val lines=sc.textFile("hdfs:///spark/streaming/*.log") // 先用sc.textFile跑通，在改成是streaming
scala> lines.count()
scala> lines.map(l => (l.split(" ")(0), 1)).reduceByKey(_+_).sortBy(_._2, false).take(10)

scala> def searchKeyWord(refer: String): (String, String) = {
     | val f = refer.split('/')
     |     val searchEngines = Map("www.google.cn" -> "q", "www.yahoo.com" -> "p", "cn.bing.com" -> "q", "www.baidu.com" -> "wd", "www.sogou.com" -> "query")
     | 
     |     var host = ""
     |     var param = ""
     |     if (f.length > 2) {
     |       host = f(2)
     |       if (searchEngines.contains(host)) {
     |         val query = refer.split('?')(1)
     |         if (query.length > 0) {
     |           val params = query.split('&').filter(_.indexOf(searchEngines(host) + "=") == 0)
     |           if (params.length > 0)
     |             param = params(0).split('=')(1)
     |         }
     |       }
     |     }
     | 
     |     (host, param)
     | }
scala> val refers = lines.map(_.split("\"")(3))
scala> val searchEngineInfo = refers.map(searchKeyWord)
scala> searchEngineInfo.filter(_._1.length>0).map(s=>(s._1, 1)).reduceByKey(_+_).take(10)
scala> searchEngineInfo.filter(_._2.length>0).map(p=>(p._2, 1)).reduceByKey(_+_).take(10)
scala> lines.map(_.split("\"")(5)).map(agent => { var res = "Default"; for (t <- List("iPhone", "Android")) { if(agent.indexOf(t) > -1) res=t } ; (res, 1)}).reduceByKey(_+_).take(10)
scala> lines.map(l => (l.split("\"")(1).split(" ")(1), 1)).reduceByKey(_ + _).take(10)
```

