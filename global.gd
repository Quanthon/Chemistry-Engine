extends Node

var difficulty_index : int = 1
var difficulty : Dictionary:
  get: return DIFFICULTIES[difficulty_index]
var difficulty_name:
  get: return tr("difficulty_" + str(difficulty_index))

const DIFFICULTIES := [
  {
    insurance = 10,
    money = 20,
    reward_ratio_min = 5,
    reward_ratio_max = 10,
    reward_max_percent = .3,
    total_level = 9,
    goal_min_list = [100, 500,  1000, 2000, 5000, 10000, 20000, 50000, 75000],
    goal_max_list = [2000, 3000, 5000, 10000, 20000, 50000, 100000, 100000, 125000]
  },
  {
    insurance = 5,
    money = 20,
    total_level = 11,
    reward_ratio_min = 2,
    reward_ratio_max = 7,
    reward_max_percent = .6,
    goal_min_list = [100, 500,  1000, 2000, 5000, 10000, 20000, 50000, 75000, 100000],
    goal_max_list = [1000, 2000, 3000, 5000, 10000, 20000, 50000, 100000, 100000, 125000]
  },
  {
    insurance = 2,
    money = 15,
    total_level = 12,
    mutation_count = 1,
    reward_ratio_min = 1,
    reward_ratio_max = 5,
    reward_max_percent = .8,
    goal_min_list = [100, 500,  1000, 2000, 5000, 10000, 20000, 50000, 75000, 100000],
    goal_max_list = [500, 1500, 2000, 4000, 7500, 15000, 30000, 75000, 100000, 125000]
  },
  {
    insurance = 1,
    money = 10,
    total_level = 13,
    mutation_count = 1,
    reward_ratio_min = 0,
    reward_ratio_max = 5,
    reward_max_percent = .8,
    goal_min_list = [100, 500,  1000, 2000, 5000, 10000, 20000, 50000, 75000, 100000, 125000],
    goal_max_list = [300, 1000, 1500, 3000, 7500, 15000, 30000, 75000, 100000, 125000, 150000]
  },
]

const DIFFICULTY_DEFAULT := {
  insurance = 5,
  money = 15,
  mutation_count = 0,
  reward_ratil_min = 1,
  reward_ratio_max = 5,
  reward_max_percent = .5,
  goal_min_list = [100, 500,  1000, 2000, 5000, 10000, 20000, 50000, 75000, 100000],
  goal_max_list = [500, 1500, 2000, 3500, 7500, 15000, 30000, 75000, 100000, 125000]
}