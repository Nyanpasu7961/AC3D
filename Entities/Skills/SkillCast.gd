class_name SkillCast

var _id : int = 0
var _skill : Skill
var _aoe : Array

var _ct_attributes : CTAttributes

func _init(s : Skill, area : Array):
	_skill = s
	_aoe = area
	
	_ct_attributes = CTAttributes.new(self)
	_ct_attributes.set_clocktime_add(_skill._cast_speed)

func _get_clocktime():
	return _ct_attributes.clock_time

func _get_source():
	return _skill._source

func _tick_cast_time():
	_ct_attributes.tick_clock_time()

func _clocktime_ready():
	return _ct_attributes._clocktime_ready()

# Obtain the amount of clock cycles needed to ready _skill
func _obtain_predicted():
	_ct_attributes._obtain_predicted_clocktime()
	return _ct_attributes

func _apply_skill():
	pass
