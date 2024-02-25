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
	
	nav_serve._init_nav_serve(battle_map)
	unit_holder._initialise(ui_control, battle_map, camera_body, nav_serve, cast_highlight, combat_serve)
	
	combat_serve.initialise_combat_serve(nav_serve, battle_map, unit_holder)
	
	combat_serve.combat_progression()

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		if ui_control.is_hovered(): return
		var mouse_tile = camera_body.get_mouse_position()
		if mouse_tile: 
			battle_map.set_hover(mouse_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
