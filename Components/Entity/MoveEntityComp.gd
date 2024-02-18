class_name MoveComponent
extends Node3D

var attr_comp : EntityParameters

@export var TIME_TO_PEAK : float = 0.5
@export var TIME_TO_FALL : float = 0.4

var jump_height : float
var jump_vel : float
var jump_gravity : float
var fall_gravity : float

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

# animation
var curr_frame : int = 0
var animator = null

func initialise_move_comp(ac : EntityParameters):
	attr_comp = ac
	jump_height = attr_comp._base_attributes.JUMP
	jump_vel = 2*jump_height/TIME_TO_PEAK
	jump_gravity = -2*jump_height/pow(TIME_TO_PEAK, 2)
	fall_gravity = -2*jump_height/pow(TIME_TO_FALL, 2)
