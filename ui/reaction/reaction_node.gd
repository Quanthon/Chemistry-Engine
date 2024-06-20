class_name ReactionNode
extends Control

var reaction: Reaction:
  set(value):
    reaction = value
    queue_redraw()


func _ready():
  mouse_filter = Control.MOUSE_FILTER_PASS
  texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  custom_minimum_size = Vector2(60, 60)


func _draw():
  if reaction:
    var WIDTH = reaction.max_x - reaction.min_x + 1 
    var HEIGHT = reaction.max_y - reaction.min_y + 1
    var SIZE = min(size.x / WIDTH, size.y / HEIGHT) * .9
    var CENTER = Vector2((reaction.max_x + reaction.min_x), 
    (reaction.max_y + reaction.min_y)) * SIZE / 2.
    var CENTER_Y = reaction.min_y + reaction.max_y

    var ANCHOR = size / 2 - CENTER
    #var ANCHOR = size / 2
    for i in reaction.positions.size():
      var p = reaction.positions[i]
      var pos = Vector2(p.x, CENTER_Y - p.y) * SIZE + ANCHOR
      var l = reaction.left[i]
      var color = Game.COLORS[l]
      var texture = Game.instance.gem_texture
      var s = Vector2(SIZE, SIZE)
      pos -= s / 2
      draw_texture_rect(texture, Rect2(pos, s), false, color)
      #draw_rect(Rect2(pos, s), color)

func set_text(text: String):
  if $Label: $Label.text = text
