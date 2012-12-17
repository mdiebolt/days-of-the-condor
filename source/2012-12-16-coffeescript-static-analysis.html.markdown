---
title: CoffeeScript static analysis
date: 2012-12-16
tags: static analysis, coffeescript, code quality
---

For a while I've been looking for code quality tools to analyze CoffeeScript. I haven't found anything very promising. So as part of a recent push to become more comfortable with Bash scripting, I decided I'd cut some corners and do it myself.

Here's a utility function I wrote to help me color text. It colors output yellow when it's within a warning range, and red when it exceeds a critical range.

```bash
#!/usr/bin/env sh

# set the output color based on conditions
set_output_color() {
  local value=$1
  local medium_threshold=$2
  local high_threshold=$3

  if [ "$value" -gt "$high_threshold" ]
  then
    echo -en $red
  elif [ "$value" -gt "$medium_threshold" ]
  then
    echo -en $yellow
  else
    echo -en $reset
  fi
}
```

As I mentioned in my previous post about [clean bash profiles](/2012/12/10/clean-bash-profiles.html), I export the most common colors as variable so that I don't need to remember Bash escape sequences. 

In this function I use those color variables to set the output color based on two parameters, `medium_threshold` and `high_threshold`, which are passed into the function as positional parameters, making sure to reset the color if the value doesn't fall within the threshold range.

Building on `set_output_color`, I put together a short function to count the lines of code in each file below the current directory.

#### Metric: Lines of code

Lines of code is perhaps the most basic metric. As your code evolves it's easy to keep implementing feature after feature in the same file, glossing over the fact that a class or module is too long and should be split into another file for ease of reading and code clarity.

```bash
#!/usr/bin/env sh

# count lines of code in each file in the current directory
# report back long files
loc() {
  local high=200
  local medium=150

  for file in `find . -type f`
  do
    count=`cat $file | wc -l`

    # set output color based
    # on thresholds passed in
    set_output_color $count $medium $high

    echo `basename $file` $count
  done
}
```

This returns a nice colored output, highlighting files longer than 150 lines in yellow, and files longer than 200 lines in red. The thresholds chosen are based on personal preference.

#### Metric: Cyclomatic complexity

This metric is a bit more tricky to calculate, but essentially boils down to the number of paths that exist through the code. A file with high complexity often includes messy conditional logic and is a good place to start refactoring.

```bash
#!/usr/bin/env sh

# approximate cyclomatic complexity of files
# under the current directory
complexity() {
  local file
  local count

  local high=15
  local medium=10

  # look through all files in and
  # below this directory recursively
  for file in `find . -type f`
  do
    # count the number of
    # if statements plus one
    count=`cat $file | grep 'if ' | wc -l`
    count=$(($count + 1))

    set_output_color $count $medium $high

    echo `basename $file` $count $line_output
  done
}
```

Although this is a very crude approximation of cyclomatic complexity, I've found it to be useful in pointing out files that could use refactoring. 

The function is very simple. It iterates over all files below the current directory and counts the number of lines containing an `if` statement, then adds one to that number, since there is always one path through your code before any conditionals are added. A more complete and accurate tool would add weight to nested `if` statements and would include iterators / for loops in the count.

The thresholds were chosen based on complexity values discussed in the [wikipedia article about cyclomatic complexity](http://en.wikipedia.org/wiki/Cyclomatic_complexity).

#### Metric: Lines of code per method

Long methods are hard to follow and should almost always be broken up into smaller methods with clear names that describe what they do.

```ruby
#!/usr/bin/env ruby

def contains_function?(line)
  !(line =~ /->|=>/).nil?
end

# TODO this doesn't catch functions created like this
# someFn = => "blah" or someFn = (arg) => 'blah'
def function_name(line)
  if index = line.index(":")
    line.slice(0, index).strip!
  end
end

def method_length(line_number, function_start)
  line_number - function_start - 2
end

def report(name, line_number, function_start)
  "#{method_length(line_number, function_start)} lines - #{name}"
end

def function_line_count
  file = ARGV.first

  name = nil
  function_start = 0

  # TODO nested functions will break this
  File.open file, 'r' do |f|
    while line = f.gets
      # if there is a function declaration on this line
      if contains_function?(line) && function_name(line)
        # if we've found a new function then report on the last one
        puts report(name, f.lineno, function_start) if name

        # set where this functions starts and its name
        function_start = f.lineno
        name = function_name(line)
      end
    end

    # add 2 because the blank line at the end of the file
    puts report(name, f.lineno + 2, function_start)
  end
end

# execute the function if we are
# executing the file by itself
if __FILE__ == $0
  function_line_count
end
```

This last script is written in Ruby because I couldn't figure out a good way to write it in Bash. It counts the number of lines in each method. This is also the script that cheats the most, relying on a rigid structure to be accurate.

It assumes you're working with a Backbone class in CoffeeScript, and detects methods based on the presence of `->` or `=>`. After finding one of these identifiers, it stores the name of the function, determining that based on where it finds the `:` character (again, cheating by assuming an object literal style function declaration). Eg.

```coffeescript
method1: ->
  something()

method2: =>
  @another()
```

Once a function is found, the line number where it starts is stored. The script keeps going through the file until a new function is found. When this happens, the current line number is used against the start line of the previous function to determine the line count. A formatted description of the method is displayed on STDOUT.

#### What's next?

My plans for the future are to incorporate this complexity suite into a CI workflow, failing the build if code complexity reaches a certain point. I'll probably want to modify it to exclude third party code. 

Although this test suite is by no means rigorous in a computer science sense, it provides good insight into the quality of my code with minimal effort spent to develop it.