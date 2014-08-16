---
layout: post
title: "Testing apocalyptic dates with ZF and PHPUnit"
description: PHPUnit with Zend Framework
date: 2012-05-18 22:45
hhlink: http://news.ycombinator.com/item?id=3999428
---

Have you ever thought why there are so many apocalyptic dates but we are still alive? Because no one had ever tested these dates! Maybe some centuries ago people didn't have any appropriate instrument for testing, but we have. Yep, it's unit testing. Today we're going to create a Zend Framework application which will list some apocalyptic dates and write some code to test its functionality.

### The application and testing environment

You can download full source of our application at this [github page](https://github.com/kalimatas/apocalypticdates). Before you can actually run any tests you need to do something:

* install Zend Framework itself, I used 1.11.11 version;
* install [PEAR](https://pear.php.net/) for installing listed below packages;
* install PHPUnit **3.4.15** (you need exactly this version, not higher, because this is the latest version of PHPUnit supported by ZF; if you use higher version you'll get an error about not implemented methods while using functionality of Zend_Test_PHPUnit_DatabaseTestCase);
* install DBUnit 1.0.3 for testing models;
* create database and tables from [sql/apocalypticdates.sql](https://github.com/kalimatas/apocalypticdates/blob/master/sql/apocalypticdates.sql);
* create testing database by running [bin/create_test_db.sh](https://github.com/kalimatas/apocalypticdates/blob/master/bin/create_test_db.sh).

Here I'm not going to provide full instructions of how to install these soft and to make this application working -
that's boring and not related to this post. Also if you want to learn all available methods of PHPUnit this is a wrong place to start - you'd better read [official documentation](http://www.phpunit.de/manual/3.4/en/). So, I assume you already have working application at your localhost.

What features does our application have? To be honest, not much: you can see the list of available dates on the main page and create a new one by accessing `/index/new/` url and providing necessary data via POST. Nevertheless this is quite enough to create different kind of tests: simple functions (or methods) tests, controllers tests and database (in our case models) tests.  

### Basic classes

In this application I'm using two basic classes by extending which we'll get all necessary functionality for actually writing something useful (I mean not this stuff you've already bored from). You can find these classes in `library/PHPUnit` directory. Let's look at them closely.

### Testing controllers

We extend `PHPUnit_ControllerTestCase` class for testing parts specific for ZF like, for example, routing, error processing, security system, etc. Here is an example test from `IndexControllerTest`:

{% highlight php %}
<?php
public function testCreateFailAction()
{
    $this->dispatch('/index/new/');

    $this->assertModule('default');
    $this->assertController('error');
    $this->assertAction('error');
    
    // we must see an error message
    $this->assertQueryContentContains(
        "div#content h3", "No data given for new date."
    );
}
{% endhighlight %}

`PHPUnit_ControllerTestCase` in its turn is extended from `Zend_Test_PHPUnit_ControllerTestCase`, it means that we can use specific for Zend Framework assertions like, for example, `assertModule`.  

In case you need to test some action which needs database interaction, just implement `setUpDatabase` method in your test class as in our example test class. This method is called before every test method (actually in setUp), so you'll have your tables truncated and populated from fixtures you provide before each test.

### Testing database

First, insure you've created testing database with  `bin/create_test_db.sh` script and set right database name in configuration for testing environment. Why? Because you'll die. Just kidding. Because every time you run a test which requires working with database your tables will be truncated, and I suppose you don't want your production base be truncated.

For testing models we extend our test classes from `PHPUnit_DatabaseTestCase`.  In this case we **must** implement `getDataSet` method which acts like previously described `setUpDatabase` method. Look at the example.

{% highlight php %}
<?php
/**
 * Should pass :))
 */
public function testWhetherHasNotHappened()
{
    $happenedDates = $this->_table->fetchAll(
        $this->_table->select()
            ->where('happened = ?', 1)
    );

    $this->assertEquals($happenedDates->count(), 0);
}
{% endhighlight %}

Here `$this->_table` refers to `Apoc_Model_Date_Table` model so we can use all it's functionality.
Quite simple.

### Running tests

Examples of running tests of this application:

{% highlight bash %}
$ cd tests
# run all tests
$ phpunit . 
# run tests from specific directory
$ phpunit application/controllers
# run tests from file
$ phpunit application/controllers/IndexControllerTest.php
{% endhighlight %}

That's it. Code itself is the best narrator :))