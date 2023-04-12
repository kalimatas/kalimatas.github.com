---
layout: post
title: "Tie-breaking Rounding"
date: 2017-05-14 16:14
---

So I was reading an article about [differences between Python 2 and Python 3][python-diff], and there was a statement:

> Python 3 adopted the now standard way of rounding decimals when it results in a tie (.5) at the last significant digits. Now, in Python 3, decimals are rounded to the nearest even number.

At this point, I was like "WTF?!". At school I was taught a simple rule: if x is exactly half-way between two integers - round to the largest absolute value, i.e. 13.5 becomes 14, and -13.5 becomes -14. No magic with even/odd numbers. It wasn't even discussed, that there are might be different ways of rounding. 

But, as it often happens with school program, they didn't tell us all the truth. 

There are actually six more or less normal ways and two not so normal, thus leaving us with eight (eight, Carl!) rules of rounding. 

<!--more-->

These are the *normal* [rules][tie-breaking]:

* Round half down (or towards negative infinity): 13.5 rounds to 13, -13.5 rounds to -14.
* Round half up (or towards positive infinity): 13.5 rounds to 14, -13.5 rounds to -13.
* Round half towards zero: 13.5 rounds to 13, -13.5 rounds to -13.
* Round half away from zero: 13.5 rounds to 14, -13.5 rounds to -14. *I believe, this is the rule I was taught at school*.
* Round half to even: 13.5 rounds to 14, -13.5 rounds to -14, but 14.5 *also rounds* to 14, and -14.5 rounds to -14.
* Round half to odd: Opposite of the previous rule. 13.5 rounds to 13, -13.5 rounds to -13, 14.5 rounds to 15, -14.5 rounds to -15.

And these are some *not so normal*:

* Stochastic rounding: the choice of the result is... *random*!.
* Alternating tie-breaking: this just alternate round up and round down for.

## Rounding in programming languages 

Just out of curiousity I checked how rounding works in a few popular programming languages. It seems like most of them use *Round half away from zero* rule, the most logical for me, since I was taught it as school. 

So, this is what you'll get in C, PHP 7, Python 2, Ruby 2:

{% highlight c %}
// C's printf
printf("%g -> %g, %g -> %g, %g -> %g, %g -> %g\n", 
    13.5, round(13.5), 14.5, round(14.5), -14.5, round(-14.5), -13.5, round(-13.5));

// output: 13.5 -> 14, 14.5 -> 15, -14.5 -> -15, -13.5 -> -14
{% endhighlight %}

But, as was already mentioned, Python3 uses *Round half to even*, and it will be:

{% highlight python %}
>>> print('%.1f -> %d, %.1f -> %d, %.1f -> %d, %.1f -> %d' \
... % (13.5, round(13.5), 14.5, round(14.5), -14.5, round(-14.5), -13.5, round(-13.5)))

// output: 13.5 -> 14, 14.5 -> 14, -14.5 -> -14, -13.5 -> -14
{% endhighlight %}

What's more surprising for me is that Java 8 also uses another rule - I guess it is *Round half towards zero*:

{% highlight java %}
System.out.printf("%.1f -> %d, %.1f -> %d, %.1f -> %d, %.1f -> %d\n",
    13.5, Math.round(13.5), 14.5, Math.round(14.5), -14.5, Math.round(-14.5), -13.5, Math.round(-13.5));

// output: 13.5 -> 14, 14.5 -> 15, -14.5 -> -14, -13.5 -> -13
{% endhighlight %}

Go 1.8 doesn't have built-in [round function][add-round] at all, you have to choose from [math.Ceil](https://golang.
org/pkg/math/#Ceil) or [math.Floor](https://golang.org/pkg/math/#Floor) yourself.

## Conclusion

Well, beware of different rules in different programming languages!

[python-diff]: http://sebastianraschka.com/Articles/2014_python_2_3_key_diff.html#bankers-rounding
[tie-breaking]: https://en.wikipedia.org/wiki/Rounding#Tie-breaking
[add-round]: https://github.com/golang/go/issues/4594