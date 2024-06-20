class_name Array2D 
extends RefCounted

var width: int 
var height: int
var default = null
var units : Array[Array]

func _init(width := 1, height := 1, default = null):
  for x in width:
    var row = []
    for y in height:
      row.append(default)
    units.append(row)
  self.width = width
  self.height = height
  self.default = default

func clear():
  for x in width:
    for y in height:
      set_i(x, y, default)

func fill(value: Variant):
  for x in width:
    for y in height:
      set_i(x, y, value)

func fill_custom(callback: Callable):
  for x in width:
    for y in height:
      set_i(x, y, callback.call(x, y))

func safe_i(x: int, y: int) -> bool:
  if x < 0 or x >= width or y < 0 or y >= height:
    return false
  return true

func safe_v(v: Vector2i) -> bool:
  return safe_i(v.x, v.y)

func get_i(x: int, y: int):
  return units[x][y]

func get_v(v: Vector2i):
  return get_i(v.x, v.y)

func set_i(x: int, y: int, value):
  units[x][y] = value

func set_v(v: Vector2i, value):
  set_i(v.x, v.y, value)

func get_row(y: int) -> Array:
  var result = []
  result.resize(width)
  for x in width:
    result[x] = get_i(x, y)
  return result

func get_column(x: int) -> Array:
  return units[x].duplicate()

func duplicate() -> Array2D:
  var result = Array2D.new(width, height, default)
  result.units = units.duplicate(true)
  return result

func _to_string():
  var str = ""
  for y in height:
    for x in width:
      str += str(get_i(x, height - y - 1))
    str += "\n"
  return str
