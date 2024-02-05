extends Node

@onready var battle_map : GridMap = $Environment/BattleMap

@onready var camerabody : CameraBody = $CameraMove
@onready var camera = $CameraMove/CameraComp/ACamera


# Called when the node enters the scene tree for the first time.
func _ready():
	camerabody.target = $UnitHolder/Unit
	
func _input(event):
	if event.is_action_pressed("select_tile"):
		var mouse_tile = screen_to_tile()
		if !mouse_tile: return
		if !$UnitHolder/Unit.is_moving:
			$NavService.astar_unit_path($UnitHolder/Unit, battle_map.l_transform_m(mouse_tile))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_tile = screen_to_tile()
	
	if mouse_tile: battle_map.set_hover(mouse_tile)
	
	if $NavService.tiles_obtained:
		$CombatService.turn_start($UnitHolder/Unit)
	#battle_map.set_movement_high([mouse_tile])


func screen_to_tile():
	var space_state = battle_map.get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	# TODO: Change to current unit when multiple units on map.
	# Intersects two rays to determine mouse position.
	# Moves origin of normal ray to mouse_pos origin to find position relative to camera.
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos)*10
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	# Exclude units from ray here.
	params.exclude = [$UnitHolder/Unit.get_rid()]
	var ray_intersect = space_state.intersect_ray(params)
	#print(ray_intersect)
	# Return position onto 3d map, if tile exists.
	if ray_intersect: 
		return ray_intersect["position"]
	# Else return neg vector given no tile.
	return null
