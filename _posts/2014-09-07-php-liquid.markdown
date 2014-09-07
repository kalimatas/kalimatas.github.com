---
layout: post
title: "Liquid engine for PHP"
description: Liquid engine for PHP, fork improvements
date: 2014-09-07 21:00
---

I've just finished working on my [fork](https://github.com/kalimatas/php-liquid) of the Liquid template engine.

[Liquid](http://liquidmarkup.org/) is a templating library which was originally developed for usage with Ruby on Rails in [Shopify](http://www.shopify.com/). It uses a combination of _tags_, _objects_, and _filters_ to load dynamic content. They are used inside Liquid _template files_, which are a group of files that make up a theme.

Here is a simple example:

{% highlight php %}
{% raw %}
<?php

use Liquid\Template;

$template = new Template();
$template->parse("Hello, {{ name }}!");
echo $template->render(array('name' => 'Alex');

// Will echo
// Hello, Alex!
{% endraw %}
{% endhighlight %}

The [implementation](https://github.com/harrydeluxe/php-liquid) my fork is based on was a little outdated and I decided that I could make some improvements to it.

### Namespaces

Namespaces were added. Now all classes are under `Liquid` namespace. The library now implements [PSR-4](http://www.php-fig.org/psr/psr-4/). The minimum required PHP version is `5.3` now.

### Composer

You can now install the library via composer. Here is the package's [page](https://packagist.org/packages/liquid/liquid).

{% highlight bash %}
composer create-project liquid/liquid
{% endhighlight %}

### New standard filters

Implemented new standard filters: `sort`, `sort_key`, `uniq`, `map`, `reverse`, `slice`, `round`, `ceil`, `floor`, `strip`, `lstrip`, `rstrip`, `replace`, `replace_first`, `remove`, `remove_first`, `prepend`, `append`.

For the full list of supported filters read the Ruby implementation's [wiki page](https://github.com/Shopify/liquid/wiki).

### New tags

`raw` tag was added. The implementation of `unless` tag is in plans. You're welcome to contribute.
