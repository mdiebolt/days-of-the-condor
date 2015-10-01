---
title: How to build a living styleguide
date: 2015-10-01
tags: code quality, CSS, Sass, kss-node, styleguide
published: false
---

At the time of writing, Bootstrap is the [most starred](https://github.com/search?q=stars:%3E1&s=stars&type=Repositories) repository on GitHub. People love it and it's largely because of documentation. With styled output positioned next to underlying markup it's extremely intuitive to get started building something that looks great.

Bootstrap puts Twitter’s CSS in the spotlight. If their code is a mess or something looks terrible, it’s there for everybody to see. Maintaining such a project takes effort but the a payoff is big. It's excellent publicity for their design team and gives them a ton of open source cred. 

I've personally been interested in setting up living styleguides for a number of projects that I've worked on but always put it off because it seems like a hassle to put together. The good news is that it's not such a Herculean effort after all.

There are a few projects out there that generate styleguides. [kss-node](https://github.com/kss-node/kss-node) is the one that grabbed my attention. KSS is inspired by TomDoc and provides a [spec](https://github.com/kneath/kss/blob/master/SPEC.md) for documenting your CSS using simple, human readable comments. However, unlike its Ruby implementation, the node version supports generating a full styleguide out of the box.

Here's what it takes to set up a basic style guide on top of a Middleman site.

## Setup

Run `middleman init` to start a fresh project.

Set up a package.json with `npm init`.

`npm install --save-dev kss` to install and save kss-node to package.json.

## Build your publish script

I'm using a simple shell script to build the site, generate docs, and publish them to GitHub Pages.

```sh
#!/bin/bash

bundle exec middleman build --clean

npm install

./node_modules/.bin/kss-node \
  --css public/site.css \
  --template source/styleguide_template \
  source/stylesheets styleguide

cp build/stylesheets/site.css styleguide/public/site.css

# push the folder `styleguide` to repo's gh-pages branch
git subtree push --prefix styleguide origin gh-pages

```

The most interesting bit of this script is where we pass options into kss-node.

`--css` tells our styleguide which CSS needs to be loaded on the finished page.

`--template` allows us to override the template. I found that the default used by kss-node didn't work very well. After a bit of Googling I [found one](https://github.com/htanjo/kss-node-template/tree/master/template) that I liked a lot more. `source/styleguide_template` is where I chose to save my copy.

`source/stylesheets` is where our KSS documented styles live.

`build/styleguide` is where we want to output our generated styleguide.

Now, you can run this publish script and Middleman will build the site, kss-node will generate a styleguide, and it will be published to GitHub Pages.

### Gotchas

Specifying a different `--homepage` location didn't work for me, so in order to create a styleguide homepage I had to create `source/stylesheets/styleguide.md`.

Another issue I ran into while testing the generated styleguide is that the pseudo selectors for previewing different state styles didn't show up correctly locally. This turned out to be an [issue](https://github.com/kss-node/kss-node/issues/51) with serving the site from the local filesystem and ends up working fine when served over http.

That's it! Now go and write all the comments and have a beautiful living styleguide.

## Finished product

[Example](http://www.diebo.lt/kss-tutorial)

[Example source code](https://github.com/mdiebolt/kss-tutorial)
