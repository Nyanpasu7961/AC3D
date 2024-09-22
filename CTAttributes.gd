class_name CTAttributes

const MAX_CHARGE = 100
const MAX_CAST = 1000

var _entity : Object = null
var _clock_time : float = 0
var MAX_CT : float = 100

var _red_act : float

var _pred_ready_ct : float = 0
var _clock_cycles : int = 0
var _ct_addition : float = 10

func _init(e):
	_entity = e
	if _entity is Unit:
		MAX_CT = MAX_CHARGE
	if _entity is SkillCast:
		MAX_CT = MAX_CAST
	
	_red_act = MAX_CT*0.2

func end_turn(turn_type : int) -> void:
	_clock_time = max(0, _clock_time - MAX_CT + turn_type*_red_act)

func set_clocktime_add(ct : float) -> void:
	_ct_addition = ct

func _clocktime_ready() -> bool:
	return _clock_time >= MAX_CT

func _obtain_predicted_clocktime() -> void:
	_clock_cycles = 0
	var pred_ready = _clock_time
	while pred_ready <= MAX_CT:
		pred_ready += _ct_addition
		_clock_cycles += 1

func tick_clock_time() -> void:
	_clock_time += _ct_addition
