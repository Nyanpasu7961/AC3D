extends Node
class_name CombatService

var turn_has_ended : bool = false
signal turn_signal_end

var CT_MAX : int = 100

var change_active : bool = true

var turn_count : int = 0
var cycle_count : int = 0

# Handles all turns of battle including initialisation, checking hit probabilities, etc.
# Deals with showing available tiles and setting borders.

var nav_serve : NavService
var battle_map : BattleMap
var unit_holder : UnitHolder

var obtained_move = false

var units = []
var skill_on_cast = []

func _units_in_area(area : Array) -> Array:
	return units.filter(func(unit): return unit.ts_cell in area)

func add_units(us : Array):
	units.append_array(us)

func initialise_combat_serve(ns : NavService, bm : BattleMap, uh : UnitHolder):
	nav_serve = ns
	battle_map = bm
	unit_holder = uh

func apply_skill(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass

# Increase power based on hit probability.
func check_hit_confirm(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass

func calculate_damage(source_unit : Unit, target_unit : Unit, skill : Skill):
	pass

func turn_start(unit : Unit):
	var reach_tiles : Array = nav_serve.get_reachable_tiles(unit)
	battle_map.set_movement_high(reach_tiles)
	battle_map.set_border(nav_serve.get_border(reach_tiles, unit))
	set_active_unit(unit)
	
func turn_end():
	turn_has_ended = true
	turn_signal_end.emit()
	change_active = true

func set_active_unit(unit : Unit):
	unit_holder._change_active(unit)
	unit._start_turn()
	change_active = false

#func temp_pred_sort(a : TempPredHolder, b : TempPredHolder):
#	
		
# Obtains the predicted number of clock cycles required for a unit/skill to be ready.
# This is to be displayed on UI on the top-right screen.
func obtain_timeclock_pred():
	var ready_pred = units.map(func (x): return x._obtain_predicted())
	var ready_s_pred = skill_on_cast.map(func(x): return x._obtain_predicted())
	ready_pred.append_array(ready_s_pred)
	ready_pred.sort_custom(Utils._sort_by_prediction)
	return ready_pred

func check_active_units():
	var ready_entities = units.filter(func (x): return x._clocktime_ready())
	var ready_skills = skill_on_cast.filter(func(x): return x._clocktime_ready())
	ready_entities.append_array(ready_skills)
	ready_entities.sort_custom(order_by_ct)
	return ready_entities


func combat_progression():
	while true:
		# Time-based triggers resolve here eg. Quicken/Stop
		increment_clocktime()
		# Check all units and skills with >= 100CT in decreasing order.
		var ready_entities = check_active_units()
		
		while not ready_entities.is_empty():
			var entity = ready_entities.pop_front()
			if entity is Unit:
				turn_start(entity)
				
				if not turn_has_ended:
					await turn_signal_end
				
				entity._end_turn_clocktime(0)
				
			if entity is SkillCast:
				var apply_aoe = unit_holder._skill_area_has_entity(entity._aoe)
				battle_map.rm_skill_to_cast(entity)
				skill_on_cast.erase(entity)
				
				
				for cell in apply_aoe:
					cell.deal_damage(50)
				
			# Need to recheck active units in case units' CT has been changed
			ready_entities = check_active_units()
			turn_has_ended = false

func order_by_ct(u1, u2):
	return u1._get_clocktime() > u2._get_clocktime()

func increment_clocktime():
	for unit : Unit in units:
		unit._tick_clocktime()
	for sc : SkillCast in skill_on_cast:
		sc._tick_cast_time()
