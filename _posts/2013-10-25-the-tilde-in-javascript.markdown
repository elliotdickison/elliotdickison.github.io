---
title:  "The Tilde In JavaScript"
date:   2013-10-25 16:38:54
tags: code
---
Here's a little tidbit I learned recently: the tilde "~" is an operator in JS. Who knew? It turns out a lot of people, actually, but since I didn't find out until way late in the game I thought I would help spread the word.

## What does it do?

In JS the tilde performs a bitwise-not. For any given bit 1 or 0, the tilde will transform it to the opposite bit 0 or 1. JS doesn't have a binary type though\*, so this definition isn't all that useful. When dealing with good ol' decimal numbers the effect of a bitwise-not can be expressed with the simple formula -1 &times; (N + 1). If you're curious why exactly this holds true, MDN has a great explanation [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_Operators#Signed_32-bit_integers). In a nutshell it's because JS encodes negative integers using [two's complement](http://en.wikipedia.org/wiki/Two's_complement). But regardless of how it works, let's see the effect of the tilde in the wild.
<span class="post-footnote">\* interesting nugget: JavaScript does have [hex & octal](http://www.javascripter.net/faq/octalsan.htm) types</span>


{% highlight javascript %}
// ~N === -(N+1)
console.log(~2);  // -3
console.log(~1);  // -2
console.log(~0);  // -1
console.log(~-1); // 0
console.log(~-2); // 1
{% endhighlight %}

## So why should I care?

At first glance this might seem pretty useless. Well, to a certain extent it is... most JS developers get along just fine without the tilde. [Joe Zim](http://www.joezimjs.com/javascript/great-mystery-of-the-tilde/) has documented a pretty nifty application for it though.

JS functions that normally return tuple indices often use -1 to indicate an error, since 0 is a valid index. This poses a slight problem because -1 is truthy, meaning that it will evaluate to true when converted to a boolean. You are probably familiar with the following gotcha when using String.indexOf:

{% highlight javascript %}
var str = "James Blaylock";

// BAD: This code will erroneously log "Bob is in str"
if (str.indexOf("Bob")) { // -1... TRUE
  console.log('Bob is in str');
}

// GOOD: This code won't log anything
if (str.indexOf("Bob") != -1) { // FALSE
  console.log('Bob is in str');
}
{% endhighlight %}

When I first learned about this I simply accepted all of those "!= -1" checks as a necessary evil. Okay, they're really not all that bad. Still, the tilde can help out here a bit. If you remember our formula from earlier, ~-1 is 0 (which is falsey). Conversely ~&lt;anything else&gt; is non-zero (which is truthy). Armed with this knowledge we can refactor those "!= -1" checks like so:

{% highlight javascript %}
var str = "James Blaylock";

// GOOD: This code won't log anything
if (~str.indexOf("Bob")) { // 0... FALSE
  console.log('Bob is in str');
}

// GOOD: This code code will log "ayl is in str"
if (~str.indexOf("ayl")) { // -9... TRUE
  console.log('ayl is in str');
}
{% endhighlight %}

Cool, huh? It may not be a game-changer, but it is a nice little trick to clean up your code.