package com.github.winse.spark

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.streaming._

object WebLogStreaming {

  def main(args: Array[String]) {
    val sc = new SparkContext(new SparkConf().setAppName("nginx"))
    sc.setLogLevel("WARN")

    val batch = 10
    val ssc = new StreamingContext(sc, Seconds(batch))
    val lines = ssc.textFileStream("hdfs:///spark/streaming")

    // pv
    lines.count().print()
    // 窗口方法
    // 必须配置checkpoint
//    ssc.checkpoint("hdfs:///spark/checkpoint")
//    lines.countByWindow(Seconds(batch*6), Seconds(batch*6)).print()

    def extractColumn(data: String)(sperator: String)(index: Int): String = {
      try {
        data.split(sperator)(index)
      } catch {
        case _: Throwable =>
          println("extract err, origin data: " + data)
          ""
      }
    }

    // ip-pv
    lines.map(l => (extractColumn(l)(" ")(0), 1)).reduceByKey(_ + _).transform(rdd => {
      rdd.sortBy(_._2, false)
    }).print()

    // search pv
    def searchKeyWord(refer: String): (String, String) = {
      val f = refer.split('/')
      val searchEngines = Map(
        "www.google.cn" -> "q",
        "www.yahoo.com" -> "p",
        "cn.bing.com" -> "q",
        "www.baidu.com" -> "wd",
        "www.sogou.com" -> "query")

      var host = ""
      var param = ""
      if (f.length > 2) {
        host = f(2)
        if (searchEngines.contains(host)) {
          val query = refer.split('?')(1)
          if (query.length > 0) {
            val params = query.split('&').filter(_.indexOf(searchEngines(host) + "=") == 0)
            if (params.length > 0)
              param = params(0).split('=')(1)
          }
        }
      }

      (host, param)
    }

    val refer = lines.map(l => extractColumn(l)("\"")(3))
    val searchEngineInfo = refer.map(searchKeyWord)

    searchEngineInfo.filter(_._1.length > 0).map(s => (s._1, 1)).reduceByKey(_ + _).print()
    // keyword pv
    searchEngineInfo.filter(_._2.length > 0).map(p => (p._2, 1)).reduceByKey(_ + _).print()

    // client type pv
    lines.map(l => extractColumn(l)("\"")(5))
      .map(agent => {
        var res = "Default"
        for (t <- List("iPhone", "Android")) {
          if (agent.indexOf(t) > -1)
            res = t
        }
        (res, 1)
      }).reduceByKey(_ + _).print()

    // page pv
    lines.map(l => (extractColumn(extractColumn(l)("\"")(1))(" ")(1), 1)).reduceByKey(_ + _).print()

    ssc.start() // start调用后才会开始执行哦！旧的数据也不会分析了！！
    ssc.awaitTermination()
  }

}
