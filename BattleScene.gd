extends Node

@onready var battle_map : GridMap = $Environment/BattleMap
@onready var camerabody : CameraBody = $CameraMove

# Called when the node enters the scene tree for the first time.
func _ready():
	camerabody.target = $UnitHolder/Unit
	
func _input(event):
	if event.is_action_pressed("select_tile"):
		var mouse_tile = camerabody.get_mouse_position()
		if !mouse_tile: return
		$NavService.astar_unit_path($UnitHolder/Unit, battle_map.l_transform_m(mouse_tile))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_tile = camerabody.get_mouse_position()
	if mouse_tile: battle_map.set_hover(mouse_tile)
	$CombatService.turn_start($UnitHolder/Unit)
