extends Node2D

enum A {
  A,
  B,
  C
}

func _ready():
  print(A.keys())

#var test_data = [
#  TestData.new({
#    a_pos = [Vector2i()],
#    b_pos = [Vector2i()],
#    a = [0],
#    b = [0],
#    result = true
#  }),
#  TestData.new({
#    a_pos = [Vector2i(), Vector2i(1, 1)],
#    b_pos = [Vector2i(), Vector2i(-1, -1)],
#    a = [0, 1],
#    b = [1, 0],
#    result = true
#  }),
#  TestData.new({
#    a_pos = [Vector2i(), Vector2i(1, 1), Vector2i(2, 2)],
#    b_pos = [Vector2i(), Vector2i(-1, -1)],
#    a = [0, 1, 2],
#    b = [1, 0],
#    result = true
#  }),
#  TestData.new({
#    a_pos = [Vector2i(), Vector2i(1, 1), Vector2i(2, 2)],
#    b_pos = [Vector2i(), Vector2i(-1, -1), Vector2i(-2, -2)],
#    a = [0, 1, 2],
#    b = [2, 1, 0],
#    result = true
#  }),
  
#  TestData.new({
#    a_pos = [Vector2i(), Vector2i(1, 1)],
#    b_pos = [Vector2i(), Vector2i(-1, -1), Vector2i(-2, -2)],
#    a = [0, 1],
#    b = [0, 1, 2],
#    result = false
#  }),
  
#  TestData.new({
#    a_pos = [Vector2i(), Vector2i(1, 1), Vector2i(2, 2)],
#    b_pos = [Vector2i(), Vector2i(1, 1)],
#    a = [0, 1, 2],
#    b = [2, 1, 0],
#    result = false
#  }),
#]

#func _ready():
#  for data: TestData in test_data:
#    var a = Reaction.new()
#    a.positions = data.a_pos
#    a.left = data.a
#    var b = Reaction.new()
#    b.positions = data.b_pos
#    b.left = data.b
#    assert(a.is_same(b) == data.result)

#class TestData extends Data:
#  var a_pos: Array[Vector2i]
#  var b_pos: Array[Vector2i]
#  var a: Array[int]
#  var b: Array[int]
#  var result: bool