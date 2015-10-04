---
title: How to build a living styleguide
date: 2015-10-04
tags: CSS, Sass, kss-node, styleguide, middleman, code quality
---

At the time of writing, Bootstrap is the [most starred](https://github.com/search?q=stars:%3E1&s=stars&type=Repositories) repository on GitHub. People love it and it's largely due to documentation. With styled output positioned alongside underlying markup, learning to build something that looks great is extremely intuitive.

Bootstrap is not only a nice looking design tool, it also holds Twitter accountable for the quality of their CSS. If the code is a mess or a half baked design gets out, it’s there for all <span js-bootstrap-stars>87,297</span> of those stars to see.

I've worked on projects where a developer or designer maintains a styleguide by hand, but it's never worked out. Almost immediately the guide become outdated. Manually adding markup and styles to a styleguide everytime a new widget or CSS file is added is an unreasonable development workflow. 

Automatically generating a living styleguide is an elegant way to solve this workflow problem. However, I've always put it off because it seems like such a hassle to implement. Today I'm here to tell you that with the right tool it's not such a Herculean effort after all.

There are a few projects out there to generate styleguides. [kss-node](https://github.com/kss-node/kss-node) is the one that grabbed my attention. KSS  provides a [spec](https://github.com/kneath/kss/blob/master/SPEC.md) for documenting your CSS using simple, human readable comments, helping keep the documentation close to the source code. Unlike its canonical Ruby implementation, kss-node supports generating a full styleguide out of the box.

Here's what it takes to create a styleguide. I'm using Middleman to build my site but as long as you end up with some HTML, CSS, and JavaScript you'll be set.

## Setup

`middleman init` to start a fresh project.

`npm init` so that you can manage the kss-node npm dependency.

`npm install --save-dev kss` to install and save kss-node to package.json.

## Build your publish script

I'm using a [simple shell script to build the site](/2015/09/30/dead-simple-github-page-publishing.html), generate docs, and publish them to GitHub Pages.

```sh
#!/bin/bash

# build the site with Middleman
bundle exec middleman build --clean

# make sure kss-node is installed
npm install

# configure kss-node to generate the styleguide
./node_modules/.bin/kss-node \
  --css public/site.css \
  --template source/styleguide_template \
  source/stylesheets styleguide

# make sure the built styleguide has access to the main stylesheet
cp build/stylesheets/site.css styleguide/public/site.css

# push the folder `styleguide` to repo's gh-pages branch
git subtree push --prefix styleguide origin gh-pages
```

The most interesting bit of this script is the kss-node configuration.

`--css` tells our styleguide which stylesheet needs to be loaded on the finished page so that it has the look and feel of your site.

`--template` allows us to override the structure of the generated styleguide. I found that the default used by kss-node didn't work very well. After a bit of Googling I [found one](https://github.com/htanjo/kss-node-template/tree/master/template) that I liked a lot more. `source/styleguide_template` is where I chose to save my copy.

`source/stylesheets` is where our KSS documented styles live.

`build/styleguide` is where we want to output our generated styleguide.

Now you can run this publish script and Middleman will build the site, kss-node will generate a styleguide, and it will be published to GitHub Pages.

### Gotchas

Specifying a different `--homepage` location didn't work for me, so in order to create a styleguide homepage I had to create `source/stylesheets/styleguide.md`.

Another issue I ran into while testing the generated styleguide is that the preview of pseudoselector styles didn't show up correctly when opening the file in my browser. This turned out to be an [issue](https://github.com/kss-node/kss-node/issues/51) with accessing the page from the local filesystem and ended up working fine when served over http.

That's it! Now go and write all the comments and have a beautiful living styleguide.

## Finished product

[Example](http://www.diebo.lt/kss-tutorial)

[Example source code](https://github.com/mdiebolt/kss-tutorial)
