@tool
class_name Screen
extends Control

var width: int = 10
var height: int = 10
var squares: Array[Square]

func _draw():
  if Engine.is_editor_hint():
    draw_rect(Rect2(Vector2(), size), Color(0, 0, 0, 0.1))
    return
  if squares:
    var SIZE = min(size.x / width, size.y / height)
    var ANCHOR = Vector2(0, size.y)
    for square in squares:
      var color = square.color 
      var s = Vector2(SIZE, SIZE) * square.scale * .9
      var pos = square.pos
      var offset = Vector2(SIZE, SIZE) * (1 - square.scale) / 2
      pos = Vector2(pos.x, -pos.y-1) * SIZE + ANCHOR + offset
      #draw_rect(Rect2(pos, s), Game.COLORS[color])
      var texture = Game.instance.gem_texture
      draw_texture_rect(texture, Rect2(pos, s), false, Game.COLORS[color])
        
func set_units(units: Array2D):
  if tween: tween.kill()
  if units.width != width or units.height != height:
    width = units.width
    height = units.height
  squares = squares.filter(func(s): return s.id != Vector2i(-1, -1))
  squares.resize(units.width * units.height)
  for x in width:
    for y in height:
      var square := squares[x + y * width]
      if square == null:
        square = Square.new({id = Vector2i(x, y)})
        squares[x + y * width] = square
      square.id = Vector2i(x, y)
      square.pos = Vector2(x, y)
      square.color = units.get_i(x, y)
  queue_redraw()

var tween : Tween
func set_anim(process: Simulator.Process, duration: float):
  if tween: tween.kill()
  tween = get_tree().create_tween()
  tween.set_parallel(true)
  for remove in process.removes:
    for s in squares:
      if s.id == remove:
        s.id = Vector2i(-1, -1)
        tween.tween_property(s, "scale", 0, duration * .2)
  for add in process.adds:
    squares.append(Square.new({color = add.color, pos = Vector2(add.to), id = add.to}))
  for move in process.moves:
    for s in squares:
      if s.id == move.from:
        s.id = move.to
        var to = Vector2(move.to)
        var dist = to.distance_to(s.pos)
        var dur = duration * dist / height
        tween.tween_property(s, "pos", Vector2(move.to), dur)
  tween.tween_method(func(__): queue_redraw(), null, null, duration)
  tween.play()

class Square extends Data:
  var pos: Vector2
  var color: int
  var scale: float = 1.
  var id: Vector2i = Vector2i(-1, -1)
