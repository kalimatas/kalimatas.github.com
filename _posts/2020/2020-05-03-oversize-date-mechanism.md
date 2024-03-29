---
layout: post
title: "Welcome to March 32nd"
description: "Why does the day window on a watch show 32nd day? Because of the outsize date (oversize) mechanism."
date: 2020-05-03 14:00
---

My wife and I both have watches with the date window - the one that shows the day of the month. At the end of March,
nearly midnight, my watch's date window switched to number "1", which stands for April 1st. Though my wife's watch
started to show number "32" instead. I was curious why, and found out that it is because of so called outsize date
mechanism.

The standard date mechanism is made of a single ring with numbers from 1 to 31 printed on it. The ring gradually rotates,
and eventually switches to another number. My watch has this mechanism. The "problem" is that this way the window size,
and thus the size of a number inside, is small, because the ring has to fit into the frame.

<!--more-->

The feature that allows to have a larger "font size" in date windows goes under the name 
[the oversize date complication](https://www.tourneau.com/watch-education/watch-complications.html).
This feature utilizes two pieces for displaying the date: units disc and tens cross, which are nicely synchronized.
Tens cross has numbers from 0 to 3, and unit disc - from 0 to 9. The final day of the month is then a combination of two
digits from both pieces.

This video has a nice visual explanation of the outsize date mechanism.

{% youtube YouzFPSD77o %}

So why does my wife's watch show 32? Well, it actually goes up to 39! It seems that in some "cheap" implementations of
the oversize date mechanism, the tens cross and the unit disc do not have proper synchronization. After the tens cross
switched from 3 to 0, indicating the beginning of a new month, the unit disc just continues to rotate further to 2, 3, 4, etc. 