class_name Unit
extends Entity

## Holds movement capabilities for playable characters.
## Allows for point-and-click movement via. A* and free movement through WASD.
## Holds wrapper functions when entity attributes are called and for turn handling.

const SPEED = 5.0
const AUTO_SPEED = 10.0
const JUMP_VELOCITY = 2.0

var orientation : Utils.Orientation = Utils.Orientation.NORTH

# Check if the currently controlled unit is this one.
var is_active = false
# Check if skill area is currently being selected
var skill_select = false

# Cell unit is on at turn start.
var ts_cell : Vector3i
var unit_cell : Vector3i

var grab_next_vel = true
var path_stack : PackedVector3Array
var is_moving = false
var _next_point = Vector3i()

# Square of length 0.25m
const ARRIVE_DISTANCE = 0.25

func _initialise_unit_mvmt(bm : BattleMap, cam : CameraBody, uc : UIComponent, ns : NavService):
	_initialise_entity(bm, cam, uc, ns)
	
	attr_comp.initialise(self)
	health_comp.initialise_health_comp(attr_comp, cam)
	move_comp.initialise_move_comp(attr_comp)
	
	ts_cell = battle_map.local_to_map(global_position)
	unit_cell = ts_cell

func _input(event):
	if not is_active or skill_select: return
	if ui_control.is_hovered(): return
	
	if event.is_action_pressed("select_tile"):
		var mouse_tile = camera_comp.get_mouse_position()
		if mouse_tile:
			nav_serve.astar_unit_path(self, battle_map.l_transform_m(mouse_tile))

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
	
	# Needed cause unit global position is translated y_pos +0.7m.
	# Should only care about ground below unit.
	var adjusted_pos = battle_map.tile_translate(global_position, false)
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
		# Update position.
		unit_cell = battle_map.local_to_map(global_position)
	
	#l_inf norm, returns distance in terms of a geometric square.
	var res = adjusted_pos - (local_position as Vector3)
	var norm = max(abs(res.x),abs(res.z))
	
	return norm <= ARRIVE_DISTANCE

func get_gravity() -> float:
	return height_scale*(move_comp.jump_gravity if velocity.y > 0 else move_comp.fall_gravity)

func check_input():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = move_comp.jump_vel
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, camera_comp.y_rot)
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else: _lerp_to_zero()
		
func _lerp_to_zero():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)

func _physics_process(delta):
	if not battle_map is BattleMap: return
	if skill_select: return
	
	if not path_stack.is_empty():
		path_movement(delta)
	
	if not is_moving:
		unit_cell = battle_map.local_to_map(global_position)
		if is_active: check_input()
		else: _lerp_to_zero()
	
	if velocity.x == 0 and velocity.z == 0: 
		snap_to_grid()
	
	if move_and_slide():
		var collide = get_last_slide_collision()
		var normal = collide.get_normal()
	
	# Add the gravity.
	if not is_on_floor() and not is_moving: 
		velocity.y += get_gravity()*delta


# Readjusts unit to nearest grid position.
func snap_to_grid():
	var cell = battle_map.local_to_map(global_position) as Vector3
	var from = Vector3(global_position.x, cell.y, global_position.z)
	var to = battle_map.tile_translate(cell)
	var dist = from.distance_to(to)
	
	if dist < 0.05: return
	
	var vel = (to-from)*SPEED
	velocity.x += vel.x
	velocity.z += vel.z

func skill_damage(skill : Skill):
	# Show AOE
	#print(skill.name)
	#attr_comp.skill_damage(skill)
	return

func _toggle_borders(b_toggle : bool):
	if b_toggle: collision_mask |= 0b10
	else: collision_mask &= ~(0b10)
	#print(collision_mask)

func _start_turn():
	_toggle_borders(true)

func _end_turn():
	is_active = false
	ts_cell = unit_cell if not is_moving else (path_stack[path_stack.size()-1] as Vector3i)
	_toggle_borders(false)

func _obtain_basic_attack():
	return attr_comp._main_job.basic_attack

func _obtain_sub_skills():
	return attr_comp._sub_job.sub_skills

func _obtain_main_skills():
	return attr_comp._main_job.main_skills

func _end_turn_clocktime(turn_type : int):
	attr_comp._ct_attributes.end_turn(turn_type)

func _clocktime_ready():
	return attr_comp._clocktime_ready()

# Obtain the amount of clock cycles needed to ready unit
func _obtain_predicted():
	return attr_comp._obtain_predicted_clocktime()

func _get_clocktime():
	return attr_comp.ct_attributes.clock_time

func _tick_clocktime():
	attr_comp.tick_clock_time()
