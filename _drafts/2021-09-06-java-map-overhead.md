---
layout: post
title: "Save 70% of heap memory by using a custom binary search instead of a map in Java"
date: 2021-09-06 00:00 
---

Java Collections Framework is an amazing toolset capable of solving your problem in most of the cases. But sometimes, a little it can become a little hungry on the memory site. Map has a huge overhead on storing values.

In one of my recent tasks, there was a need to perform a range query — give me all records within some range
of values — on an in-memory data structure. Looking at the [Java Collections
Framework][collections-framework], we decided to use `NavigableMap`, and in particular, its `subMap()` method.
The implementation worked as we expected. The only downside was memory consumption. It looked like we used
more heap memory than the data consumed on disk in the database. Armed with a profiler, we started to dig and
discovered a huge memory overhead imposed by using `NavigableMap`.

In this article, we will go through the original implementation first, and discover the internals of the Map in Java. Then we have a look on how we managed to solve the problem by performing a couple of binary searches on sorted lists.

## Java memory layout intro

Before diving into the implementation, let's have a brief look at how Java stores objects in memory. This is a huge topic by itself, and we'll just touch enough basics in order to understand the memory overhead caused by Java objects. For more detailed explanation, please refer to [From Java code to Java heap](https://developer.ibm.com/articles/j-codetoheap/) post. 

A newly allocated object on a heap will consume more memory than the memory required to store its data. For example, in a 64-bit Java process with [Compressed Ordinary Object Pointers (OOPs)](https://wiki.openjdk.java.net/display/HotSpot/CompressedOops) enabled, an `Integer` object requires 128 bits on a heap as opposed to 32 bits of the `int` value itself. This is what we call an "overhead". To analyze the layout for a particular object, we can utilize [Java Object Layout](https://openjdk.java.net/projects/code-tools/jol/)(JOL) tool. For the given code:

{% highlight java %}
import org.openjdk.jol.info.ClassLayout;
import org.openjdk.jol.vm.VM;

public static void main(String[] args) {
    System.out.println(VM.current().details());
    System.out.println(ClassLayout.parseClass(Integer.class).toPrintable());
}
{% endhighlight %}

We get the following output:

```bash
# Running 64-bit HotSpot VM.
# Using compressed oop with 3-bit shift.
# Using compressed klass with 3-bit shift.
# WARNING | Compressed references base/shifts are guessed by the experiment!
# WARNING | Therefore, computed addresses are just guesses, and ARE NOT RELIABLE.
# WARNING | Make sure to attach Serviceability Agent to get the reliable addresses.
# Objects are 8 bytes aligned.
# Field sizes by type: 4, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]
# Array element sizes: 4, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]

java.lang.Integer object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     N/A
  8   4        (object header: class)    N/A
 12   4    int Integer.value             N/A
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
```

From the output, we see that the instance size is 16 bytes (128 bits) from which 12-byte header metadata. The line `Using compressed oop...` tells us that we are using OOPs feature mentioned above which is a technique in JVM to reduce the memory consumption for heap sizes less than 32Gb. If we disable this feature with `-XX:-UseCompressedOops`, then it becomes even worse, and an `Integer` class requires 24 bytes!

```bash
# Running 64-bit HotSpot VM.
# Objects are 8 bytes aligned.
# Field sizes by type: 8, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]
# Array element sizes: 8, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]

java.lang.Integer object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     N/A
  8   8        (object header: class)    N/A
 16   4    int Integer.value             N/A
 20   4        (object alignment gap)    
Instance size: 24 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

Another interesting line from the above output is `object alignment gap`. Java objects are 8-bit aligned in memory for performance reaaons, which leads to space losses. For more details, refer to [Object Alignment][object-alignment] post from JVM Anatomy Quarks series by Aleksey Shipilëv.

More complex objects — especially in the Collection Framework — will have larger overhead on memory. From all written above, we make a simple conclusion: the less objects we have allocated on the heap — the better. You might argue that this is obvious: by storing more data we cosume more memory. Indeed, but my point here is that with more objects we have the more overhead we impose on the memory, and sometimes this overhead memory is larger than the data itself.

That is all interesting and stuff, but let's finally have a look at the problem we faced and how we managed to optimize it.

## Domain model

Here is a generalized domain model we will be working with. We have a number of stations that serve as verticles in a graph. Verticles are connected with edges. Each edge has a set of properties: we don't really care for these properties except for the `departureTimestamp`, as this is the value we need to perform the range query on. The rest of the properties will be integer values.

```java
class Edge implements Comparable<Edge> {
    int id;
    int tripId;
    int fromId;
    int toId;
    short tripLengthKm;
    byte segmentSequence;
    int departureTimestamp;
    int arrivalTimestamp;

    @Override
    public int compareTo(final Edge e) {
        return Integer.compare(departureTimestamp, e.departureTimestamp);
    }
}
```

Given that, the range query in our domain model language sounds like "find all edges departing from a particular station within an interval of two timestamp". For simplicity of calculation, we limit the number of verticles and edges: let's say 3K for verticles and 3M for edges.

Now, let's dive into the implementation with `NavigableMap`.

## Implementation with NavigableMap

This implementation is straightforward. We have a top-level `Map` with keys being the station id, and values — the instances of `TreeMap` (implementation of `NavigableMap`) where we store all edges index by their `departureTimestamp`. Since there can be multiple edges with the same depture timestamp, the values in the `NavigableMap` are of type `List<Edge>`.

```java
class MapStorage {
    /** Map of edges indexed by stop ID. Edges map is index by edge departure (multiple edges by the same departure) */
    private final Map<Integer, NavigableMap<Integer, List<Edge>>> edgesByStop = new HashMap<>();

    void load(List<Edge> edges) {
        edges.forEach(edge -> {
            edgesByStop.putIfAbsent(edge.fromId, new TreeMap<>());
            var stopEdges = edgesByStop.get(edge.fromId);
            stopEdges.putIfAbsent(edge.departureTimestamp, new ArrayList<>());
            edgesByStop.get(edge.fromId).get(edge.departureTimestamp).add(edge);
        });
    }

    List<Edge> query(int stopId, int from, int to) {
        return edgesByStop.get(stopId)
                .subMap(from, true, to, true)
                .values()
                .stream()
                .flatMap(Collection::stream)
                .collect(Collectors.toList());
    }
}
```

Our range query becomes a simple call to `subMap()`. We just have to merge the multiple lists of edge into
one. Easy-peasy. 

What about heap memory usage? Remember, we generated 3M edges for 3K stops. Again, JOL is our friend here:

```bash
com.kalimatas.MapStorage@6e0e048ad footprint:
     COUNT       AVG       SUM   DESCRIPTION
   2999855        56 167991880   [Ljava.lang.Object;
         1     16400     16400   [Ljava.util.HashMap$Node;
   3000000        40 120000000   com.kalimatas.Edge
         1        16        16   com.kalimatas.MapStorage
   3002855        16  48045680   java.lang.Integer
   2999855        24  71996520   java.util.ArrayList
         1        48        48   java.util.HashMap
      3000        32     96000   java.util.HashMap$Node
      3000        48    144000   java.util.TreeMap
   2999855        40 119994200   java.util.TreeMap$Entry
  15008423           528284744   (total)
```

Now, let's explain some of the records here:

- On top of the chain, we have one instance of `java.util.HashMap`. This is our `edgesByStop` map.
- This map has 3000 instances of `java.util.HashMap$Node`. These are `HashMap$Node<Integer, TreeMap>` instances: one node for each station ID. 96000 bytes.
- That's why we have 3000 instances of `java.util.TreeMap`. 144000 bytes.
- Our random edges generator generated 2999855 unique departure timestamps, that's why we have 2999855 instance of `java.util.TreeMap$Entry`. These are `TreeMap$Entry<Integer, List>` instances: on entry for each departure timestamp, and each of them has a list of edges. 119994200 bytes.
- That's why we have 2999855 instances of `java.util.ArrayList`. 71996520 bytes.
- Each `com.kalimatas.Edge` takes 40 bytes, and we have 3000000 of them. 120000000 bytes.
- Plus `Object` and `Integer`.

Instances of `TreeMap$Entry`, `HashMap$Node` and `[Ljava.lang.Object` are only there because this is how these data structures are implemented in Java Collections Framework: they do not really store any data, but they must be allocated in order to make these data structures functional, i.e. they are helper objects. Huge number of `ArrayList` instances is a problem of our design. 

Together they consume more than double the memory required to store actual data (3M edges with 3K stations): ~343 Mb of heap memory vs ~114 Mb. The overhead is enourmous!




[navigable-map]: https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/NavigableMap.html
[sub-map]: https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/NavigableMap.html#subMap(K,boolean,K,boolean)
[collections-framework]: https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/package-summary.html#CollectionsFramework
[object-alignment]: https://shipilev.net/jvm/anatomy-quarks/24-object-alignment/

Links

https://www.baeldung.com/jvm-measuring-object-sizes
https://developer.ibm.com/articles/j-codetoheap/
https://openjdk.java.net/projects/code-tools/jol/

https://lowtek.ca/roo/2008/java-performance-in-64bit-land/
https://www.javacodegeeks.com/2012/12/should-i-use-a-32-or-a-64-bit-jvm.html

https://stackoverflow.com/questions/258120/what-is-the-memory-consumption-of-an-object-in-java/35407947#35407947