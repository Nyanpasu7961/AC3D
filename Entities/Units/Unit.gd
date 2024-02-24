class_name Unit
extends CharacterBody3D

@export var health_comp : HealthComponent
@export var move_comp : MoveComponent
@export var attr_comp : EntityParameters

const SPEED = 5.0
const AUTO_SPEED = 5.0
const JUMP_VELOCITY = 2.0

var battle_map : GridMap
var camera_comp : CameraBody
var nav_serve : NavService
var ui_control : UIComponent

# Check if the currently controlled unit is this one.
var is_active = false
# Check if skill area is currently being selected
var skill_select = false

var map_id

var DIRECTIONS = [Vector3.FORWARD, Vector3.BACK, Vector3.RIGHT, Vector3.LEFT]


var cell_size
# Cell unit is on at turn start.
var ts_cell : Vector3i
var unit_cell : Vector3i

var grab_next_vel = true
var path_stack : PackedVector3Array
var is_moving = false
var _next_point = Vector3i()

var tested = false

# Square of length 0.25m
const ARRIVE_DISTANCE = 0.25

var height_scale : float = 1

func _initialise_unit_mvmt(bm : BattleMap, cam : CameraBody, uc : UIComponent, ns : NavService):
	battle_map = bm
	camera_comp = cam
	ui_control = uc
	nav_serve = ns
	
	health_comp.initialise_health_comp(attr_comp)
	move_comp.initialise_move_comp(attr_comp)
	
	cell_size = battle_map.cell_size
	ts_cell = battle_map.local_to_map(global_position)
	map_id = battle_map.get_instance_id()
	unit_cell = battle_map.local_to_map(global_position)

func _process(delta):
	adjust_healthbar()
	pass

func _input(event):
	if !is_active or skill_select: return
	if ui_control.is_hovered(): return
	
	if event.is_action_pressed("select_tile"):
		var mouse_tile = camera_comp.get_mouse_position()
		if mouse_tile:
			nav_serve.astar_unit_path(self, battle_map.l_transform_m(mouse_tile))

func adjust_healthbar():
	var cam_rot = camera_comp.pivot.rotation
	var rot_x = snapped(cam_rot.x, 0.01)
	var rot_y = snapped(cam_rot.y, 0.01)
	
	var bar_pos = lerp(Vector3(0, health_comp.BAR_DISTANCE, 0),Vector3(0, 0, health_comp.BAR_DISTANCE), 2*rot_x/PI)
	health_comp.bar_sprite.position = (bar_pos).rotated(Vector3.UP, rot_y)

func get_gravity() -> float:
	return height_scale*(move_comp.jump_gravity if velocity.y > 0 else move_comp.fall_gravity)

func path_movement(delta):
	var arrived_to_next_point = _move_to(_next_point, delta)
	if arrived_to_next_point:
		path_stack.remove_at(0)
		unit_cell = battle_map.local_to_map(global_position)
		if path_stack.is_empty():
			is_moving = false
			return
		_next_point = path_stack[0] as Vector3i

func _move_to(local_position, delta):
	is_moving = true
	# Move only in terms of the xz directions.
	var desired_velocity = local_position - unit_cell
	
	var adjusted_pos : Vector3 = translate_grid_center(global_position, false)
	# Needed cause unit global position is translated y_pos +0.7m.
	# Should only care about ground below unit.
	adjusted_pos.y = floor(adjusted_pos.y)
	
	# y component velocity
	if desired_velocity.y > 0:
		global_position.y += desired_velocity.y
		unit_cell = battle_map.local_to_map(global_position)
	
	velocity.x = desired_velocity.x*AUTO_SPEED
	velocity.z = desired_velocity.z*AUTO_SPEED
	
	if desired_velocity.y < 0 and not is_on_floor():
		velocity.x = 0
		velocity.z = 0
		velocity.y += get_gravity()*delta
	
	if desired_velocity.y != 0 and is_on_floor():
		unit_cell = battle_map.local_to_map(global_position)
	
	#l_inf norm, returns distance in terms of a geometric square.
	var res = adjusted_pos - (local_position as Vector3)
	var norm = max(abs(res.x),abs(res.z))
	
	return norm <= ARRIVE_DISTANCE

func check_input():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = move_comp.jump_vel
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, camera_comp.y_rot)
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

func _physics_process(delta):
	if not is_active or skill_select: return
	
	if not path_stack.is_empty():
		path_movement(delta)
	
	if not is_moving:
		unit_cell = battle_map.local_to_map(global_position)
		check_input()
	
	if velocity.x == 0 and velocity.z == 0: 
		snap_to_grid()
	
	if move_and_slide():
		var collide = get_last_slide_collision()
		var normal = collide.get_normal()
	
	# Add the gravity.
	if not is_on_floor() and not is_moving: 
		velocity.y += get_gravity()*delta
	
	if not is_moving:
		tested = false
	
func translate_grid_center(cell : Vector3, grab_center : bool = true):
	var t_vec = Vector3(cell_size.x/2, 0, cell_size.z/2)
	return cell + (t_vec if grab_center else -t_vec)

func force_snap_to_grid():
	var cell = battle_map.local_to_map(global_position) as Vector3
	var to = cell+Vector3(cell_size.x/2, 0, cell_size.z/2)
	global_position = to

# Readjusts unit to nearest grid position.
func snap_to_grid():
	var cell = battle_map.local_to_map(global_position) as Vector3
	var from = Vector3(global_position.x, cell.y, global_position.z)
	var to = cell+Vector3(cell_size.x/2, 0, cell_size.z/2)
	var dist = from.distance_to(to)
	
	if dist < 0.05: return
	
	var vel = (to-from)*SPEED
	velocity.x += vel.x
	velocity.z += vel.z

func deal_damage(dmg : float):
	print("ouch")
	health_comp.take_dmg(dmg)

func skill_damage(skill : Skill):
	# Show AOE
	#print(skill.name)
	#attr_comp.skill_damage(skill)
	return

func _obtain_basic_attack():
	return attr_comp._main_job.basic_attack

func _obtain_sub_skills():
	return attr_comp._sub_job.sub_skills

func _obtain_main_skills():
	return attr_comp._main_job.main_skills

