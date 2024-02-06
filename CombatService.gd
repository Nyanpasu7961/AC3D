extends Node

@onready var nav_serve = $"../NavService"
@onready var battle_map : BattleMap = $"../Environment/BattleMap"

var obtained_move = false

func increment_clocktime():
	#queue pop here
	pass

func turn_start(unit : Unit):
	if !obtained_move:
		var reach_tiles : Array = nav_serve.get_reachable_tiles(unit)
		print(reach_tiles)
		battle_map.set_movement_high(reach_tiles)
		obtained_move = true
	
	
