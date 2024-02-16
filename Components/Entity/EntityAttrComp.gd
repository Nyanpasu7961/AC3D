class_name EntityAttrComp
extends Node3D

# Change to unit stats file to set attributes
# var stats_file = preload("res://addons/godot-jolt/LICENSE.txt")

@export var _main_job : Job
@export var _sub_job : Job

var clock_time : int

@export var _base_attributes : Attributes
var _stat_mods : Array[AttrMod]
var _collated_mods : Dictionary

var _is_dirty : bool = true
var final_stats

func load_unit_stats():
	pass

func tick_clock_time() -> void:
	clock_time += _base_attributes.agi*0.1

func add_modifier(mod : AttrMod) -> void:
	_is_dirty = true
	_stat_mods.push_back(mod)
	
	_collated_mods[mod.t_stat][mod.value_type] += mod.value
	
func rm_modifier(mod : AttrMod):
	# TODO: Might need to find by attributes rather than the entire struct.
	var index = _stat_mods.rfind(mod)
	if index != -1: 
		_stat_mods.remove_at(index)
		_is_dirty = true
		_collated_mods[mod.t_stat][mod.value_type] -= mod.value
		
	return index

func tick_modifiers(d_type : Utils.DurationType):
	var expired_mods = []
	for mod in _stat_mods:
		var expired = mod._tick_duration(d_type)
		if expired: expired_mods.append(mod)
		
	return expired_mods

func order_modifiers(a : AttrMod, b : AttrMod): 
	return a.value_type < b.value_type

func sort_modifiers():
	_stat_mods.sort_custom(order_modifiers)

