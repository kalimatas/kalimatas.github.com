---
layout: post
title: "\"const\" keyword in C"
date: 2017-05-12 17:38
---

> **const** qualifier is used to tell the compiler, that the specified variable is going to have a *constant* value.

> Yours sincerely, Captain

But seriously. If you don't want the variable to be modified throughout the program's execution, you declare it with `const` qualifier. Quick example (boilerplate code is skipped):

{% highlight c %}
const int i = 42;
i = 43;
{% endhighlight %}

Try to compile the program and you'll see an error message like that:

{% highlight bash %}
const_error.c:6:11: error: cannot assign to variable 'i' with const-qualified type 'const int'
        i = 43;
        ~ ^
const_error.c:5:19: note: variable 'i' declared const here
        const int i = 42;
        ~~~~~~~~~~^~~~~~
{% endhighlight %}

If you want to use a variable to indicate the array size - it must be declared with `const`. Try this code:

{% highlight c %}
int i = 42; 
int arr[i] = {};
{% endhighlight %}

The error will be similar to this:

{% highlight bash %}
const_error_array.c:6:17: error: variable-sized object may not be initialized
        int arr[i] = {};
                ^
{% endhighlight %}

It has to be:

{% highlight c %}
const int i = 42;
int arr[i] = {};
{% endhighlight %}

what is used for

what can be constant
how to define: declaration/arguments
gotchas? how to overcome? 
