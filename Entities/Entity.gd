class_name Entity
extends CharacterBody3D

@export var health_comp : HealthComponent
@export var move_comp : MoveComponent
@export var attr_comp : EntityParameters

var height_scale : float = 1

func get_gravity() -> float:
	return height_scale*(move_comp.jump_gravity if velocity.y > 0 else move_comp.fall_gravity)

func deal_damage(dmg : float):
	print("ouch")
	health_comp.take_dmg(dmg)
