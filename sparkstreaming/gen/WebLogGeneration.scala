import java.net.URLEncoder
import java.util

import org.joda.time.DateTime

import scala.collection.mutable.ListBuffer
import scala.util.Random

object WebLogGeneration {

  val user_agent_dist = Map(
    0 -> "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)",
    1 -> "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)",
    2 -> "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727)",
    3 -> "Mozilla/5.0 (compatible; MSIE 6.0; Windows NT 5.0; .NET CLR 1.1.4322)",
    4 -> "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko",
    5 -> "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0",
    6 -> "Mozilla/4.0 (compatible; MSIE6.0; Windows NT 5.0; .NET CLR 1.1.4322)",
    7 -> "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B511 Safari/535.53",
    8 -> "Mozilla/5.0 (Linux; Android 4.2.1; Galaxy Nexus Build/JOP40D AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19)",
    9 -> "Mozilla/5.0 (Macintosh; Intel Max OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
    10 -> " "
  )

  val ip_slice_list = Array(10, 29, 30, 46, 55, 63, 72, 87, 98, 132, 156, 124, 167, 143, 187, 168, 190, 201, 202, 214, 215, 222)

  val url_path_list = Array("login.php", "view.php", "list.php", "upload.php", "admin/login.php", "edit.php", "index.html")

  val http_refer = Array(
    "http://www.baidu.com/s?wd={query}",
    "http://www.goole.cn/search?q={query}",
    "http://www.sogou.com/web?query={query}",
    "http://www.yahoo.com/s?q={query}",
    "http://cn.bing.com/search?q={query}"
  )

  val search_keyword = Array("spark", "hadoop", "hive", "spark mlib", "spark sql")

  def sample[K](arr: Array[K], num: Int = 1): Seq[K] = {
    var res = new ListBuffer[K]()
    for (i <- 0 until num)
      res += arr(Random.nextInt(arr.length))
    res
  }

  def sample_ip = sample(ip_slice_list, 4).mkString(".")

  def sample_url = sample(url_path_list)(0)

  def sample_user_agent = user_agent_dist(Random.nextInt(11))

  def sample_refer = {
    if (Random.nextInt() > 2) {
      // 20% 流量有refer
      "-"
    } else {
      sample(http_refer)(0).replace("{query}", URLEncoder.encode(sample(search_keyword)(0)))
    }
  }

  def log(count: Int = 3): Unit = {
    val time = DateTime.now.toString("yyyy-MM-dd hh:mm:ss")
    for (i <- 0 until count)
      println(s"""$sample_ip - - [$time "GET /$sample_url HTTP/1.1" 200 0 "$sample_refer" "$sample_user_agent" "-" """)
  }

  def main(args: Array[String]) {
    log(Random.nextInt(20000) + 30000)
  }

}
