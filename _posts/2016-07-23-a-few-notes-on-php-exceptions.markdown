---
layout: post
title: "A Few Notes on PHP Exceptions"
date: 2016-07-23 20:30
---

There are several practices, that I found myself using over and over again while working with PHP exceptions. Here they are.

#### Package/component level exception interface

Create an interface that represents the top level of exceptions hierarchy for your package/component/module. This interface is known as a [Marker interface](https://en.wikipedia.org/wiki/Marker_interface_pattern). This approach has several advantages. First, it allows clients of your code to distinguish these component specific exceptions from others. Second, as PHP doesn't support multiple inheritance, using an interface allows the exceptions to extends from other exceptions. e.g. [SPL exceptions](https://secure.php.net/manual/en/spl.exceptions.php).

Here is an example wth usage:

{% highlight php %}
<?php
namespace some\package {
    // Common package level exception
    interface Exception extends \Throwable {}

    class InvalidArgumentException extends \InvalidArgumentException
        implements Exception {}
}

namespace {
    try {
        // Do something
    } catch (some\package\Exception $e) {
        // All package specific exceptions
    } catch (Exception $e) {
        // Other exceptions
    }
}
{% endhighlight %}

#### Factory methods to create exceptions

It is quite often, that exception's message is long and contains some placeholders. Generating this message, especially if you throw it in different places, is not very convenient. In this case a factory method will hide this complexity. Imaging, you are doing something like this:

{% highlight php %}
<?php
interface SomeInterface {}
$c = new stdClass();
if (!($c instanceof SomeInterface)) {
    throw new some\package\UnexpectedValueException(
        sprintf('Argument is of type "%s", but expecting "%s"', get_class($c), SomeInterface::class)
    );
}
{% endhighlight %}

But instead, it would me much more cleaner to do this:

{% highlight php %}
<?php
class UnexpectedValueException extends \UnexpectedValueException
    implements Exception
{
    public static function wrongType($given, $expected)
    {
        return new self(
            sprintf('Argument is of type "%s", but expecting "%s"', $given, $expected)
        );
    }
}

// Calling code
use some\package\UnexpectedValueException;

if (!($c instanceof SomeInterface)) {
    throw UnexpectedValueException::wrongType(get_class($c), SomeInterface::class);
}
{% endhighlight %}

#### Extended exceptions with additional details

There are cases, when we need to perform additional actions in `catch` block. For that we often need to know the details about the original arguments, that caused the exception. For instance, you're catching a `DuplicatedAccountException`, and want to know the e-mail, that was passed to a registration service. It might be quite easy, if the call to a service and the `catch` block are in the same context:

{% highlight php %}
<?php
class DuplicatedAccountException extends \LogicException {}

class RegistrationService
{
    public function register($email)
    {
        throw new DuplicatedAccountException(sprintf('Account with %s email alread exists.', $email));
    }
}

// Calling code
$email = 'test@test.com';
$registrationService = new RegistrationService();

try {
    $registrationService->register($email);
} catch (DuplicatedAccountException $e) {
    echo 'Error: ' . $e->getMessage() . PHP_EOL;

    // Do something else with $email. We can do that
    // because we are in the same context, i.e. in one method.
}
{% endhighlight %}

But it is quite common, when you are catching an exception, that is thrown from some deeply nested method, and you don't have access to the context. In this case, it is helpful to have this information _attached_ to the exception itself.

{% highlight php %}
<?php
class DuplicatedAccountException extends \LogicException
{
    private $originalEmail;

    public function __construct($originalEmail, $code = 0, Exception $previous = null)
    {
        $this->originalEmail = $originalEmail;

        parent::__construct(
            sprintf('Account with %s email alread exists.', $originalEmail),
            $code,
            $previous
        );
    }

    public static function create($originalEmail)
    {
        return new self($originalEmail);
    }

    public function getOriginalEmail()
    {
        return $this->originalEmail;
    }
}

// Calling code
try {
    // Some actions…
} catch (DuplicatedAccountException $e) {
    // Do something with $originalEmail.
    echo 'Original email: ' . $e->getOriginalEmail() . PHP_EOL;
}
{% endhighlight %}
