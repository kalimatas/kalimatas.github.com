---
title: "Will for deep knowledge"
layout: post
date: 2012-05-30 22:32
hhlink: http://news.ycombinator.com/item?id=4042320
---

I'd like to do something useful. No kidding. Something I or someone else could use. When I come up with some idea I start to think about details and about what technologies I should use for its implementation. Speaking about technology I want to say that I prefer using something I've never used before. And here lies the rub. When I start to learn something I start with the idea of getting some satisfactory level of deep knowledge of the subject, not only some basic understanding enough only for "hello world".

For example, I wanted to create a small web app which will help me to send POST request (need for my current job project). I've chosen Python and [Flask](http://flask.pocoo.org) as technologies, mostly because I'm learning Python now. Ok, let's read what Flask is. Hm, it's based on Werkzeug and Jinja2. Well, let us a look at them. WSGI? What's that? 

After some time I found myself sitting in front of my computer with VIM opened and a few lines of code there:

{% highlight python %}
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from wsgiref.simple_server import make_server

def app(environ, start_response):
    start_response('200 Ok', [('Content-type', 'text/html')])
    return ['Hello from wsgi!']

httpd = make_server('', 8005, app)
httpd.serve_forever()
{% endhighlight %}

That's too far away from my initial task as you understand. So what happened? 

When I started to read about Flask it turned out that I don't want to use it until I get a deeper understanding of its underlying mechanisms. The same about Werkzeug and Jinja.  Don't know whether I should cry or laugh. On the one hand this will for deep knowledge serves me well - after spending some hours/days/weeks/months of reading and trying I feel like a pro in the subject. But on the other hand I spent my time learning and not doing something really useful.  

Remember the beginning of the post?

