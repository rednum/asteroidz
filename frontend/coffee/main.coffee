MAXWIDTH = 1024
MAXHEIGHT = 768

class Game
  constructor: ->
    @canvas = $('#asteroids_canvas')
    @ctx = @canvas[0].getContext('2d')
    @width = @canvas.attr('width')
    @height = @canvas.attr('height')

    @player = new SpaceShip(@width/2, @height/2, 0, @ctx)
    @rocks = [new Rock(3 * @width/4, 3 * @height/4, 2, @ctx), new Rock(@width/4, @height/4, 2, @ctx)]
    @projectiles = []
    @bodies = (r for r in @rocks)
    @bodies = @bodies.concat([@player])

  shoot: ->
    console.log "kapow"

  bindKeyboard: (selector) ->
    $(selector).keypress (e) =>
      angle = 0.2
      speed = 1
      speed2 = -0.5
      angle2 = -0.5
      switch e.which
        when 119 then @player.accelerate(speed)
        when 97 then @player.rotate(-angle)
        when 115 then @player.accelerate(-speed / 2)
        when 100 then @player.rotate(angle)
        when 32 then @shoot()
        when 101 then @player.strafe(speed2, -angle2)
        when 113 then @player.strafe(speed2, angle2)
      e.preventDefault()

  update: ->
    @clear()
    (b.tick() for b in @bodies)
    @collide()
    true
 
  collide: ->
    # rocks vs player
    # rocks vs ammo
    # both players

  clear: ->
    @ctx.fillStyle = 'black'
    @ctx.fillRect(0, 0, @width, @height)


    
class Shape
  constructor: (x, y, rotation, points, color, ctx) ->
    @ctx = ctx
    @x = x
    @y = y
    @dx = 0
    @dy = 0
    @maxX = MAXWIDTH
    @maxY = MAXHEIGHT
    @speed = 0
    @rotation = rotation
    @basePoints = points
    @points = ([p[0], p[1]] for p in @basePoints)
    @segments = []
    @color = color
    @radius2 = 0
    for p in points
      @radius2 = Math.max(@radius2, p[0] * p[0] + p[1] + p[1])

  draw: () ->
    @ctx.save()
    @ctx.strokeStyle = @color
    @ctx.beginPath()
    last = @points[@points.length-1]
    @ctx.moveTo(last[0], last[1])
    for point in @points
      @ctx.lineTo(point[0], point[1])
    @ctx.closePath()
    @ctx.stroke()

  segments: () ->
    segments

  move: () ->
    i = 0
    @x += @dx + @maxX
    @y += @dy + @maxY
    @x %= @maxX
    @y %= @maxY
    @dx *= 0.9999
    @dy *= 0.9999
    while i < @basePoints.length
      @points[i][0] = @x + @basePoints[i][0] * Math.cos(@rotation) - @basePoints[i][1] * Math.sin(@rotation)
      @points[i][1] = @y + @basePoints[i][0] * Math.sin(@rotation) + @basePoints[i][1] * Math.cos(@rotation)
      i += 1

  accelerate: (speed, angle) ->
    @dx += speed * Math.sin(@rotation + angle)
    @dy -= speed * Math.cos(@rotation + angle)

  @collideShapes: (shapeA, shapeB) ->
    if Shape.distance2(shapeA, shapeB) < shapeA.radius2 + shapeB.radius2
      return false

    for segmentA in shapeA.segments()
      for segmentB in shapeB.segments()
        if Shape.collideSegments(segmentA, segmentB)
          return true

    return false

  @distance2: (shapeA, shapeB) ->
    dx = shapeA.x - shapeB.x
    dy = shapeA.y - shapeB.y
    dx * dx + dy * dy

class SpaceShip
  constructor: (x, y, rotation, ctx) ->
    @x = x
    @y = y
    @rotation = rotation
    @speed = 0
    points = [[0, -15], [-10, 10], [10, 10]]
    @shape = new Shape(@x, @y, @rotation, points, 'lime', ctx)

  rotate: (angle) ->
    @rotation += angle
    @shape.rotation += angle

  accelerate: (speed) ->
    @shape.accelerate(speed, 0)

  strafe: (speed, angle) ->
    @shape.accelerate(speed, angle)

  tick: ->
    @shape.move()
    @shape.draw()

class Rock
  constructor: (x, y, size, ctx) ->
    @x = x
    @y = y
    @size = size
    @rotation = 0.1
    @angle = 0.1
    @speed = 1
    points = [[-31, 1], [-21, -25], [15, -27], [31, 2], [-3, 29]]
    @shape = new Shape(@x, @y, @rotation, points, 'orange', ctx)
    @shape.accelerate(@speed, 0)

  tick: ->
    @shape.rotation += @angle
    @shape.move()
    @shape.draw()

# lame fullscreen 
$("#asteroids_canvas").css("width", $(window).width() + "px")
$("#asteroids_canvas").css("height", $(window).height() + "px")
$(window).resize(=>
  $("#asteroids_canvas").css("width", $(window).width() + "px")
  $("#asteroids_canvas").css("height", $(window).height() + "px")
)

g = new Game()
g.bindKeyboard('body')
$.doTimeout('main_loop', 50, (=> g.update()))
