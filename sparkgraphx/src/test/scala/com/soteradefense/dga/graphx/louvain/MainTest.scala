package com.soteradefense.dga.graphx.louvain

import java.io.File
import java.nio.file.Files

import org.junit.Test

class MainTest {

  @Test
  def runTest(): Unit = {
    val output = "data/output"
    def delete(file: File): Unit = {
      if (file.isDirectory) {
        file.listFiles().foreach(delete)
      }
      
      if (file.exists()) file.delete()
    }
    delete(new File(output))

    Main.main(Array(
      "-i", "data/input/friends.csv",
      "-o", output // 输出目录
    ))
  }

}
