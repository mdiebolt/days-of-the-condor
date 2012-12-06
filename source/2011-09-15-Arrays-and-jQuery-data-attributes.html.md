---
title: Arrays and jQuery data attributes
date: 2011-09-15
---

I recently had a situation where I wanted to use jQuery’s data method to convert one of my HTML data-attribute values into an array.

I ran into trouble when I tried to use the returned data as an array. The problem was that my data-attribute wasn’t valid JSON because I had double quoted the attribute value instead of single quoting it. As a result, jQuery was parsing it as a string rather than an array.

Here’s a demonstration of what was going on: [http://jsfiddle.net/EgbUh/6/](http://jsfiddle.net/EgbUh/6/)

Don’t let this happen to you. Make sure you are giving jQuery valid JSON to parse when you call the data method.
