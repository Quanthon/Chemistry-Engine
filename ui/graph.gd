class_name Graph
extends Control

const RED := Color(1, 0, 0)
const YELLOW := Color(1, 1, 0)
const GREEN := Color(0, 1, 0)
const DARK_YELLOW := Color(0.5, 0.5, 0, 0.5)
const DARK_GREEN := Color(0, 0.5, 0, 0.5)
const TOOLTIP_WIDTH := 10

var params : Params
var labels: Array[Label]

func _ready():
  item_rect_changed.connect(queue_redraw)
  for i in 6:
    var label = Label.new()
    add_child(label)
    label.add_theme_font_size_override("font_size", 16)
    label.mouse_filter = Control.MOUSE_FILTER_PASS
    labels.append(label)
  # Blue
  labels[4].modulate = Color(.5, .5, 1)
  labels[5].modulate = Color(1, 1, .0)
func _draw():
  if Engine.is_editor_hint():
    draw_rect(Rect2(Vector2(), size), Color(0, 0, 0, 0.1))
    return
  var goal_min := params.goal_min
  var goal_max := params.goal_max
  var safe := params.safe
  var energy := params.energy
  var reward_min := params.reward_min
  var reward_max := params.reward_max

  const DOT_SIZE = 4
  var X_RATIO = size.x / f((safe) * 1.05)
  var Y_RATIO = size.y / reward_max
  var BASE = 0
  var x_min = f(goal_min + BASE) * X_RATIO
  var x_max = f(goal_max + BASE) * X_RATIO
  var x_safe = f(safe + BASE) * X_RATIO
  var ANCHOR = Vector2(0, size.y)
  # X Axis
  draw_line(ANCHOR, ANCHOR + Vector2(x_min, 0), RED)
  draw_line(ANCHOR + Vector2(x_min, 0), ANCHOR + Vector2(x_max, 0), YELLOW)
  draw_line(ANCHOR + Vector2(x_max, 0), ANCHOR + Vector2(x_safe, 0), GREEN)
  draw_line(ANCHOR + Vector2(x_safe, 0), ANCHOR + Vector2(size.x, 0), RED)

  # Draw Polygon
  var points : Array[Vector2] = [Vector2(x_max, 0), Vector2(x_max, size.y), Vector2(x_min, size.y)]
  const POINT_COUNT := 100.
  for i in POINT_COUNT:
    var _i = i / POINT_COUNT
    var x = lerp(goal_min, goal_max, _i)
    var reward := Game.instance.calculate_reward(x)
    points.append(ANCHOR + Vector2(lerp(x_min, x_max, _i),- reward * Y_RATIO))
  draw_colored_polygon(points, DARK_GREEN)
  draw_colored_polygon([
    Vector2(x_max, 0), Vector2(x_max, size.y), Vector2(x_safe, size.y), Vector2(x_safe, 0)
  ], GREEN)

  
  var color : Color = Color.WHITE
  #if energy < goal_min:
  #  color = RED
  #elif energy < goal_max:
  #  color = YELLOW
  #elif energy < safe:
  #  color = GREEN
  #else:
  #  color = RED
  var energy_x = f(energy + BASE) * X_RATIO
  # Draw Current Axis
  draw_circle(ANCHOR + Vector2(f(energy + BASE) * X_RATIO, 0), DOT_SIZE, color)
  var cur_reward := Game.instance.calculate_reward(energy)
  draw_line(ANCHOR + Vector2(energy_x, 0), ANCHOR + Vector2(energy_x, -cur_reward * Y_RATIO), color)

  draw_circle(ANCHOR + Vector2(x_min, 0), DOT_SIZE, YELLOW)
  draw_circle(ANCHOR + Vector2(x_max, 0), DOT_SIZE, GREEN)
  draw_circle(ANCHOR + Vector2(x_safe, 0), DOT_SIZE, RED)

  #for i in 4:
  #  var label := labels[i]
  #  match i:
  #    0:
  #      label.text = str(goal_min)
  #      label.position = Vector2(x_min, size.y) - label.size / 2
  
  labels[0].text = str(goal_min)
  labels[0].position = Vector2(x_min, size.y)
  labels[1].text = str(goal_max)
  labels[1].position = Vector2(x_max, size.y)
  labels[2].text = str(reward_min)
  labels[2].position = Vector2(x_min, size.y - reward_min * Y_RATIO)
  labels[3].text = str(reward_max)
  labels[3].position = Vector2(x_max, size.y - reward_max * Y_RATIO)
  labels[4].text = str(energy)
  labels[4].position = Vector2(energy_x, size.y)
  labels[5].text = str(roundi(cur_reward))
  labels[5].position = Vector2(energy_x, size.y - cur_reward * Y_RATIO)
  var names = ["goal_min", "goal_max", "reward_min", "reward_max", "energy", "reward"]
  for i in 6:
    labels[i].tooltip_text = tr("graph_tooltip_" + names[i])
  labels[5].visible = cur_reward > 0

  var set_labels = func():
    for label in labels:
      label.position -= label.size / 2
  set_labels.call_deferred()
      

  #var OFFSET_X = TOOLTIP_WIDTH / 2
  #var TOOLTIP_Y = size.y + TOOLTIP_WIDTH
  ## Set tooltips 
  #tooltip_min.size = Vector2(TOOLTIP_WIDTH, TOOLTIP_Y)
  #tooltip_min.position = Vector2(x_min - OFFSET_X, 0)

  #tooltip_max.size = Vector2(TOOLTIP_WIDTH, TOOLTIP_Y)
  #tooltip_max.position = Vector2(x_max - OFFSET_X, 0)

  #tooltip_safe.size = Vector2(TOOLTIP_WIDTH, TOOLTIP_Y)
  #tooltip_safe.position = Vector2(x_safe - OFFSET_X, 0)

  #tooltip_current.size = Vector2(TOOLTIP_WIDTH, TOOLTIP_Y)
  #tooltip_current.position = Vector2(energy_x - OFFSET_X, 0)

func f(v: float) -> float:
  return v

func update(dict = null):
  if dict: 
    params = Params.new(dict)
    dict["reward"] = Game.instance.calculate_reward(params.energy)
    var energy = dict["energy"]
    dict["energy_reach_min"] = (
      tr("graph_tooltip_reach_min").format({energy = params.goal_min - energy}) 
      if energy < params.goal_min else ""
    )
    dict["energy_reach_max"] = (
      tr("graph_tooltip_reach_max").format({energy = params.goal_max - energy}) 
      if energy < params.goal_max else ""
    )
    dict["energy_safe"] = params.safe - energy
    #for key in ["tooltip_min", "tooltip_max", "tooltip_safe", "tooltip_current"]:
    #  var format = tr("graph_" + key)
    #  self[key].tooltip_text = format.format(dict)
  queue_redraw()

class Params extends Data:
  var energy: int
  var goal_min: int 
  var goal_max: int
  var reward_min := 0
  var reward_max := 0
  var safe := 0
