class_name EntityParameters
extends Resource

var _entity_id : int = 0

@export var _main_job : Job
@export var _sub_job : Job
@export var _base_attributes : Attributes

var _ct_attributes : CTAttributes = null

# Stores AttrMod
var _stat_mods : Array[AttrMod]
var _collated_mods : Dictionary

var _is_dirty : bool = true
var final_stats

func initialise(entity) -> void:
	_ct_attributes = CTAttributes.new(entity)
	_ct_attributes.set_clocktime_add(_base_attributes.AGI*0.1)

func _clocktime_ready() -> bool:
	return _ct_attributes._clocktime_ready()

func set_clocktime(ct : float) -> void:
	_ct_attributes.set_clocktime_add(ct)

func _obtain_predicted_clocktime() -> CTAttributes:
	_ct_attributes._obtain_predicted_clocktime()
	return _ct_attributes

func tick_clock_time() -> void:
	_ct_attributes.tick_clock_time()
	for mod in _stat_mods:
		mod._tick_duration(Utils.DurationType.CLOCKTIME)

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
