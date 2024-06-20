class_name PositionCount
extends Control

var color: Color:
  set(value):
    color = value
var counter : Array[int]

func _draw():
  var SIZE = size.x / 3.
  var _max : float = counter.reduce(func(a, b): return max(a, b), 0.)
  for x in 3:
    for y in 3:
      var i := x + y * 3
      var c = color
      var count = counter[i]
      if count > 0:
        c.a = count / _max
      else:
        c = Color(.9, .9, .9)
      draw_rect(Rect2(x * SIZE, y * SIZE, SIZE, SIZE), c)