extends Node3D

@onready var battle_map : GridMap = $Environment/BattleMap
@onready var camera_body : CameraBody = $CameraMove
@onready var combat_serve : CombatService = $CombatService
@onready var nav_serve : NavService = $NavService
@onready var ui_control : UIComponent = $UICanvas/UIComponent
@onready var unit_holder : UnitHolder = $UnitHolder

var test_skill : Skill

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_body.target = $UnitHolder/Unit
	
	test_skill = Skill.new()
	test_skill.range = 3
	test_skill.height_range = 1
	
	nav_serve._init_nav_serve(battle_map)
	unit_holder.initialise_units(ui_control, battle_map, camera_body, nav_serve)
	combat_serve.initialise_combat_serve(nav_serve, battle_map, unit_holder)
	
func _input(event):
	if ui_control.is_hovered(): return
	
	if event.is_action_pressed("select_tile"):
		var mouse_tile = camera_body.get_mouse_position()
		if !mouse_tile: return
		nav_serve.astar_unit_path($UnitHolder/Unit, battle_map.l_transform_m(mouse_tile))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	combat_serve.turn_start($UnitHolder/Unit)
	
	if not ui_control.is_hovered():
		var mouse_tile = camera_body.get_mouse_position()
		if mouse_tile: battle_map.set_hover(mouse_tile)
	
	# Testing for skill area.
	#if !$UnitHolder/Unit.tested:
	#	var test_cells = nav_serve.grab_skill_area($UnitHolder/Unit, test_skill)
	#	battle_map.map_set_skill(test_cells)
	#	$UnitHolder/Unit.tested = true
