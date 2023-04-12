---
layout: post
title: "Broken Code Theory"
date: 2016-04-24 23:45
---

I have recently come across [Broken windows theory](https://en.wikipedia.org/wiki/Broken_windows_theory) article. It is a criminological theory which addresses the problems of urban disorder, vandalism and anti-social behavior. The theory states that:

> … maintaining and monitoring urban environments to prevent small crimes such as vandalism, public drinking, and toll-jumping helps to create an atmosphere of order and lawfulness, thereby preventing more serious crimes from happening.

The theory was introduced in a 1982 article by social scientists James Q. Wilson and George L. Kelling in an article titled [Broken Windows](http://www.theatlantic.com/magazine/archive/1982/03/broken-windows/304465/), where they had an example:

> Consider a building with a few broken windows. If the windows are not repaired, the tendency is for vandals to break a few more windows. Eventually, they may even break into the building, and if it's unoccupied, perhaps become squatters or light fires inside.

<!--more-->

The authors suggested to prevent vandalism by addressing the problems when they are small and easy to manage with.

I think the same theory can be applied to software development - writing “bad” code may be observed as a vandalism. We often find ourselves in situations in which we can accomplish some task in two ways: either program a clean, robust solution (often meaning complex and long) or make a quick dirty hack. By that time the code may be in two states:

1. The code is clean and there no dirty hack.
2. There are dirty hacks.

Guess when will you be more tempted to add "just another small hack, that no one will notice”? Exactly. In the second case. After all, you have deadlines. But you’ll definitely feel uncomfortable, if you need to do that in the first case, just because there seem to be is an established norm of clean code, that you don’t want to break.

In ideal world, the code is always perfect, but in real world it tends to become over the time a collection of small (sometimes not so small) fixes. To prevent that, like with an ordinal vandalism, the hacks should be removed/replaces as soon as possible. By adding another **small fix** you not only making an obvious poor design decision, but also send the other the message “Go, add more of them!”.
