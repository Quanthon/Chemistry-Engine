class_name Simulator
extends RefCounted

var width 
var height
var colors := 2
var count := 0
var counter : Array[int]
var units : Array2D
var reactions: Array[Reaction]
var queue: Array[Array]
var color_counter : Array[int]

var _reaction_index := 0:
  set(value):
    _reaction_index = value
    _reaction = reactions[_reaction_index]
var _reaction: Reaction
var _buffer : Array2D
var _process: Process

func _init(_width: int, _height: int):
  units = Array2D.new(_width, _height, 0)
  _buffer = Array2D.new(_width, _height, -1)
  width = _width
  height = _height

func clear():
  #counter.clear()
  #counter.resize(reactions.size())
  color_counter.clear()
  color_counter.resize(colors)

func reset_queue():
  queue.clear()
  for i in width:
    queue.append(range(1, colors + 1))

func reset():
  count = 0
  _reaction_index = 0
  _buffer.clear()

func do(anim := false):
  reset()
  if anim: _process = Process.new()
  for i in reactions.size():
    _reaction_index = i
    do_reaction()
  for x in width:
    for y in height:
      var v = _buffer.get_i(x, y)
      if v >= 0:
        units.set_i(x, y, _buffer.get_i(x, y))
        if anim:
          _process.removes.append(Vector2i(x, y))
  if anim:
    gravity_with_anim()
    reload_with_anim()
    return _process
  gravity()
  reload()

func do_reaction():
  var r = _reaction
  for x in range(max(-r.min_x, 0), min(width - r.max_x, width)):
    for y in range(max(-r.min_y, 0), min(height - r.max_y, height)):
      do_square(Vector2i(x, y))


func do_square(pos: Vector2i) -> bool:
  var flag = true
  for i in _reaction.positions.size():
    var p := _reaction.positions[i]
    var l := _reaction.left[i]
    var t := pos + p
    if units.get_v(t) != l:
      flag = false
      break
  if flag:
    #counter[_reaction_index] += 1
    for p in  _reaction.positions:
      var t := pos + p
      if _buffer.get_v(t) < 0:
        count += 1
      _buffer.set_v(pos + p, 0)
  return flag

func gravity():
  for x in width:
    var col = units.get_column(x)
    col = col.filter(func(i): return i > 0)
    for y in height:
      units.set_i(x, y, col[y] if y < col.size() else 0)

func gravity_with_anim():
  for x in width:
    var i = 0
    for y in height:
      var unit = units.get_i(x, y)
      if unit > 0:
        if y != i:
          _process.moves.append(Move.new(Vector2i(x, y), Vector2i(x, i)))
          units.set_i(x, i, unit)
          units.set_i(x, y, 0)
        i += 1

func reload():
  for x in width:
    for y in height:
      if units.get_i(x, y) <= 0:
        units.set_i(x, y, get_next_color(x))

func reload_with_anim():
  for x in width:
    var white_count = 0
    for y in height:
      if units.get_i(x, y) <= 0: white_count += 1
    for y in height:
      if units.get_i(x, y) <= 0:
        var color = get_next_color(x)
        units.set_i(x, y, color)
        _process.adds.append(Add.new(Vector2i(x, y + white_count), color))
        _process.moves.append(Move.new(Vector2i(x, y + white_count), Vector2i(x, y)))
        #print(Vector2i(x, y + white_count), Vector2i(x, y))

func get_next_color(col: int):
  var c = queue[col].pick_random()
  color_counter[c - 1] += 1
  return c

func shuffle():
  for x in width:
    for y in height:
      units.set_i(x, y, get_next_color(x))

class Add extends Data:
  var to: Vector2i
  var color: int

  func _init(_to: Vector2i, _color: int):
    to = _to
    color = _color

class Move:
  var from: Vector2i
  var to: Vector2i

  func _init(_from: Vector2i, _to: Vector2i):
    from = _from
    to = _to

class Process extends Data:
  var removes : Array[Vector2i]
  var adds : Array[Add]
  var moves: Array[Move]
