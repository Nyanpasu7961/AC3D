class_name HealthComponent
extends Node3D

@onready var hp_bar : TextureProgressBar = $BarViewPort/Bar
@onready var bar_sprite : Sprite3D = $BarSprite

const BAR_DISTANCE = 0.5

var attr_comp : EntityParameters

@export var MAX_HP : float
var curr_hp : float

var hp_changed = false

func _ready():
	hp_bar.max_value = MAX_HP
	curr_hp = MAX_HP
	hp_bar.value = curr_hp
	
	bar_sprite.position = Vector3.UP*0.5

func _process(delta):
	global_rotation = Vector3.ZERO
	if hp_changed:
		# TODO: Put decrease health animation here.
		hp_bar.value = curr_hp
		hp_changed = false

func take_dmg(dmg : float):
	hp_changed = true
	curr_hp -= dmg
	if curr_hp < 0:
		print("death")

func heal(health : float):
	hp_changed = true
	curr_hp = min(health+curr_hp, MAX_HP)
