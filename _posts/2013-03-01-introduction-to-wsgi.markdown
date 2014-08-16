---
title: Introduction to WSGI
layout: post
description: Python and WSGI example
date: 2013-03-01
---

The **Web Server Gateway Interface (WSGI)** is a universal interface between web servers and web applications for Python. _Universal_ means there is no more need to design your application for a specific API interface of a web server like CGI, FastCGI, mod_python, etc. - implementing WSGI support in your application gives you opportunity to use it with any web server which in it's turn has WSGI support.  

I highly recommend reading [PEP333](http://www.python.org/dev/peps/pep-0333/) with full specification, here is just a bare minimum:

* the WSGI interface has two sides: the server/gateway and the application side; beside this strict distinction there are so called "middleware" components which implement server and application sides at the same time;
* WSGI application is a callable object (a function, method, class, or an instance with a `__call__` method) that accepts two **positional** arguments: WSGI environment variables and a callable with two required positional arguments which starts the response;
* the server side invokes the callable object which returns response.

### Basic example
Here is a simple example.

{% highlight python %}
from urlparse import parse_qs

class Greetings:
    def __call__(self, environ, start_response):
        params = parse_qs(environ.get('QUERY_STRING'))
        name = 'Alex'
        if 'name' in params:
            name = params.get('name')[0]
        start_response('200 Ok', [('Content-type', 'text/plain')])
        return ['My name is {0}'.format(name)]
{% endhighlight %}

This application greets someone called Alex (me actually) or a person whose name is specified via url. The `Greetings` class is our callable object with two required positional arguments which is invoked by a server side. Pay attention to the fact that there are other variants of implementing a callable object: we could create a class with `__iter__` method which would *yield* the result, or, simply, create a function without any classes. Regardless of your choice of a callable object it's first parameter is an environment dictionary object. As the second parameter it accepts a callable which starts response and is invoked with two parameters: status string and a list of tuples with headers information. 

In order to test this application we can use any web server with WSGI support. For tests purposes there is a `wsgiref` module from standard Python library. At the end of our file: 

{% highlight python %}
if __name__ == "__main__":
	from wsgiref.simple_server import make_server
	httpd = make_server('', 8005, Greetings())
	httpd.serve_forever()
{% endhighlight %}

After starting the app and pointing your browser to `http://localhost:8005/?name=John` you will see a request log in the console.

{% highlight bash %}
$ python wsgi.py 
1.0.0.127.in-addr.arpa - - [01/Mar/2013 21:36:40] "GET /?name=Jonh HTTP/1.1" 200 15
{% endhighlight %}

### What is a middleware?
Middleware applications play the role of a server for their contained applications and, at the same time, look like an application to their containing server. They can be used to:

* routing to a different URL based on `environ` parameters;
* logging;
* handling exceptions;
* perform any kind of preprocess/postprocess operations.

Middleware application acts like a wrapper around another application, which in it's turn can could be a middleware for another application and so on. In this case you create a so called "middleware stack". Let's have a look at the example - our application will add to the result of it's underlying application a string with information about the size of the result. 

{% highlight python %}
class ResultMiddlware:
    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        # the size of the result returned by self.app
        size = 0

        # call the application
        appiter = self.app(environ, start_response)
        for r in appiter:
            size += len(r)
            yield r

        yield '\n\nResult length: ' + str(size)

        # the application might define a close method
        # which must be called
        if hasattr(appiter, 'close'):
            appiter.close()
{% endhighlight %}

And change the invoking part:

{% highlight python %}
if __name__ == "__main__":
	from wsgiref.simple_server import make_server
    application = ResultMiddlware(Greetings())
    httpd = make_server('', 8005, application)
    httpd.serve_forever()
{% endhighlight %}

### Conclusion 
WSGI is no doubt a great piece of technology which brings some standardization to a zoo of existing technologies in Python web area. But as it is rightly mentioned in PEP333 WSGI is a tool for frameworks and server developers, and is not intended to directly support application developers. Thus consider using existing libraries and frameworks with WSGI support for your applications. Have a look at [Werkzeug](http://werkzeug.pocoo.org/) and [Flask](http://flask.pocoo.org/), it's a good point to start from (or maybe stop at).