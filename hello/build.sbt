organization := "com.example"
version := "0.1.0"
scalaVersion := "2.11.8"
name := "hello"

//disablePlugins(plugins.IvyPlugin)

resolvers += Resolver.mavenLocal
resolvers += "cu" at "http://14.215.113.57:8081/nexus/content/groups/public/"
resolvers += "maven-restlet" at "http://maven.restlet.org"

libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0"