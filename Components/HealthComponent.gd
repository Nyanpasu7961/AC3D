class_name HealthComponent
extends Node3D

@onready var hp_bar : TextureProgressBar = $View/Bar
@onready var bar_sprite : Sprite3D = $BarSprite

@export var attr_comp : EntityAttrComp

@export var MAX_HP : float
var curr_hp : float

var hp_changed = false

func _ready():
	hp_bar.max_value = MAX_HP
	curr_hp = MAX_HP
	hp_bar.value = curr_hp

func _process(delta):
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
