class_name CTAttributes

const MAX_CHARGE = 100
const MAX_CAST = 1000

var entity : Object = null

var clock_time : float = 0
var MAX_CT : float = 100

var red_act : float

var pred_ready_ct : float = 0
var clock_cycles : int = 0

var _ct_addition : float = 10



func _init(e):
	entity = e
	if entity is Unit:
		MAX_CT = MAX_CHARGE
	if entity is SkillCast:
		MAX_CT = MAX_CAST
	
	red_act = MAX_CT*0.2

func end_turn(turn_type : int):
	clock_time = max(0, clock_time - MAX_CT + turn_type*red_act)

func set_clocktime_add(ct : float):
	_ct_addition = ct

func _clocktime_ready():
	return clock_time >= MAX_CT

func _obtain_predicted_clocktime():
	var clock_cycles = 0
	var pred_ready = clock_time
	while pred_ready <= MAX_CT:
		pred_ready += _ct_addition
		clock_cycles += 1

func tick_clock_time() -> void:
	clock_time += _ct_addition
