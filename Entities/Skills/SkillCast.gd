class_name SkillCast

var _skill : Skill
var _cast_time : float = 0
var _aoe : Array


func _init(s : Skill, area : Array):
	_skill = s
	_aoe = area

func _get_clocktime():
	return _cast_time

func _get_source():
	return _skill._source

func _tick_cast_time():
	_cast_time += _skill._cast_speed

func _ready_to_cast():
	return _cast_time >= 100

# Obtain the amount of clock cycles needed to ready _skill
func _obtain_predicted():
	var clock_cycles = 0
	var pred_cast = _cast_time
	while pred_cast <= 1000:
		pred_cast += _skill._cast_speed
		clock_cycles += 1
	return clock_cycles

func _apply_skill():
	pass
