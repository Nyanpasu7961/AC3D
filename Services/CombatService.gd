extends Node
class_name CombatService

# Handles all turns of battle including initialisation, checking hit probabilities, etc.
# Deals with showing available tiles and setting borders.

var nav_serve : NavService
var battle_map : BattleMap
var unit_holder : UnitHolder

var obtained_move = false

var skill_on_cast = {}

func initialise_combat_serve(ns : NavService, bm : BattleMap, uh : UnitHolder):
	nav_serve = ns
	battle_map = bm
	unit_holder = uh

func increment_clocktime():
	#queue pop here
	pass

func set_active_unit(unit : Unit):
	unit.is_active = true
	unit_holder.active_unit = unit

func turn_start(unit : Unit):
	var reach_tiles : Array = nav_serve.get_reachable_tiles(unit)
	battle_map.set_movement_high(reach_tiles)
	battle_map.set_border(nav_serve.get_border(reach_tiles, unit))
		
	set_active_unit(unit)

func turn_end():
	pass

func apply_skill(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass

# Increase power based on hit probability.
func check_hit_confirm(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass

func calculate_damage(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass
