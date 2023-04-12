---
layout: post
title: "Atomic Change of an Index in MySQL"
date: 2016-06-25 15:52
---

Imagine you have a composite index on four columns, and you need to remove one column from the index. The obvious solution would be to re-create the index:
 
{% highlight sql %}
DROP INDEX idx ON test_table;
CREATE INDEX idx ON test_table (column1, column2, column3);
{% endhighlight %}

But after the `DROP` statement there is no index at all, which is, of course, bad for performance. Especially on a production system. The other way would be to re-create the index in one `ALTER TABLE` statement:

{% highlight sql %}
ALTER TABLE test_table
DROP INDEX idx,
ADD KEY idx (column1, column2, column3);
{% endhighlight %}

<!--more-->

I was wondering how *atomic* this statement was, i.e. if internally it actually just executes `DROP` and `CREATE`, thus making a time window, when there is no index, or uses some other technique to make this change not so painful. I made a test table with four fields (except `id`), and populated it with 500K random records. The size of the table was 28Mb. Then created composite index on four columns (the size increased to 36Mb). A test query:

{% highlight sql %}
mysql> EXPLAIN SELECT * FROM atomic WHERE field1 = 30 AND field2 = 69370;
+----+-------------+--------+------+---------------+------+---------+-------------+------+-------------+
| id | select_type | table  | type | possible_keys | key  | key_len | ref         | rows | Extra       |
+----+-------------+--------+------+---------------+------+---------+-------------+------+-------------+
|  1 | SIMPLE      | atomic | ref  | idx           | idx  | 8       | const,const |    1 | Using index |
+----+-------------+--------+------+---------------+------+---------+-------------+------+-------------+
1 row in set (0.00 sec)
{% endhighlight %}

Ok, the index is in place and is used. At this point I did an experiment to see how the size of `.ibd` file changes if I just re-create the index with separate `DROP` and `CREATE` statements. As expected, the size stayed the same - 36Mb.

Then I did that: in one session ran an `ALTER TABLE` statement with `DROP/ADD`, and while it was running, in the other session I executed the already mentioned `SELECT` statement, to see if the index was still used. The answer is - **yes**, it was still used during the execution of the `ALTER TABLE`.
 
Also, I checked the size of the `.ibd` file after changing the index. It increased to 44Mb. It might mean, that MySQL created a temporary index with different number of columns (that's why the size increased), and then just updated the table's metadata to use the new index.
