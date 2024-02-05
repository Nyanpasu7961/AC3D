class_name MoveComponent
extends Node3D

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

var move_range = 6
var jump_range = 1

# animation
var curr_frame : int = 0
var animator = null

var is_jumping = false

func jump():
	is_jumping = true
	
