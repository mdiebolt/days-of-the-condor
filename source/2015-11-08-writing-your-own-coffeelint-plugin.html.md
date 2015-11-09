---
title: Writing your own CoffeeLint plugin
date: 2015-11-08
tags: CoffeeLint, code quality
---

Recently I wrote about maintaining code consistency on growing teams using CoffeeLint. If you use CoffeeLint across many projects or with a large enough team, sooner or later you’ll come across a situation that isn’t covered by an out of the box rule.

CoffeeLint provides a plugin system that makes authoring your own linter easy. The implementation guidelines are outlined in [Building Custom Rules](http://www.coffeelint.org/). There are three different types of rules that can be implemented depending on your needs: LineLinter, TokenLinter, and ASTLinter.

### Describing the rule

I’m going to write a TokenLinter that enforces whitespace conventions when invoking a function. To pass this check a function call must:

1. Not include whitespace following the opening parenthesis.
1. Use a space to separate each argument.
1. Not include whitespace before the closing parenthesis.

*Note: The points about opening and closing parentheses don't apply if they have been omitted when calling the function.*

```coffee
# Valid style
fn(2, 5)
fn 2, 5
fn(2, 5) if x > 10
fn 2, 5 if x > 10
fn 2,
  someOption: true

# Invalid style
fn( 2, 5)
fn(2, 5 )
fn( 2, 5 )
fn(2,5)
``` 

### Start from an existing rule

Rather than write a plugin from the ground up, I searched through CoffeeLint's base rules and [found one](https://github.com/clutchski/coffeelint/blob/master/src/rules/no_implicit_parens.coffee) similar to what I wanted.

The main difference is that I wanted to check both `CALL_START` *and* `CALL_END` tokens to make sure they were not surrounded by a space. In addition, I would need to test tokens in between to make sure arguments to the function were spaced appropriately.

### Breaking it down

```coffee
# ...
tokens: ["CALL_START", "CALL_END"]

lintToken: (token, tokenApi) ->
  tokenType = token[0]
  if tokenType == "CALL_START"
    isOpeningParenError = true if token.spaced
    isArgumentError = checkArgumentSpacing(tokenApi)
  else if tokenType == "CALL_END"
    isClosingParenError = checkCloseParenSpacing(token, tokenApi)

  isOpeningParenError || isArgumentError || isClosingParenError
# ...
```

`lintToken` is the crux of a TokenLinter plugin. In our case it's called any time a `CALL_START` or `CALL_END` token is encountered. Stepping through it we see that a linting error is triggered if any of the following are true:

1. Does the opening parenthesis incorrectly use a space?
1. Are any of the function arguments incorrectly spaced?
1. Does the closing parenthesis incorrectly use a space?

#### Opening parenthesis

The opening parenthesis case is easy to handle since CoffeeScript's compiler gives us a property `spaced` if the token has a space after it. 

```coffee
isOpeningParenError = true if token.spaced
```

#### Function arguments

Next, starting at `CALL_START`, we use `checkArgumentSpacing` to loop over the arguments by peeking forward until we reach `CALL_END`. At each step we need to check a few things:

1. Is the token a comma? We care about commas because they're the only character used to separate arguments in JavaScript. 
1. Does the token have a space after it? This covers inline arguments.
1. Does the token have a newline after it? This covers multiline arguments, commonly used with configuration options.

```coffee
isArgumentIncorrectlySpaced = (token) ->
  token[0] == "," && !(token.spaced || token.newLine)

checkArgumentSpacing = (tokenApi) ->
  i = 1
  insideFunctionCall = true
  while insideFunctionCall
    nextToken = tokenApi.peek(i)
    i += 1

    isLintingError = true if isArgumentIncorrectlySpaced(nextToken)
    insideFunctionCall = nextToken[0] != "CALL_END"

  isLintingError
```

#### Closing parenthesis

This one is trickier than the opening case because you can't rely on the `spaced` property since it only applies to spacing *after* the given token. You can look at the previous token's spacing property, but this breaks down when a function is invoked and then followed by a postfix expression. In this situation the previous token will have a space after it and look like a violation of the rule. As a workaround, I check that the current token (`CALL_END`) and the previous token are in the same position. That fact that these tokens are reported in the same position seems to be a CoffeeScript compiler quirk, but is reliable enough for our needs.

```coffee
checkCloseParenSpacing = (token, tokenApi) ->
  previousToken = tokenApi.peek(-1)
  if previousToken.spaced
    # generated means that CoffeeScript is adding parentheses for us
    # and that the author has omitted them
    if token.generated
      unless token[2].last_column == previousToken[2].last_column
        isLintingError = true
    else
      isLintingError = true

  isLintingError
```

### Wrapping up

Writing one of these plugins doesn't take much time and it'll save you the headache of fighting with developers with strong opposing opinions. Now go out and write all the plugins to bend the code style of your organization to your will!
