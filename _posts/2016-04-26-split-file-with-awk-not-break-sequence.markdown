---
layout: post
title: "Split file in chunks without breaking the sequence with GAWK"
date: 2016-04-26 23:01
---

Today I came up with a task for myself, mostly for fun, but it also has a useful application. I have a dump of some MySQL table in `csv`, it’s ~500K records. The data will be loaded into Neo4j, though I want to speed up the load and be able to parallelize the process. Of course, I can make it in any programming language, but I decided to practice with Linux shell commands and to use [gawk](https://www.gnu.org/software/gawk/).

The example structure of the file is like this:

{% highlight shell %}
Title,Id,Sequence
"eee",3,2
"hhh",1,2
"bbb",2,1
"hhh",1,3
"kkk",4,1
"hhh",1,1
"bbb",2,2
"eee",3,1
"eee",3,3
{% endhighlight %}

There is a requirement: records with the same `Id` column must be processed together. Basically, that means, they cannot be in different chunks, even if we exceed the limit of a chunk a little, say, have 1003 records instead of 1000.

The first step would be to sort the file by `Id` column. But it will be even easier for my loader to work, if the file is sorted secondary by the `Sequence` column. To simplify, let’s get rid of the header too.

{% highlight shell %}
$> awk 'BEGIN { getline; } { print $0 }' test.csv > test_without_header.csv
{% endhighlight %}

A little explanation. AWK's BEGIN statement is executed only once - before processing the first line. Here `getline;` will just read the header line, but it won’t be printed, so the real output with `print $0` will start actually from the second line. Now sort:

{% highlight shell %}
$> sort -k2n -k3n --field-separator "," test_without_header.csv > test_sorted.csv
{% endhighlight %}

`-k2` means sort by the column number `2` (initial is `1`), `n` means numerical sort. The same for the secondary sort. In MySQL the same result will be achieved with `ORDER BY Id ASC, Sequence ASC`. `--field-separator` is necessary, because the default separator is a space, but we have a comma. Now we have this:

{% highlight shell %}
"hhh",1,1
"hhh",1,2
"hhh",1,3
"bbb",2,1
"bbb",2,2
"eee",3,1
"eee",3,2
"eee",3,3
"kkk",4,1
{% endhighlight %}

Let’s assume we want to split the file into chunks by 2 records. The natural approach with [split](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/split.html) doesn't work, because it breaks the sequence. Indeed, if we do like:

{% highlight shell %}
$> split -l 2 test_sorted.csv
$> cat xaa
"hhh",1,1
"hhh",1,2
$> cat xab
"hhh",1,3
"bbb",2,1
{% endhighlight %}

The third record with `Id = 1` got to the second chunk, but should be in the first. To solve the problem I played around with AWK a little and wrote the following script:

{% highlight shell %}
# split.awk
#
# Initialise values.
# This block will be executed only once before
# processing the first line.
BEGIN {
    records_limit_per_chunk = 2
    records_currently_in_chunk = 0
    chunk_number = 1
    prev = -1
    chunk_limit_is_hit = 0
}

# Process current line
{
    # If the limit is hit and we are not
    # in the middle of a sequence.
    # $2 means the second column, which is Id in our case.
    if (chunk_limit_is_hit && prev != $2) {
        chunk_number++
        records_currently_in_chunk = 0
    }

    # Write line to a chunk
    file = "chunk_" chunk_number
    print $0 > file
    ++records_currently_in_chunk

    # Test the limit
    if (records_currently_in_chunk >= records_limit_per_chunk) {
        chunk_limit_is_hit = 1
    }

    # Save previous Id value
    prev = $2
}
{% endhighlight %}

Run the script:

{% highlight shell %}
$> gawk -F, -f split.awk test_sorted.csv
{% endhighlight %}

Pay attention to `-F,` argument, which says to use `,` as a field separator. `-f split.awk` means to load script from file. For our input file it creates 4 chunks with the following content:

{% highlight shell %}
$> cat chunk_1
"hhh",1,1
"hhh",1,2
"hhh",1,3
$> cat chunk_2
"bbb",2,1
"bbb",2,2
$> cat chunk_3
"eee",3,1
"eee",3,2
"eee",3,3
$> cat chunk_4
"kkk",4,1
{% endhighlight %}

Exactly what I need: the records with ids `1` and `3` are in the same chunk, though its size is larger than the limit of 2 records.
