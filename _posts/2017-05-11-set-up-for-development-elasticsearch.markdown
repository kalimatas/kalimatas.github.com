---
layout: post
title: "Elasticsearch: set up for development"
date: 2017-05-11 15:37
---

Quite often, while I'm browsing the source code of some project, I see the ways I can contribute to it by fixing some issues. Though, it's not the lack of confidence in my knowledge, that stops me most of the time. One of the main impediments (agile!) is the heavyweight process of setting up the project for development: forking, setting up an editor/IDE, running tests, etc. Usually, the more complex the project - the more complex the process. This is especially true, if this is an unfamiliar for me ecosystem.

I believe, I'm not the only one like that, and a lot of developers would be glad to contribute to some open source project, but just don't want to bother with setting up. I decided to pick up one of the projects, where I've already done that, and describe the process.

In this article I'm going to describe the process of setting up [Elasticsearch](https://www.elastic.co/products/elasticsearch) for development.

### Working with repository

First, you have to fork the source code repository, which is [https://github.com/elastic/elasticsearch](https://github.com/elastic/elasticsearch). You can read more about the process of forking in the official [GitHub help](https://help.github.com/articles/working-with-forks/), here is just a few commands to begin with.

After you've forked the repository, you'll have your own copy at `https://github.com/<your_github_username>/elasticsearch`. Now clone it to your working directory (will use SSH, not HTTPS for that). Assuming you're in your home directory:

{% highlight bash %}
$ git clone git@github.com:<your_github_username>/elasticsearch.git
{% endhighlight %}

Now, you want to have your copy of the source code to be in sync with the original repository. For that you need to add another *remote* repository:

{% highlight bash %}
$ git remote set-url upstream git@github.com:elastic/elasticsearch.git
$ git remote -v
origin	git@github.com:kalimatas/elasticsearch.git (fetch)
origin	git@github.com:kalimatas/elasticsearch.git (push)
upstream	git@github.com:elastic/elasticsearch.git (fetch)
upstream	git@github.com:elastic/elasticsearch.git (push)
{% endhighlight %}

To update your *master* branch just do:

{% highlight bash %}
$ git git fetch -p upstream
// some output here
$ git checkout master
$ git rebase upstream/master
{% endhighlight %}

Using `rebase` vs `merge` is up to you here.

### Gradle

Elasticsearch uses [Gradle](https://gradle.org/) as a build system. Check the [install](https://gradle.org/install) page for the installation instructions. Elasticsearch documentation says, that you need at least version `3.3`. On macOS you can use [Homebrew](https://brew.sh/) to install it:

{% highlight bash %}
$ brew install gradle
{% endhighlight %}


Gradle, SDK man, if specific version

IDE, IntelliJ IDEA
SDK
JAR hell (link? what, issue in Pivotal tracker)

build the project
run tests
start
debug

Making a pull request? Should or just a link to another tutorial?
