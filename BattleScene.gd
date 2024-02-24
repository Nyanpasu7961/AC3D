extends Node3D

@onready var battle_map : GridMap = $Environment/BattleMap
@onready var camera_body : CameraBody = $CameraMove
@onready var combat_serve : CombatService = $CombatService
@onready var nav_serve : NavService = $NavService
@onready var ui_control : UIComponent = $UICanvas/UIComponent
@onready var unit_holder : UnitHolder = $UnitHolder

@onready var cast_highlight : CastHighlight = $Environment/CastTimeHighlight

var test_skill : Skill

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_body.target = $UnitHolder/Unit
	
	test_skill = Skill.new()
	test_skill._range = 3
	test_skill._height_range = 1
	
	nav_serve._init_nav_serve(battle_map)
	unit_holder._initialise(ui_control, battle_map, camera_body, nav_serve, cast_highlight, combat_serve)
	combat_serve.initialise_combat_serve(nav_serve, battle_map, unit_holder)
	
	combat_serve.turn_start($UnitHolder/Unit)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not ui_control.is_hovered():
		var mouse_tile = camera_body.get_mouse_position()
		if mouse_tile: battle_map.set_hover(mouse_tile)
	
	# Testing for skill area.
	#if !$UnitHolder/Unit.tested:
	#	var test_cells = nav_serve.grab_skill_area($UnitHolder/Unit, test_skill)
	#	battle_map.map_set_skill(test_cells)
	#	$UnitHolder/Unit.tested = true
