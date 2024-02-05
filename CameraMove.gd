class_name CameraBody
extends CharacterBody3D

var rot_displacement = PI/4

const MOVE_SPEED = 16
const ROT_SPEED = 10

# Holds rotation in radians
var x_rot
var y_rot

@onready var pivot = $CameraComp

# Used if player wants to move camera freely.
var move_mode = false

# Snap screen to target unit.
var target : Unit = null

func _ready():
	var rot = pivot.get_rotation()
	x_rot = rot.x
	y_rot = rot.y

func move_camera(h, v, joystick):
	if !joystick and h == 0 and v == 0 or target: return
	var angle = (atan2(-h, v))+pivot.get_rotation().y
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle)
	var vel = dir*MOVE_SPEED
	if joystick: vel = vel*sqrt(h*h+v*v)
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity

func rotate_camera(delta):
	var curr_r = pivot.get_rotation()
	var dst_r = Vector3(x_rot, y_rot, 0)
	pivot.set_rotation(curr_r.lerp(dst_r, ROT_SPEED*delta))
	set_process_input(true)

func _input(event : InputEvent):
	
	if event.is_action_pressed("rot_left"):
		set_process_input(false)
		y_rot -= rot_displacement
		
		if y_rot < 0:
			y_rot += 2*PI
			pivot.rotation.y += 2*PI
		
	elif event.is_action_pressed("rot_right"):
		set_process_input(false)
		y_rot += rot_displacement
		if y_rot > 2*PI:
			y_rot -= 2*PI
			pivot.rotation.y -= 2*PI


func follow():
	if move_mode or !target: return
	var from = global_transform.origin
	var to = target.global_transform.origin
	
	var dist = from.distance_to(to)
	
	var vel = (to-from)*MOVE_SPEED/4
	if dist <= 0.25:
		vel = vel*4*max(dist-0.05, 0)
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity


func _process(delta):
	rotate_camera(delta)
	follow()
