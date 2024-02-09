class_name MoveComponent
extends Node3D

@export var TIME_TO_PEAK : float = 0.5
@export var TIME_TO_FALL : float = 0.2
@export var move_range : int = 8
@export var jump_range : int = 4

@onready var jump_height = jump_range
@onready var jump_vel = 2*jump_height/TIME_TO_PEAK
@onready var jump_gravity = -2*jump_height/pow(TIME_TO_PEAK, 2)
@onready var fall_gravity = -2*jump_height/pow(TIME_TO_FALL, 2)

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

# animation
var curr_frame : int = 0
var animator = null

var is_jumping = false


func jump():
	is_jumping = true
	
