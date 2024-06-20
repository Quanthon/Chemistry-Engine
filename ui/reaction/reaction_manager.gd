class_name ReactionManager
extends Control

var reactions : Array[Reaction]
var nodes: Array[ReactionNode]

func update():
  self.reactions = reactions
  Utils.compare_update(nodes, reactions,
    func compare(node, r):
      return node.reaction == r,
    func add(r: Reaction):
      var node := load("res://ui/reaction/reaction_node.tscn").instantiate() as ReactionNode
      %RContainer.add_child(node)
      node.reaction = r
      nodes.append(node),
    func remove(node):
      node.queue_free()
      nodes.erase(node)
  )
  for i in nodes.size():
    var node := nodes[i]
    node.queue_redraw()

  for child in %CountContainer.get_children():
    child.queue_free()
  var counts = count()
  for i in counts.size():
    var color = Game.instance.COLORS[i + 1]
    var c = counts[i]
    var node = load("res://ui/reaction/color_count.tscn").instantiate() 
    %CountContainer.add_child(node)
    node.set_text(str(c))
    node.set_color(color)
  for child in %PositionContainer.get_children():
    child.queue_free()
  var position_counts = count_position()
  for i in position_counts.size():
    var color = Game.instance.COLORS[i + 1]
    var counter = position_counts[i]
    var node = PositionCount.new()
    node.custom_minimum_size = Vector2(80, 80)
    %PositionContainer.add_child(node)
    node.color = color
    node.counter = counter

func update_numbers(counter: Array[int]):
  if not counter: return
  for i in nodes.size():
    if i > counter.size():
      break
    var node := nodes[i]
    node.set_text(str(counter[i]) if counter[i] > 0 else "")

func count():
  var result : Array[int] = []
  result.resize(Game.instance.color_count)
  for i in reactions.size():
    var r := reactions[i]
    var list : Array[bool] = []
    list.resize(result.size())
    for l in r.left:
      list[l - 1] = true
    for j in list.size():
      if list[j]:
        result[j] += 1
  return result

func count_position():
  var result : Array[Array] = []
  for i in Game.instance.color_count:
    var counter : Array[int] = []
    counter.resize(9)
    result.append(counter)
  for i in reactions.size():
    var r := reactions[i]
    var center = Vector2(r.min_x + r.max_x, r.min_y + r.max_y) / 2
    for j in r.positions.size():
      var p = Vector2(r.positions[j]) - center
      var l = r.left[j]
      var x = 2 if p.x > 0 else 0 if p.x < 0 else 1
      var y = 0 if p.y > 0 else 2 if p.y < 0 else 1
      result[l - 1][x + y * 3] += 1
  return result
      
