class_name AttrMod

var t_stat : Utils.AttributeTypes
var value : float
var value_type : Utils.ValueTypes

var duration : int
var duration_type : Utils.DurationType

var source : Object

func _tick_duration(d_type : Utils.DurationType):
	if d_type == duration_type: 
		duration -= 1
	return duration <= 0
