class_name StatusComponent
extends Node3D

var status_list : Array = []

class StatusAilment:
	var duration : int
	var duration_type : Utils.DurationType
	# Removed when damage is taken.
	var remove_on_damage : bool = false
	var stackable : bool = false
	
	# Used for poison/regen effects.
	var health_tick : float = 0
	# +/- modifier effect on status application.
	var modifiers : Array[AttrMod]
	# Paralysis, sleep, zero effects
	var effect_chance : float = 0
	# Clock time effects eg. quicken
	var clock_time_inc : float = 0
	
	var source : Object
	
	func _tick_duration(d_type : Utils.DurationType):
		var check_type = d_type == duration_type
		if check_type: duration -= 1
		return check_type
