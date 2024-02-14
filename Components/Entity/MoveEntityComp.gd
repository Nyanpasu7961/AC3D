class_name MoveComponent
extends Node3D

@export var TIME_TO_PEAK : float = 0.5
@export var TIME_TO_FALL : float = 0.4

@export var move_range : int = 8
@export var jump_range : int = 4

var jump_height = jump_range
var jump_vel = 2*jump_height/TIME_TO_PEAK
var jump_gravity = -2*jump_height/pow(TIME_TO_PEAK, 2)
var fall_gravity = -2*jump_height/pow(TIME_TO_FALL, 2)

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

# animation
var curr_frame : int = 0
var animator = null

func obtain_move_attr():
	jump_height = jump_range
	jump_vel = 2*jump_height/TIME_TO_PEAK
	jump_gravity = -2*jump_height/pow(TIME_TO_PEAK, 2)
	fall_gravity = -2*jump_height/pow(TIME_TO_FALL, 2)
