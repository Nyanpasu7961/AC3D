extends Resource
class_name AttrMod

@export var t_stat : Utils.AttributeTypes
@export var value : float
@export var value_type : Utils.ValueTypes

@export var duration : int
@export var duration_type : Utils.DurationType

var source : Object = null

func _tick_duration(d_type : Utils.DurationType):
	if d_type == duration_type: duration -= 1
	return duration <= 0
