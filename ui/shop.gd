class_name Shop
extends Control

signal decided(reaction: Reaction)
var list: Array[Reaction]



func set_list(_list: Array[Reaction]):
  for child in %GoodsContainer.get_children(): child.queue_free()
  list = _list
  var nodes := []
  for i in list.size():
    var r := list[i]
    var button := Button.new()
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    %GoodsContainer.add_child(button)
    var node := ReactionNode.new()
    button.add_child(node)
    button.pressed.connect(_on_button_pressed.bind(i))
    node.reaction = r
    node.size = Vector2(100, 100)
    nodes.append(node)
  await get_tree().create_timer(0.01).timeout
  for node in nodes:
    node.position = node.get_parent().size / 2 - node.size / 2
    node.queue_redraw()

func _on_button_pressed(i: int):
  decided.emit(list[i] if i >= 0 else null)