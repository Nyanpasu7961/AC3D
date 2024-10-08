class_name CameraBody
extends CharacterBody3D

var rot_displacement = PI/4

const MOVE_SPEED = 16
const ROT_SPEED = 10
const RAY_LENGTH = 1000
const FULL_ROT = 2*PI

var zoom : float = 0
@export var zoom_step : float = 0.1
@export var ZOOM_LIMIT : int = 3

var initial_cam_pos : Vector3

# Holds rotation in radians
var x_rot : float
var y_rot : float

var desired_fov : float

@onready var pivot = $CameraComp
@onready var camera = $CameraComp/ACamera
@onready var ray : RayCast3D = $CameraComp/ACamera/CameraRay

# Used if player wants to move camera freely.
var move_mode = false

var has_moved = false

# Snap screen to target unit.
var target : Unit = null
var target_position : Vector3

func _ready():
	desired_fov = camera.fov
	initial_cam_pos = camera.position
	
	var rot = pivot.get_rotation()
	x_rot = rot.x
	y_rot = rot.y

func _input(event : InputEvent):
	camera_zoom(event)
	camera_rot(event)

func _process(delta):
	rotate_camera(delta)
	follow()

func camera_zoom(event):
	if event.is_action("zoom_in"):
		zoom -= zoom_step
	elif event.is_action("zoom_out"):
		zoom += zoom_step
		
	zoom = clamp(zoom, -ZOOM_LIMIT, ZOOM_LIMIT)
	camera.position.z = initial_cam_pos.z + zoom

func camera_rot(event):
	if event.is_action_pressed("rot_left"):
		set_process_input(false)
		y_rot -= rot_displacement
		if y_rot < 0:
			pivot.rotation.y += FULL_ROT
			y_rot += FULL_ROT
		has_moved = true
		
	elif event.is_action_pressed("rot_right"):
		set_process_input(false)
		y_rot += rot_displacement
		if y_rot > FULL_ROT:
			pivot.rotation.y -= FULL_ROT
			y_rot -= FULL_ROT
		has_moved = true
	
	elif event.is_action_pressed("rot_up"):
		set_process_input(false)
		x_rot = clamp(x_rot - rot_displacement, -PI/2, 0)
		has_moved = true
	
	elif event.is_action_pressed("rot_down"):
		set_process_input(false)
		x_rot = clamp(x_rot + rot_displacement, -PI/2, 0)
		has_moved = true

func move_camera(h, v, joystick):
	if !joystick and h == 0 and v == 0 or target: return
	var angle = (atan2(-h, v))+pivot.get_rotation().y
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle)
	var vel = dir*MOVE_SPEED
	if joystick: vel = vel*sqrt(pow(h, 2)+pow(v, 2))
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity

func rotate_camera(delta):
	var curr_r = pivot.get_rotation()
	var dst_r = Vector3(x_rot, y_rot, 0)
	pivot.set_rotation(curr_r.lerp(dst_r, ROT_SPEED*delta))
	set_process_input(true)

func change_target(unit : Unit):
	target = unit
	target_position = target.global_transform.origin

func follow():
	if target == null: return
	
	var from = global_transform.origin
	target_position = target.global_transform.origin
	
	var dist = from.distance_to(target_position)
	
	var vel = (target_position-from)*MOVE_SPEED/4
	if dist <= 0.25:
		vel = vel*4*max(dist-0.05, 0)
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity
	
	has_moved = true

func get_mouse_position():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Intersects two rays to determine mouse position.
	# Moves origin of normal ray to mouse_pos origin to find position relative to camera.
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos)*RAY_LENGTH
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	# Exclude units from ray here.
	params.set_collision_mask(1)
	var ray_intersect = space_state.intersect_ray(params)
	# Return position onto 3d map, if tile exists.
	if ray_intersect: return ray_intersect["position"]
	# Else return neg vector given no tile.
	return null


