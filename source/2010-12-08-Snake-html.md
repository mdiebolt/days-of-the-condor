---
title: Snake
date: 2010-12-08
---

This is part one of a classic games in JavaScript series I am starting.

I can hear all the haters now, “this guy never writes in his blog, there is no way this will be anything more than a one post series”. While this may be true, I am now unemployed so I have much more time to spend writing games that were invented in the 70s.

It's also a shameless promotion / tutorial for [Pixie](http://pixieengine.com), which Daniel X. Moore and I have been hard at work on lately.

Pixie’s goal as a game development platform is to take as much terribleness out of programming JavaScript as possible. In fact, I went as far as to write my game in Coffeescript to avoid JavaScript’s syntax.

Let’s start with a high level view.

#### Main

```coffeescript
snake = Snake()
fruits = []

window.game_over = false

controls =
  "down": Point(0, 10)
  "up": Point(0, -10)
  "left": Point(-10, 0)
  "right": Point(10, 0)

$.each controls, (key, value) ->
  Game.keydown key, ->
    snake.move value

collideFruits = ->
  for fruit in fruits
    snake.eat fruit

Game.update ->
  snake.update()
  if !window.game_over
    if rand() < 0.02
      fruits.push Fruit()

    fruits = fruits.select (fruit) ->
      fruit.update()

    collideFruits()

Game.draw (canvas) ->
  canvas.fill "#000"
  fruit.draw canvas for fruit in fruits
  snake.draw canvas
```

##### Important methods
* controls (not really a method): Takes an object of velocities and maps them to the keyboard to control the snake.
* collideFruits: Checks to see if the snake is touching any of the fruits.
* Game.update tells both the snake and fruits to update their data.
* Game.draw draws all the objects onscreen.

The nice part about developing on Pixie is that a lot of the tedious boilerplate code, like setting up the canvas and creating your game loop, is already taken care of by including Gamelib in your app.

**Main summary: Make a snake, set up the controls, add some fruit every once in a while, gg.**

Now with the basic game outline in mind, let’s look at the game objects.

```coffeescript
Fruit = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: "#F00"
    points: 20
    radius: 5
    x: 10*rand(47) + 5
    y: 10*rand(31) + 5

  half_points = I.points / 2

  self = GameObject(I).extend
    eatenBy: (snake) ->
      I.active = false
      snake.score I.points

    draw: (canvas) ->
      canvas.fillColor I.color
      canvas.fillCircle I.x, I.y, I.radius

    before:
      update: ->
        if I.age > 200
          I.color = "CC3"
          I.points = half_points

  self
```

If you are unfamiliar with this JavaScript style I suggest checking out Daniel X. Moore’s [Game Extensions blog series](http://strd6.com/category/256-javascript-game-extensions/).

This class defines the key aspects of a fruit such as its color, size, and position.

##### Important methods
* eatenBy: Dispose of the fruit once it is eaten.
* draw: Draw the fruit onscreen
* before update: My fruit is extending GameObject, a class provided by a built-in Pixie library. GameObject already gives me an update method. Rather than overwrite the method and code the built-in features by hand, before: lets me jam some stuff in front of the update method so that the code I define there will be executed prior to the execution of the normal update method.

```coffeescript
BodyPiece = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: "#FFF"
    position: Point(5, 5)
    radius: 5,

  self =
    draw: (canvas) ->
      canvas.fillColor I.color
      canvas.fillCircle I.position.x, I.position.y, I.radius

    position: (val) ->
      if(val != undefined)
        I.position = val
      else
        I.position
```

This class is very basic. It contains the bare bones information required to keep track of a piece of the snake’s body. Like Fruit, this tracks color, size, and position. Nothing else to say here.

```coffeescript
Snake = (I) ->
  I ||= {}

  $.reverseMerge I,
    dead: false
    pieces: [BodyPiece()]
    score: 0
    velocity: Point(0, 0)

  deathChecks = ->
    I.dead = outOfBounds()

    snake_temp = I.pieces.copy()
    head = snake_temp.shift()

    for piece in snake_temp
      if head.position().equal piece.position()
        I.dead = true

    if I.dead
      window.game_over = true

  grow = ->
    headPosition = I.pieces[0].position()

    I.pieces.unshift BodyPiece
      position: headPosition

  moveTailToHead = ->
    headPosition = I.pieces[0].position()
    tail = I.pieces.pop()
    tail.position(headPosition.add I.velocity)
    I.pieces.unshift tail

  movingOpposite = (direction) ->
    if I.velocity.equal Point(0, 0)
      return false
    else
      I.velocity.x == -direction.x || I.velocity.y == -direction.y

  outOfBounds = ->
    headPosition = I.pieces[0].position()
    !((0 < headPosition.x < 480) && (0 < headPosition.y < 320))
  self =
    draw: (canvas) ->
      snakePiece.draw(canvas) for snakePiece in I.pieces
      if I.dead
        canvas.centerText "GAME OVER", 160
        canvas.centerText "Refresh to play again", 180
      canvas.fillText "Score: " + I.score, 390, 20

    eat: (fruit) ->
      if I.pieces[0].position().equal fruit.position()
        fruit.eatenBy self
        grow()

    move: (direction) ->
      I.velocity = direction unless movingOpposite direction

    score: (points) ->
      I.score += points * I.pieces.length

    update: ->
      if !I.dead
        moveTailToHead()
        deathChecks()
```

Okay, here is where most of the logic happens. The snake knows how many pieces are in its body, its score, how fast it is going, and whether or not it is dead.

##### Important methods
* deathChecks: check if the snake should die from being out of bounds or colliding with itself
* movingOpposite: This is a helper method to make sure you can’t start moving left when moving right and collide into your body
* moveTailToHead: This is the key trick to coding this game. Treat the snake’s body as a circular array and when updating it move the end piece to the head rather than trying to update the position of each of the pieces

The rest of the code is pretty simple. Draw the snake, with a few extra calls to draw the game over screen when it is dead. Define how a snake eats fruit. Allow a change in direction as long as you aren’t moving the opposite direction. Manage your score. Update the snake’s data.

…And we are done. In 147 lines of Coffeescript we have a live snake game playable on any of the modern internets.
