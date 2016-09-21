package com.soteradefense.dga.graphx.louvain

import java.net.InetAddress
import java.nio.ByteBuffer

import org.apache.spark.SparkContext
import org.apache.spark.graphx.{Edge, Graph}

object Main {

  def main(args: Array[String]): Unit = {
    val parser = new scopt.OptionParser[Config](this.getClass().toString()) {
      opt[String]('i', "input") action { (x, c) => c.copy(input = x) } text ("input file or path  Required.")
      opt[String]('o', "output") action { (x, c) => c.copy(output = x) } text ("output path Required")
      opt[String]('m', "master") action { (x, c) => c.copy(master = x) } text ("spark master, local[N] or spark://host:port default=local")
      opt[String]('h', "sparkhome") action { (x, c) => c.copy(sparkHome = x) } text ("SPARK_HOME Required to run on cluster")
      opt[String]('n', "jobname") action { (x, c) => c.copy(appName = x) } text ("job name")
      opt[Int]('p', "parallelism") action { (x, c) => c.copy(parallelism = x) } text ("sets spark.default.parallelism and minSplits on the edge file. default=based on input partitions")
      opt[Int]('x', "minprogress") action { (x, c) => c.copy(minProgress = x) } text ("Number of vertices that must change communites for the algorithm to consider progress. default=2000")
      opt[Int]('y', "progresscounter") action { (x, c) => c.copy(progressCounter = x) } text ("Number of times the algorithm can fail to make progress before exiting. default=1")
      opt[String]('d', "edgedelimiter") action { (x, c) => c.copy(edgedelimiter = x) } text ("specify input file edge delimiter. default=\",\"")
      opt[String]('j', "jars") action { (x, c) => c.copy(jars = x) } text ("comma seperated list of jars")
      opt[Boolean]('z', "ipaddress") action { (x, c) => c.copy(ipaddress = x) } text ("Set to true to convert ipaddresses to Long ids. Defaults to false")
      arg[(String, String)]("<property>=<value>....") unbounded() optional() action { case ((k, v), c) => c.copy(properties = c.properties :+(k, v)) }
    }

    var edgeFile, outputdir, master, jobname, jars, sparkhome, edgedelimiter = ""
    var properties: Seq[(String, String)] = Seq.empty
    var parallelism, minProgress, progressCounter = -1

    var ipaddress = false

    parser.parse(args, Config()) map {
      config =>
        edgeFile = config.input
        outputdir = config.output
        master = config.master
        jobname = config.appName
        jars = config.jars
        sparkhome = config.sparkHome
        properties = config.properties
        parallelism = config.parallelism
        edgedelimiter = config.edgedelimiter
        minProgress = config.minProgress
        progressCounter = config.progressCounter
        ipaddress = config.ipaddress
        if (edgeFile == "" || outputdir == "") {
          println(parser.usage)
          sys.exit(1)
        }
    } getOrElse (sys.exit(1))

    properties.foreach { case (k, v) =>
      println(s"System.setProperty($k, $v)")
      System.setProperty(k, v)
    }

    var sc: SparkContext = null
    if (master.indexOf("local") == 0) {
      sc = new SparkContext(master, jobname)
    } else {
      sc = new SparkContext(master, jobname, sparkhome, jars.split(","))
    }
    // 日志级别
    sc.setLogLevel("WARN")

    // read the input into a distributed edge list
    val inputHashFunc =
      if (ipaddress)
        (id: String) => IpAddress.toLong(id)
      else
        (id: String) => id.toLong

    var edgeRDD = sc.textFile(edgeFile).map(row => {
      val tokens = row.split(edgedelimiter).map(_.trim())
      // 边（A, B, 权重）
      tokens.length match {
        case 2 => new Edge(inputHashFunc(tokens(0)), inputHashFunc(tokens(1)), 1L)
        case 3 => new Edge(inputHashFunc(tokens(0)), inputHashFunc(tokens(1)), tokens(2).toLong)
        case _ => throw new IllegalArgumentException("Invalid input line: " + row)
        // case _ => new Edge(0, 0, 1L)
      }
    })

    // if the parallelism option was set map the input to the corrent number of partitions,
    // otherwise parallelism will be based off number of HDFS blocks
    if (parallelism != -1) edgeRDD = edgeRDD.coalesce(parallelism, shuffle = true)

    val graph = Graph.fromEdges(edgeRDD, None)

    val runner = new HDFSLouvainRunner(minProgress, progressCounter, outputdir)
    runner.run(sc, graph)
  }

}

case class Config(
                   input: String = "",
                   output: String = "",
                   master: String = "local",
                   appName: String = "graphx analytic",
                   jars: String = "",
                   sparkHome: String = "",
                   parallelism: Int = -1,
                   edgedelimiter: String = ",",
                   minProgress: Int = 2000,
                   progressCounter: Int = 1,
                   ipaddress: Boolean = false,
                   properties: Seq[(String, String)] = Seq.empty[(String, String)])

object IpAddress {

  def toString(address: Long) = {
    val byteBuffer = ByteBuffer.allocate(8)
    val addressBytes = byteBuffer.putLong(address)
    // The below is needed because we don't have an unsigned Long, and passing a byte array
    // with more than 4 bytes causes InetAddress to interpret it as a (bad) IPv6 address
    val tmp = new Array[Byte](4)
    Array.copy(addressBytes.array, 4, tmp, 0, 4)
    InetAddress.getByAddress(tmp).getHostAddress()
  }

  def toLong(_address: String): Long = {
    val address =
      try {
        InetAddress.getByName(_address)
      } catch {
        case e: Throwable => throw new IllegalArgumentException("Could not parse address: " + e.getMessage)
      }

    val addressBytes = address.getAddress
    val bb = ByteBuffer.allocate(8)
    addressBytes.length match {
      case 4 =>
        bb.put(Array[Byte](0, 0, 0, 0)) // Need a filler
        bb.put(addressBytes)
      case n =>
        throw new IndexOutOfBoundsException("Expected 4 byte address, got " + n)
    }
    bb.getLong(0)
  }

}