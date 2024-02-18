class_name HealthComponent
extends Node3D

@onready var hp_bar : TextureProgressBar = $BarViewPort/Bar
@onready var bar_sprite : Sprite3D = $BarSprite

const BAR_DISTANCE = 0.5

var attr_comp : EntityParameters

var max_hp : float
var curr_hp : float

var hp_changed = false

func initialise_health_comp(ac : EntityParameters):
	attr_comp = ac
	max_hp = attr_comp._base_attributes.MAXHP
	
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	
	curr_hp = max_hp
	
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
	curr_hp = min(health+curr_hp, max_hp)
