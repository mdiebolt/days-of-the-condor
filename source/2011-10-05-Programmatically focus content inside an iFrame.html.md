---
title: Programmatically focus content inside an iFrame
date: 2011-10-05
---

This is a short one. On the Pixie landing page I was trying to use jQuery to focus on a game embedded via an iFrame. I tried

```coffeescript
$ ->
  $('iframe').contents().find('canvas').focus()
```

but that didn’t work.

It turns out to get this working you need setTimeout. I guess the browser isn’t done loading the iFrame contents by the time jQuery says the DOM is ready.

```coffeescript
$ ->
  setTimeout ->
    $('iframe')[0].contentWindow.focus()
  , 100
```

Here’s the related <a href="http://stackoverflow.com/questions/369026/setting-focus-to-iframe-contents" target='_blank'>Stack Overflow question</a>
