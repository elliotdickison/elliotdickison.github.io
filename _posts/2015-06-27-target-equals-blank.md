---
title: "Target Equals Blank"
tags: code web
summary: "Stop right there, pilgrim!"
---
I ran into yet another website today that had `target="_blank"` set on *every* **_single_** **_LINK_**, even internal links to other pages on the *same website*. For anyone not familiar with this trick, it tells the browser to open those links in new tabs/windows when they're clicked.

This feature is usually used (abused) by websites in an attempt to keep users from navigating away to other sites. By setting this attribute on external links a website can ensure that it will remain open in your browser when you click on those links. "Surely you didn't mean to leave *this* super-awesome site. Here, let me just open that other lame-o page in a new tab for you. Come back soon!"

I've been guilty of this in the past, but this practice creates a terrible UX for users of all levels. Don't do it! For beginners who don't generally use multiple tabs, this practice is confusing. The original site is probably as good as lost anyway once they're booted to a new tab. For power users it's just an annoyance. They know how to open the link in a new tab if they want to, and don't need their tabs managed for them. On top of all that, forcing a link to open in a new tab breaks the browser history. The new tab comes with a new history stack and the back button doesn't point *anywhere*, let alone to the original site. It's actually harder to get back!

There is really no good reason to use `target="_blank"`. If you're building a complex site or app explicitly designed to be used in multiple windows then you can use `target="<window name>"`. This will also cause a link to open in a new tab, but will explicitly name the tab for future reference. All links targeting the same name will be opened in the same tab. This will keep things organized and consistent and will not spawn a million tabs if a user mashes the same link over and over.