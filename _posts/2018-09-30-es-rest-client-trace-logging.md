---
layout: post
title: "Enabling trace logging for Elasticsearch REST Client with Logback"
description: "Enabling trace logging for Elasticsearch REST Client with Logback"
date: 2018-09-30 15:12
---

Recently I had some issues with Elasticsearch - all requests were failing with "bad request" error. In order to understand what was wrong with these requests, I, natually, decided to enable debug/trace logging of for ES REST Client, but couldn't find out how. Partially, because the [official documentation](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/6.3/java-rest-low-usage-logging.html) on this topic could have been more informative, to be honest. But mainly, because my project uses [Logback](https://logback.qos.ch/) and the REST Client package uses [Apache Commons Logging](https://commons.apache.org/proper/commons-logging/).

This article is a short summary of how I've eventually managed to enable tracing with Logback. The patient under inspection is  Elasticsearch 6.3 with its [Java Low Level REST Client](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/6.3/java-rest-low.html).

According to the official documentation, we need to enable trace logging for the <code>tracer</code> package. If you are interested, you can check the source code for [org.elasticsearch.client.RequestLogger](https://github.com/elastic/elasticsearch/blob/v6.3/client/rest/src/main/java/org/elasticsearch/client/RequestLogger.java#L49) class, where the logger with this name is defined:

{%highlight java%}
...
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
...
private static final Log tracer = LogFactory.getLog("tracer");
...
{%endhighlight%}

As you can see, enabling this logger with <code>TRACE</code> level in Logback is not enough, because, again, the client uses Apache Commons Logging.

Luckily, Logback was designed with this use case in mind, and provides a set of bridging modules [[1]](#1). They allow us to use Logback even with other dependencies that rely on other logging API. In particular, we're looking for [jcl-over-slf4j.jar](https://www.slf4j.org/legacy.html#jclOverSLF4J).

So, here are the steps.

**Require <code>jcl-over-slf4j.jar</code>**. The dependencies section for Gradle:  
{%highlight gradle%}
dependencies {
    implementation('org.slf4j:slf4j-api:1.8.0-beta2')
    implementation('ch.qos.logback:logback-classic:1.3.0-alpha4')
    implementation('org.slf4j:jcl-over-slf4j:1.8.0-beta2')
}
{%endhighlight%}

**Exclude <code>commons-logging.jar</code>**. The details of why are described in the Logback docs [here](https://www.slf4j.org/legacy.html#jclOverSLF4J).  
{%highlight gradle%}
dependencies {
    configurations.all {
        exclude group: "commons-logging", module: "commons-logging"
    }
}
{%endhighlight%}

**Enable _tracer_ logger in Logback configuration.**  
{%highlight xml%}
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>[%d{ISO8601}] [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="WARN">
        <appender-ref ref="STDOUT" />
    </root>

    <logger name="tracer" level="TRACE" additivity="false">
        <appender-ref ref="STDOUT" />
    </logger>

    <!-- Additionally, you can also enable debug logging ofr RestClient class itself -->
    <logger name="org.elasticsearch.client.RestClient" level="DEBUG" additivity="false">
        <appender-ref ref="STDOUT" />
    </logger>
</configuration>
{%endhighlight%}

Voilà! Enjoy your debugging session!

## References

<ul id="notes">
<li>
	<span class="col-1">[1] <a name="1"></a></span>
	<span class="col-2"><a href="https://www.slf4j.org/legacy.html">Bridging legacy APIs with Logback</a></span>
</li>
</ul>
