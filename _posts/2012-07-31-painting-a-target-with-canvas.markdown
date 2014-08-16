---
title: Painting a target with canvas
layout: post
description: JavaScript canvas example
date: 2012-07-31
hhlink: http://news.ycombinator.com/item?id=4318178
---

After playing with [canvas](http://en.wikipedia.org/wiki/Canvas_element) for some time I gave a birth to this small piece of... code. If you don't have any idea what it is I'll give you a hint. It's a gradually appearing target created with the help of HTML5 canvas element. 5 elements actually.

The idea is simple: create several canvas elements with different radius values and absolutely position them at the same point. Step by step drawing is archived by repeatedly calling a *drawCircle* function with different values of radius property until it reaches `Math.PI * 2`.

<div style="position: relative;">
<div id="can_div" style="width: 300px; height: 300px;"></div>
</div>

That's it. View source for code.

{% highlight javascript %}
<script type="text/javascript">
var canvas;
var PI2 = Math.PI * 2;
var elements = [];
var colors = ['#C9F24B', '#736859', '#B8925A', '#8C3F3F', '#FFD63E'];
var intervals = [];
var time = 15;

function createElements() {
    for (var i=0; i<=4; i++) {
        elements[i] = {
            'radius': (i+1) * 20,
            'style': colors[i],
            'size': 300,
            'circle': null
        };
    }
}

function init() {
    canvas = document.getElementById('can_div');
    createElements();

    delta = 0.01;
    angle = 0;
    for (var i=elements.length-1; i>=0; i--) {
        var elem = elements[i];
        var circle = createCircle(elem.size);
        intervals[i] = createInterval(elem, circle);
    }
}

function createInterval(elem, circle) {
    return setInterval(function () {
    	drawCircle(circle, 130, 130, elem.radius, elem.style);
   	}, time);
}

function createCircle(size) {
    var circle = document.createElement("canvas");
    circle.width = size;
    circle.height = size;
    circle.style.position = 'absolute';
    circle.style.left = "100px";
    circle.style.top = 0;
    canvas.appendChild(circle);
    return circle;
}

function drawCircle( can, x, y, radius, style) {
    var context = can.getContext("2d");
    context.clearRect(0, 0, 600, 600);
    context.fillStyle = style;
    context.beginPath();
    context.arc(x, y, radius, 0, angle, false);
    context.lineTo(x, y);
    context.closePath();
    context.fill();

    angle += delta;
    if (angle >= PI2 + 0.5) {
        for (var i=0; i<intervals.length; i++) {
            clearInterval(intervals[i]);
        }
    }
}

init();
</script>
{% endhighlight %}

<script type="text/javascript">
var canvas;
var PI2 = Math.PI * 2;
var elements = [];
var colors = ['#C9F24B', '#736859', '#B8925A', '#8C3F3F', '#FFD63E'];
var intervals = [];
var time = 15;

function createElements() {
    for (var i=0; i<=4; i++) {
        elements[i] = {
            'radius': (i+1) * 20,
            'style': colors[i],
            'size': 300,
            'circle': null
        };
    }
}

function init() {
    canvas = document.getElementById('can_div');
    createElements();

    delta = 0.01;
    angle = 0;
    for (var i=elements.length-1; i>=0; i--) {
        var elem = elements[i];
        var circle = createCircle(elem.size);
        intervals[i] = createInterval(elem, circle);
    }
}

function createInterval(elem, circle) {
    return setInterval(function () {
    	drawCircle(circle, 130, 130, elem.radius, elem.style);
    	}, time);
}

function createCircle(size) {
    var circle = document.createElement("canvas");
    circle.width = size;
    circle.height = size;
    circle.style.position = 'absolute';
    circle.style.left = "100px";
    circle.style.top = 0;
    canvas.appendChild(circle);
    return circle;
}

function drawCircle( can, x, y, radius, style) {
    var context = can.getContext("2d");
    context.clearRect(0, 0, 600, 600);
    context.fillStyle = style;
    context.beginPath();
    context.arc(x, y, radius, 0, angle, false);
    context.lineTo(x, y);
    context.closePath();
    context.fill();

    angle += delta;
    if (angle >= PI2 + 0.5) {
        for (var i=0; i<intervals.length; i++) {
            clearInterval(intervals[i]);
        }
    }
}

init();
</script>