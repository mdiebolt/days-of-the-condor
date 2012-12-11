---
title: Clean bash profiles
date: 2012-12-10
tags: Bash
---

Lately I've been more interested in writing Bash. However, as cool as Bash is for being able to pipe data all over the place, it has a really hard to read syntax. This makes understanding people's 1000 line long Bash file tedious.

The more utility functions, aliases, and slight tweaks I add to my profile, the longer I have to spend each time I come back to it. I recently split out each of the sections into their own files to fix this.

My new profile is much shorter and is very clear.

```bash
# export common color escape sequences
source ~/Dropbox/dotfiles/colors

# source utility functions
for function in `find ~/Dropbox/dotfiles/bin/sh -type f`
do
  source $function
done

# aliases
source ~/Dropbox/dotfiles/aliases

# z script
source ~/z/z.sh

# system PATH
source ~/Dropbox/dotfiles/paths

export EDITOR=subl

eval "$(rbenv init -)"

computer_symbol="⚡"
symbol_formatting="$reset\n$computer_symbol "

PS1="\n\[\`if [[ \$? = "0" ]]; then echo '\e[32m\h\e[0m'; else echo '\e[31m\h\e[0m' ; fi\`\]:\w$yellow"'`__git_ps1`'"$symbol_formatting"
``` 

I can never remember the color escape sequences, so the first thing I do is `source` a file that exports common colors for easy use.

```bash
export red="\033[31m"
export yellow="\033[33m"
export green="\033[32m"
export blue="\033[34m"
export purple="\033[35m"
export cyan="\033[36m"
export reset="\033[0m"
```

Next, I make sure that I have access to all the utility functions I've been writing by sourcing each of them from a scripts directory.

I noticed that my aliases were getting a bit out of hand and were taking up a large part of my profile, so I pulled them into a file too.

This next one is really useful. [z script](https://github.com/rupa/z) is a Bash utility that Paul Irish mentioned in a talk. It allows you to `cd` into a directory by fuzzy matching directories in your recent bash history. For example, if you always `cd` into `~/matt/some/really/long/project/called/rainbow-unicorns`, you could type `z uni` and z script would work its magic and take you there.

The next part is a matter of personal taste. I prefer using vertical space to horizontal, so I split my `PATH` variable assignment into another file. The old one used to have a bunch of junk all in one line.

```bash
export PATH=/path1:/path2:/more/paths: # etc
```

Here are how my paths look now.

```bash
path_directories=(
  '/usr/local/share/npm/bin:'
  '~/.pollev/bin:'
  '~/bin:'
  '/bin:'
  '/sbin:'
  '/usr/local/bin:'
  '/usr/bin:'
  '/usr/local/sbin/:'
  '/usr/sbin:'
  '/opt/local/sbin:'
  '/usr/local/git/bin:'
  '/Applications/MacVim/:'
  '/Users/matt/.redis26/bin:'
)

PATH=$(printf "%s" "${path_directories[@]}")

export PATH
```

More verbose? Yes, but I'll take it for clarity.

The rest isn't too exciting, I assign my `EDITOR` of choice, configure rbenv, and then work black magic to make my prompt look the way I like.

Overall, splitting my profile into multiple files has been a useful project in learning Bash tricks. The only thing I'm not pleased with is how hard it is to understand the `PS1` code. I'd like to pull that logic into a function to clear up the intent of the code but I haven't quite figured out how yet.