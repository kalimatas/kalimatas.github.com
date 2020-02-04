---
layout: post
title: "Covariance and contravariance in programming"
description: "Short intro to variance in type systems"
date: 2020-02-04 09:00
---

Whenever I hear "covariant return type", I have to pause and engage my 
System 2 [[1]](#1) thoroughly in order to understand what I have just heard. 
And even then, I cannot bet I will answer properly what it means. So this serves
 as a memo for me of the concept of variance [[2]](#2) in programming.

The notion of variance is related to the topic of subtyping [[3]](#3) in 
programming language theory. It deals with rules of what is allowed or not with 
regards to function arguments and return types. 

Variance comes in four forms:

* invariance
* covariance
* contravariance
* bivariance (will skip that)

Before we dive into explanations, let us agree on pseudo code that I am going 
to use. The `>` operator shows subtyping. In the example

```
Vehicle > Bus
```

`Bus` is a subtype of `Vehicle`. Functions are defined with the following syntax:

```
func foo(T): R
```

where `T` is a type of an argument, and `R` is a return type of a function `foo`.
Functions can also override another functions (think "override of a method 
in Java"). Here, `bar` overrides `foo`:

```
func foo(T): R > func bar(T): R
```

Throughout the example, I will be using this hierarchy of objects.

```
Vehicle > MotorVehicle > Bus
```

## Invariance

Invariance is the easiest to understand: it does not allow anything - neither 
supertype nor subtype - to be used instead of a defined function argument or 
return type in inherited functions. For instance, if we have a function:

```
func drive(MotorVehicle)
```

Then the only possible way to define an inherited function is with `MotorVehicle` 
argument, but not `Vehicle` or `Bus`.

```
func drive(MotorVehicle) > func overrideDrive(MotorVehicle)
```

Same goes for return types.

```
func produce(): MotorVehicle > func overrideProduce(): MotorVehicle
```

This way, the type system of a language doesn't allow you much flexibility,
but protects you from many possible type errors.

## Covariance

Covariance allows subtypes or, in other words, more specific types to be used 
instead of a defined function argument or return type. Let's start with return 
types. **Return types are covariant**. Let's look at these two functions:

```
func produce(): MotorVehicle > fn overrideProduce(): Bus
```

Is it OK that `overrideProduce` returns more concrete `Bus` instead of 
`MotorVehicle`? Yes, it is! Since `Bus` is a type of `MotorVehicle`, it meets 
the contract, because it supports everything a `MotorVehicle` can do. So this 
is allowed:

```
motorVehicle = product()
motorVehicle = overrideProduce()
```

In this case, for the calling code there is no difference whether `motorVehicle`
variable has a `MotorVehicle` instance or a `Bus`.

But what about function arguments? Is this definition fine?

```
func drive(MotorVehicle) > func overrideDrive(Bus)
```

This is actually not allowed by a safe type system, because `overrideDrive` 
breaks parent's contract. Users of `drive` expect to be able to pass any type 
of `MotorVehicle`, not only `Bus`. Indeed, imagine someone calls `drive` with, 
let's say a `Car` (where `MotorVehicle > Car`), then the call to `overrideDrive`
will be `overrideDrive(Car)`, but `overrideDrive` works only with `Bus` instances.
So function arguments are not covariant. And here we approach contravariance.

## Contravariance

Contravariance allows supertypes or, in other words, more abstract types to be 
used instead of a defined type. **Function arguments are contravariant**. 
Let's have a look at the example.

```
func drive(MotorVehicle) > func overrideDrive(Vehicle)
```

Though it looks counterintuitive, this is a perfectly valid case. 
`overrideDrive` meets parent's contract: it supports any `Vehicle`, and since 
`MotorVehicle` is a type of `Vehicle`, users of `drive` still can pass any 
instance of `MotorVehicle`.

## References

<ul id="notes">
<li>
	<span class="col-1">[1] <a name="1"></a></span>
	<span class="col-2"><a href="https://en.wikipedia.org/wiki/Thinking,_Fast_and_Slow#Two_systems">The concept of System 2 is from the book "Thinking, Fast and Slow"</a></span>
</li>
<li>
	<span class="col-1">[2] <a name="2"></a></span>
	<span class="col-2"><a href="https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)">Covariance and contravariance</a></span>
</li>
<li>
	<span class="col-1">[3] <a name="3"></a></span>
	<span class="col-2"><a href="https://en.wikipedia.org/wiki/Subtyping">Subtyping</a></span>
</li>
</ul>
