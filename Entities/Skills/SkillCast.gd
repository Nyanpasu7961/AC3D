class_name SkillCast

var skill : Skill
var cast_time : float = 0
var aoe : Array

func _init(s : Skill, area : Array):
	skill = s
	aoe = area

func _tick_cast_time():
	cast_time += skill._cast_speed

# Obtain the amount of clock cycles needed to ready skill
func _obtain_predicted():
	var clock_cycles = 0
	var pred_cast = cast_time
	while pred_cast <= 1000:
		pred_cast += skill._cast_speed
		clock_cycles += 1
	return clock_cycles

func _apply_skill():
	pass
