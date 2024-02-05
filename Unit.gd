class_name Unit
extends CharacterBody3D

@export var move_comp : MoveComponent

const SPEED = 5.0
const AUTO_SPEED = 5.0
const JUMP_VELOCITY = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var battle_map : GridMap = $"../../Environment/BattleMap"
@onready var nav_serve = $"../../NavService"

var DIRECTIONS = [Vector3.FORWARD, Vector3.BACK, Vector3.RIGHT, Vector3.LEFT]

var cell_size
# Cell unit is on at turn start.
var ts_cell : Vector3i
var unit_cell : Vector3

var grab_next_vel = true
var path_stack : PackedVector3Array
var is_moving = false
var _next_point = Vector3()
var travel_dir : Vector3
const ARRIVE_DISTANCE = 0.2

func _ready():
	cell_size = battle_map.cell_size
	ts_cell = battle_map.local_to_map(global_position)

func _process(delta):
	if grab_next_vel:
		unit_cell = battle_map.local_to_map(global_position)

func path_movement(delta):
	is_moving = true
	var arrived_to_next_point = _move_to(_next_point, delta)
	if arrived_to_next_point:
		grab_next_vel = true
		path_stack.remove_at(0)
		if path_stack.is_empty():
			print("finished")
			is_moving = false
			return
		_next_point = path_stack[0]

func _move_to(local_position, delta):
	# Move only in terms of the xz directions.
	var desired_velocity = local_position - unit_cell
	grab_next_vel = false
	
	desired_velocity = (desired_velocity.project(Vector3.BACK)+desired_velocity.project(Vector3.RIGHT)).normalized()
	desired_velocity = desired_velocity*AUTO_SPEED*log(path_stack.size()+1)
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	
	var adjusted_pos : Vector3 = global_position
	adjusted_pos.y = battle_map.local_to_map(global_position).y
	adjusted_pos = translate_grid_center(adjusted_pos, false)
	
	return adjusted_pos.distance_to(local_position) <= ARRIVE_DISTANCE

func check_input():
	if is_moving: return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, $"../../CameraMove".y_rot)
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

func _physics_process(delta):
	if !path_stack.is_empty():
		path_movement(delta)
	
	if !is_moving: check_input()
	
	if velocity.x == 0 and velocity.z == 0: 
		snap_to_grid()
	
	if move_and_slide():
		var collide = get_last_slide_collision()
		var normal = collide.get_normal()
		if normal in DIRECTIONS:
			velocity.y += JUMP_VELOCITY
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 10*gravity*delta
	
func translate_grid_center(cell : Vector3, grab_center : bool = true):
	var t_vec = Vector3(cell_size.x/2, 0, cell_size.z/2)
	return cell + (t_vec if grab_center else -t_vec)
	
# Readjusts unit to grid position.
func snap_to_grid():
	var cell = battle_map.local_to_map(global_position) as Vector3
	var from = Vector3(global_position.x, cell.y, global_position.z)
	var to = cell+Vector3(cell_size.x/2, 0, cell_size.z/2)
	var dist = from.distance_to(to)
	
	if dist < 0.05: return
	
	var vel = (to-from)*SPEED
	velocity.x += vel.x
	velocity.z += vel.z


