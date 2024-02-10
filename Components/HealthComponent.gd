class_name HealthComponent
extends Node3D

@export var MAX_HP : float
var curr_hp : float

func _ready():
	curr_hp = MAX_HP

func take_dmg(dmg : float):
	curr_hp -= dmg
	if curr_hp < 0:
		print("death")

func heal(health : float):
	curr_hp = min(health+curr_hp, MAX_HP)

func increase_maxhp(inc : float):
	MAX_HP += inc
