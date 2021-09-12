---
layout: post
title: "Save 70% of heap memory by using a custom binary search instead of a map in Java"
description: |
    Java's collections framework is an amazing toolset capable of solving your problem in most 
    of the cases. But sometimes, a little it can become a little hungry on the memory site. Map has a huge 
    overhead on storing values.
date: 2021-09-06 00:00 
---

In one of my recent tasks, there was a need to perform a range query — give me all records whose values 
are within some range of values — on an in-memory data structure. Looking at the Java Collections 
Framework [1], we decided to use `NavigableMap`, and in particular, its `subMap()` method. The implementation 
worked as we expected. The only downside was memory consumption. It looked like we used more heap memory than
the data consumed on disk in the database. Armed with a profiler, we started to dig and discovered a huge 
memory overhead imposed by using `NavigableMap`.

In this article, we will go through the original implementation first, and discover the internals of the Map
in Java. Then we have a look on how we managed to solve the problem by performing a couple of binary searches
on sorted lists.

### Domain model

Here is a generalized domain model we will be working with. We have a number of entities that serve as 
verticles in a graph. From each verticle there can be multiple outgoing edges. Each edge has a set of 
properties: we don't really care what these properties except for the `departure_timestamp`, as this is 
the value we need to perform the range query on. The rest of the properties will be just nine other 
integer values.

todo: picture of the model

Given that, the range query in our domain model language sounds like "find all edges departing from a 
particular station within an interval of two timestamp".  

Now, let's dive into the implementation with `NavigableMap`.

### Implementation with NavigableMap

This implementation is straightforward. We have a top-level `Map` with keys being the station ID, and 
values — the instances of NavigableMap where we store all edges sorted by `departure_timestamp`. 

todo: picture of the model with Map

For simplicity of calculation, we limit the number of verticles and edges: let's say 3K for verticles and
1M for edges. Translated to Java code, we say that we have a `Map` with 3K instances of `NavigableMap` 
across which scattered 3M edges. Here is how it looks in the code:

todo: code sample: new Map, with NavigableMaps inside.

And here is our range query:

todo: `subMap()` call

Works flawlessly. What about heap memory usage?

todo: picture/text of the profiler

Let's do the math. To store 10 integer values, 64-bit JVM will use ... amount of bytes. 3M x 10, plus 3K 
station IDs (insignificant), plus some overhead on the `Edge` object. And we get ... The rest is the 
overhead for storing all these values in `Map` and `NavigableMap`. And that is ... !

In order to understand where this overhead comes from, let's have a look at the internals of the Map in Java.

todo: find internals
todo: a picture with a `Map.Entry`
Maybe something about NavigableMap in particular because they use other data structure to support Set 
operations and traversal.

There are some good resources going into details on the JVM intervals and specifically the Map overhead.
todo: find links for Map overhead. 

With the implementation details in mind, we see that the overhead comes from a huge amount of Map 
instances together with a lot of elements inside them. 

https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/NavigableMap.html
https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/NavigableMap.html#subMap(K,boolean,K,boolean)

[1]: https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/package-summary.html#CollectionsFramework
