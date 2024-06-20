class_name Menu
extends Control

@onready var game := load("res://game/game.tscn")

func click_button(diff: int):
  match diff:
    0:
      pass
  Global.difficulty_index = diff
  %Info.show()
  %Info.get_node("Label").text = "%s: %d\n%s"%[
    tr("level_count"), Global.difficulty["total_level"],
    tr("difficulty_%d_detail" % Global.difficulty_index)
  ] 

func start_game():
  get_tree().change_scene_to_packed(game)
