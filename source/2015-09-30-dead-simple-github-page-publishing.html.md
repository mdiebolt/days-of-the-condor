---
title: Dead simple GitHub Page publishing
date: 2015-09-30
tags: GitHub Pages, bash
---

GitHub Pages are awesome. Combined with a CNAME record you have a Real Site on the Internet. 

The most annoying part for me was always remembering the command to publish to GitHub Pages because I might be using a node tool, a ruby tool, or plain HTML, CSS, and JavaScript to create the site. Some of these tools have built in publishing mechanisms and others don't. 

Now, instead of relying on the tool to publish I have a really simple shell script take care of it for me. It's one line and it's consistent across any toolchain.

```sh
# push the folder `site` to repo's gh-pages branch
git subtree push --prefix site origin gh-pages
```

This command takes whatever is currently in your `site` directory and pushes it to the gh-pages remote, which GitHub uses to trigger the GitHub Pages build.

I didn't figure this out myself and I don't remember where I learned it but it's been a big time saver over many projects. 
