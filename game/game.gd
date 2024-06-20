class_name Game
extends Control

static var instance: Game
const COLORS := [
    Color(1, 1, 1),
    Color(1, 0, 0),
    Color(0, 1, 0),
    Color(0, 0, 1),
    Color(1, 1, 0),
    Color(1, 0, 1),
    Color(0, 1, 1),
    Color(0, 0, 0),
]
const COLOR_NAMES := [
    "white",
    "red",
    "green",
    "blue",
    "yellow",
    "magenta",
    "cyan",
    "black"
]
const BOARD_SIZE := [6, 8, 9, 10, 12]

@onready var gem_texture := load("res://assets/gem.png")
@onready var screen := %Screen as Screen
@onready var reaction_manager := %ReactionManager as ReactionManager
@onready var shop := %Shop as Shop

@export var color_count := 2
@export var test_board_size := 0
@export var reaction_count := 1
@export var mutation_test : Mutation
@export var print_color_counter := false

var simulator : Simulator
var reactions : Array[Reaction] = []
var r_nodes: Array[ReactionNode]
var patterns : Array[Pattern] = []
var preview_mode := false

var total_level := 10
var level := 0
var board_size := 10
var money := 0
var safe := 0
var insurance := 0
var energy := 0
var last_energy := 0
var preview_energy := 0
var goal_min := 0
var goal_max := 0
var goal_distance := 0
var goal_min_list : Array
var goal_max_list : Array
var reward_min := 0
var reward_max := 0
var reward_ratio_min := 0
var reward_ratio_max := 0
var reward_max_percent := .8
var prices := {}
var last_reactions_count

enum Diffculty {
  EASY, NORMAL, HARD
}

var mutation_count := 0
var mutation: Mutation
var mutation_info : String:
  set(value):
    mutation_info = value
    if value: %LevelInfo.show()
    else: %LevelInfo.hide()
    %LevelInfo.text = mutation_info
enum Mutation {
  Null,
  MoreArea,
  LessArea,
  MoreColor,
  OddColumnColor,
  ColumnColor,
  NoColor,
  #HardProduce,
  MoreGoal,
  LessSafe
}

func _enter_tree():
  instance = self

func _ready():
  var folder_path = "res://resources/pattern/"
  for file in Utils.get_all_files(folder_path):
    if file.ends_with(".remap"):
      file = file.replace(".remap", "")
    var pattern := load(folder_path + file) as Pattern
    for _i in pattern.weight:
      for i in 4:
        patterns.append(pattern.rotate(i))
  reaction_manager.reactions = reactions
  new_game()

const SPEEDS = [1, 2, 5, 60]
var timer_on := false:
  set(value):
    timer_on = value
    if timer_on == false:
      time = 0
      process = null
      if print_color_counter and simulator:
        print(simulator.color_counter)
var speed_level := 0
var reaction_speed : float:
  get: return SPEEDS[speed_level]
var time := 0.
var process: Simulator.Process
func _process(delta):
  if timer_on:
    time += delta * reaction_speed
    if time > 1:
      time -= 1
      process = null
      if reaction_speed <= 10:
        process = simulator.do(true)
      else:
        simulator.do()
      if simulator.count <= 0:
        timer_on = false
        preview_mode = false
      if not preview_mode:
        energy += simulator.count
      else:
        preview_energy += simulator.count
      update()
      if simulator.count <= 0: process = null

func _input(event):

  if event is InputEventKey:
    if event.pressed:
      if event.keycode == KEY_1:
        _submit()

func new_game():

  level = 0
  color_count = 2
  board_size = BOARD_SIZE[0]
  preview_mode = false
  timer_on = false

  reactions.clear()
  for i in reaction_count:
    reactions.append(create_reaction())
  new_simulator()

  for dict in [Global.DIFFICULTY_DEFAULT, Global.difficulty]:
    for key in dict:
      if key in self:
        self[key] = dict[key]
    prices["remove"] = -1

  # UI
  process = null
  shop.hide()
  %Message.hide()
  %GameOver.hide()
  %Win.hide()

  new_turn()
  update()

func new_simulator(size: int = board_size):
  simulator = Simulator.new(size, size)
  simulator.reactions = reactions
  simulator.colors = color_count
  simulator.clear()
  simulator.reset_queue()

func new_turn():
  level += 1
  if level > total_level:
    win()
    return
  var _minor_index = level % 3
  energy = 0

  var difficulty_text : String = ""
  if _minor_index == 0:
    color_count += 1
    simulator.colors = color_count
    board_size = BOARD_SIZE[color_count - 2]
    difficulty_text = "\n" + tr("message_new_color").format({color = tr(COLOR_NAMES[color_count]), size = board_size})
  else:
    if level > 1: difficulty_text = "\n" + tr("message_more_energy")
  new_simulator()

  last_reactions_count = reactions.size()
  var goal_index = _minor_index + color_count * 2 - 5
  goal_min = goal_min_list[goal_index]
  goal_max = goal_max_list[goal_index]
  goal_distance = goal_max - goal_min
  reward_min = level * reward_ratio_min + 5
  reward_max = level * reward_ratio_max + 10
  
  prices["buy"] = -color_count + 1
  prices["produce"] = -color_count + 1
  prices["preview"] = -1
  prices["submit"] = 0
  prices["upgrade"] = -level

  simulator.reset_queue()
  var mutation_list : Array[Mutation] = []
  var mutation_texts : Array[String] = []
  for _i in mutation_count:
    mutation = mutation_test if mutation_test != Mutation.Null else Mutation.values().pick_random()
    mutation_list.append(mutation)
    var m_text = tr("mutation_" + Mutation.keys()[mutation].to_snake_case())
    match mutation:
      Mutation.MoreColor:
        var list = range(1, color_count + 1)
        var c = randi() % color_count + 1
        list.append(c)
        simulator.queue.fill(list)
        mutation_texts.append(m_text.format({color = tr(COLOR_NAMES[c])}))
      Mutation.OddColumnColor:
        var c = randi() % color_count + 1
        for x in range(0, simulator.width):
          if x % 2 == 0:
            simulator.queue[x].append_array([c, c])
        mutation_texts.append(m_text.format({color = tr(COLOR_NAMES[c])}))
      Mutation.ColumnColor:
        var c = randi() % color_count + 1
        var col = randi() % simulator.width
        for i in 5:
          simulator.queue[col].append(c)
        mutation_texts.append(m_text.format({column = col + 1, color = tr(COLOR_NAMES[c])}))
      Mutation.NoColor:
        if color_count <= 2: 
          continue
        if Mutation.NoColor in mutation_list:
          continue
        var c = randi() % color_count + 1
        for list in simulator.queue:
          list.erase(c)
        mutation_texts.append(m_text.format({color = tr(COLOR_NAMES[c])}))
      Mutation.MoreArea:
        #if Mutation.LessArea in mutation_list or Mutation.MoreArea in mutation_list:
        #  continue
        var s = abs(randi() % 4 - randi() % 4) + 1
        s = min(board_size + s, 15)
        new_simulator(s)
        mutation_texts.append(m_text.format({size = s}))
      Mutation.LessArea:
        #if Mutation.MoreArea in mutation_list or Mutation.LessArea in mutation_list:
        #  continue
        var s = abs(randi() % 4 - randi() % 4) + 1
        s = max(board_size - s, 5)
        new_simulator(s)
        mutation_texts.append(m_text.format({size = s}))
      Mutation.MoreGoal:
        if Mutation.MoreGoal in mutation_list:
          continue
        goal_distance *= .6
        goal_min = goal_max - goal_distance
        mutation_texts.append(m_text)
      Mutation.LessSafe:
        if Mutation.LessSafe in mutation_list:
          continue
        goal_distance *= .6 
        goal_max = goal_min + goal_distance
        mutation_texts.append(m_text)
      _:
        continue
  mutation_info = "\n".join(mutation_texts)
  simulator.shuffle()

  update()
  reaction_manager.update()
  var format = {
    level = "%d/%d" % [level, total_level],
    difficulty = difficulty_text,
    goal_min = goal_min,
    goal_max = goal_max,
    mutation = "%s: %s\n" % [tr("mutation"), mutation_info] if mutation_info else "",
  }
  message(tr("message_turn_start").format(format))

func create_reaction():
  var r := Reaction.new()
  r.positions = patterns.pick_random().positions
  r.randomize(color_count)
  return r

func update():
  prices["submit"] = roundi(calculate_reward(energy))
  if process:
    screen.set_anim(process, 1 / reaction_speed)
  else:
    screen.set_units(simulator.units)
  %EnergyInfo.text = str(energy)
  %MoneyInfo.text = str(money)
  %InsuranceInfo.text = str(insurance)
  
  for name in ["buy", "produce", "preview", "submit", "upgrade", "undo"]:
    var node_path = "%" + name.to_pascal_case()
    var button = get_node(node_path)
    button.disabled = timer_on
  for name in ["buy", "produce", "preview", "submit", "upgrade"]:
    var price = prices[name]
    var node_path = "%" + name.to_pascal_case()
    var button = get_node(node_path)
    var price_str = str(price)
    if price >= 0:
      price_str = "+" + price_str
    button.text = "%s %s" % [tr(name), price_str]
    button.disabled = price + money < 0 or button.disabled
  #%Undo.disabled = reactions.size() <= last_reactions_count or %Undo.disabled
  %Undo.disabled = reactions.size() <= 1 or %Undo.disabled
  var cant_submit = energy < goal_min
  %Submit.disabled = cant_submit or timer_on

  # preview mode
  if preview_mode: 
    %Preview.hide()
    %CancelPreview.show()
  else:
    %Preview.show()
    %CancelPreview.hide()
  if preview_energy > 0:
    %PreviewBar.show()
    %PreviewBar/Label.text = str(preview_energy)
  else:
    %PreviewBar.hide()
  
  %Graph.update({
    goal_min = goal_min,
    goal_max = goal_max,
    reward_min = reward_min,
    reward_max = reward_max,
    safe = safe + goal_max,
    energy = preview_energy if preview_energy > 0 else energy,
  })
  if not preview_mode && energy > safe + goal_max:
    explode()

func calculate_reward(_energy: float) -> float:
  var a = goal_min + (goal_max - goal_min) * reward_max_percent
  if _energy < goal_min:
    return 0
  elif _energy > a:
    return reward_max
  else:
    var x : float = (a - _energy) / (a - goal_min)
    var y :=sqrt(1 - x ** 2)
    return (lerp(reward_min, reward_max, y))

func message(text: String):
  %Message.show()
  %MessageLabel.text = text

func explode():
  energy = last_energy
  insurance -= 1
  timer_on = false
  if insurance < 0:
    game_over("explode")
  else:
    message(tr("message_explode").format({safe = goal_max + safe}))
  update()

func win():
  %Win.show()
  %WinLabel.text = tr("win").format({difficulty = Global.difficulty_name, money = money})

func game_over(reason: String):
  %GameOver.show()
  %GameOverReason.text = "game_over_%s" % reason

func _buy():
  money += prices["buy"]
  shop.show()
  var list : Array[Reaction] = []
  for i in 20:
    if list.size() >= 3: break
    var r = create_reaction()
    var flag := false
    for _r: Reaction in reactions + list:
      if _r.is_same(r):
        flag = true
        break
    if flag: continue
    list.append(r)
  shop.set_list(list)
  var r = await shop.decided
  shop.hide()
  if r:
    prices["buy"] -= 1
    reactions.append(r)
    reaction_manager.update()
    simulator.clear()
  update()

func _undo():
  #if reactions.size() > last_reactions_count:
  reactions.pop_back()
  reaction_manager.update()
  update()

func _remove():
  pass

func _upgrade():
  goal_max += goal_distance
  money += prices["upgrade"]
  prices["upgrade"] -= level
  update()

func _produce():
  last_energy = energy
  preview_mode = false
  start_simulation()
  money += prices["produce"]
  prices["produce"] -= 1

func _preview():
  preview_mode = true
  start_simulation()
  money += prices["preview"]
  prices["preview"] -= 1

func _cancel_preview():
  preview_mode = false
  timer_on = false
  update()

func start_simulation():
  preview_energy = 0
  simulator.clear()
  simulator.shuffle()
  screen.set_units(simulator.units)
  timer_on = true
  update()

func _submit():
  money += prices["submit"]
  new_turn()

func _change_game_speed(level: int):
  speed_level = level
  for i in %SpeedOptions.get_child_count():
    var child = %SpeedOptions.get_child(i)
    child.disabled = level == i

func _to_menu():
  get_tree().change_scene_to_packed(load("res://ui/menu/menu.tscn"))

func _on_message_gui_input(event:InputEvent):
  if event is InputEventMouseButton:
    %Message.hide()
