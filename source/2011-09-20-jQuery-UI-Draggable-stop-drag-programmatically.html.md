---
title: jQuery UI Draggable stop drag programmatically
date: 2011-09-20
---

I hate making elements on web pages draggable. I think it’s a gross UI choice. However, sometimes it makes sense.

Recently, I’ve been working on making a bunch of interactive tooltips to help people get familiar with our game development tools on Pixie. It’s pretty convenient for the user to move these things around in order to see different parts of the code as they read the tips.

On some of these tooltips I have code samples, which should be selectable so that people can copy the snippets into their game. I ran into a problem using jQuery UI draggable. The code snippet is a child of the draggable tooltip div so trying to select this code would drag the whole tooltip around.

After some googling I came across the good solution, after finding many bad ones, like “try `$(document).trigger(‘mouseup’);`”.

Here it is:

```coffeescript
$("#tooltip").draggable
  start: (e, ui) ->
    return false if $(e.srcElement).is('pre')

  drag: (e, ui) ->
    if $(e.srcElement).is('pre')
      ui.position.left = ui.position.left_old
      ui.position.top = ui.position.top_old

    ui.position.left_old = ui.position.left
    ui.position.top_old = ui.position.top
```

The drag event keeps the position of the element at its previous position and updates the “old position” to the same, effectively stopping movement.

The start event is necessary for me because I want to kill the drag event immediately if the user clicks the code sample element. This prevents the behavior where someone highlights text and drags the cursor over the draggable ‘#tooltip’ element, causing the tooltip to move.
