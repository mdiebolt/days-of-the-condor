---
title: OS X dock in css
date: 2011-03-17
---

As part of the [Pixie](http://pixieengine.com) redesign, Daniel and I decided we wanted an [“App”](http://daringfireball.net/linked/2011/01/13/app-word-of-the-year) dock as the primary site navigation. Without performing our design due diligence how could we expect to synergize the feel of the site and incentivize our community to shift the paradigm in our favor? #Monetize

I looked around and found a good example of an OS X style dock in css by the folks at [Zurb](http://www.zurb.com/playground/osx-dock). I make no claims to the originality of my work. These guys deserve all the credit.

The sample css was clear but once implemented on the site the height and z-index of the container elements got in the way of user interaction. The Zurb demo also used a scale and transition effect so that the icon would magnify on hover a la OS X but I thought it looked chunky and felt unresponsive.

I have never liked that magnify feature on Macs and I had to resize the container height so I went ahead and cut out everything possible.

There are two main tricks. The first is to know that `-webkit-box-reflect` exists. The second is the following css:

```sass
#dock-container .cap {
  width: 30px;
  height: 50px;
  background: url(images/dock_background.png) bottom left no-repeat;
}
```

```sass
#dock-container ul.osx-dock {
  background: url(images/dock_background.png) no-repeat right bottom;
  height: 70px;
  margin: 0 0 0 30px;
  padding: 0 30px 0 0;
}
```

`dock_background.png` is a 1000 x 50 fancy transparent trapezoid. It would be a hassle if you had to create a new image every time you wanted to add an icon to your dock. The above css saves us from that. The first block sets the width of the image to 30px and positions it on the bottom left. The second block positions the same image on the bottom right and takes advantage of the bounding element to constrain its width. Then it uses `margin-left: 30px` to line it up with the `width: 30px` image to make the dock seamless. This trick will work until you approach the width of the image. So as long as you don’t have a dock that is over 1000px wide you don’t have to make new images.
