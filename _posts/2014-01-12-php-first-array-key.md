---
title: "Get The First Array Key In PHP"
tags: code
summary: "A somewhat useful PHP hack"
---
Did you know there's an easy way to get the first (or last) key of an associative array in PHP *in one line*? Yep, it's true. You can throw all those monolithic two-line solutions out the window, grab your [PHP hammer](http://www.flickr.com/photos/raindrift/sets/72157629492908038), and get re-factoring. Here's the code:

{% highlight php startinline %}
$my_assoc_array = ['one' => 1, 'two' => 8];
echo reset((array_keys($my_assoc_array))); # one
{% endhighlight %}

I did some research to find out exactly why this snippet works, but after reading several conflicting explanations and a pretty old [bug report](https://bugs.php.net/bug.php?id=55222) I gave up. For whatever reason, that extra set of parenthesis around "array_keys" tricks "reset" into thinking it's getting a reference instead of a value, and the old "Only variables should be passed by reference" error disappears. Normally it bothers me to use something I don't understand, but PHP is a weird animal and over time I've learned to just accept its quirks.