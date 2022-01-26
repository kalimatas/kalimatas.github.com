---
title: "Missing Code Review Advice"
description: "Can we make code reviews better?"
date: 2018-07-10 14:54
---

We all know that code reviews are important and have a lot of value. There is plenty of "best practices"
articles telling you how you should do a code review, when, at which pace, on which Moon cycle, which SMARTass
criterias to prepare, etc. [^1][^2]

I believe they miss one piece of advice.

There are two types of changes you as a code reviewer can propose to do: the ones that involve some huge
effort, and the ones that do not. The examples of the former are architectural changes, missing functionality,
wrong interpretation of requirements, etc. Among the latter are code style issues, typos, redundant comments,
missing type hints, obvious small bugs, etc.

Whenever you see these small issues, instead of writing a comment to fix it,
_just switch to the branch, fix it yourself and push to the repository_.

This approach has several benefits. First, you save a lot of time for both of you: the developer who submitted
a merge request does not need to be distracted by another notification, and you do not need to re-check the
change later in the next round.

Second, it reduces the amount of those ping-pong code review rounds.

Third, you immediately feel responsibility for this code, which is good, because in the end it is _not_
someone else's code - it is _your_ code also. You may be the one to fix a bug in it next week.

## Notes

[^1]: <a href="https://medium.com/palantir/code-review-best-practices-19e02780015f">Code Review Best Practices</a>
[^2]: <a href="https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/">These 10 tips will guide you toward effective peer code review</a>
