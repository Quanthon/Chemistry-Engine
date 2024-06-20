@tool
class_name Reaction
extends Resource

enum Speed {
  FAST,
  SLOW
}

@export var positions: Array[Vector2i]:
  set(value):
    positions = value
    left.resize(positions.size())
    max_x = positions.reduce(func(acc, pos): return max(acc, pos.x), -INF)
    max_y = positions.reduce(func(acc, pos): return max(acc, pos.y), -INF)
    min_x = positions.reduce(func(acc, pos): return min(acc, pos.x), INF)
    min_y = positions.reduce(func(acc, pos): return min(acc, pos.y), INF)
@export var left: Array[int]
@export var right: int
@export var direction: Vector2i

var size: int:
  get: return positions.size()
  set(value): assert(false, 'readonly property')
var max_x: int
var max_y: int
var min_x: int
var min_y: int

func randomize(color: int):
  for i in left.size():
    left[i] = randi() % color + 1

func is_same(other: Reaction) -> bool:
  var offset := Vector2i(other.min_x - min_x, other.min_y - min_y)
  for i in min(size, other.size):
    var pos := positions[i]
    var other_pos = pos + offset
    var j = other.positions.find(other_pos)
    if j >= 0:
      var a = left[i]
      var b = other.left[j]
      if a != b:
        return false
    else:
      return false
  return true