class_name EntityAttrComp
extends Node3D

# Change to unit stats file to set attributes
# var stats_file = preload("res://addons/godot-jolt/LICENSE.txt")

var entity_attr : Dictionary
var _stat_mods : Array[AttrMod]
var _collated_mods : Dictionary

var _is_dirty : bool = true
var final_stats

func _ready():
	initialise_attr()
	load_unit_stats()

func initialise_attr():
	for attributes in Utils.AttributeTypes:
		entity_attr[attributes] = 0
		_collated_mods[attributes] = {}
		for value_types in Utils.ValueTypes:
			_collated_mods[attributes][value_types] = 0

func load_unit_stats():
	pass

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

