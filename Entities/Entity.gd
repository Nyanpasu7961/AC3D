class_name Entity
extends CharacterBody3D

@export var health_comp : HealthComponent
@export var move_comp : MoveComponent
@export var attr_comp : EntityParameters

var battle_map : BattleMap
var camera_comp : CameraBody
var nav_serve : NavService
var ui_control : UIComponent

var height_scale : float = 1

func _initialise_entity(bm : BattleMap, cam : CameraBody, uc : UIComponent, ns : NavService):
	battle_map = bm
	camera_comp = cam
	ui_control = uc
	nav_serve = ns

func deal_damage(dmg : float):
	print("ouch")
	health_comp.take_dmg(dmg)
