class_name CastHighlight
extends Node3D

@export var highlight_mesh : MeshInstance3D

var highlight_material : StandardMaterial3D

var TRANS_INCREMENT : int = 5

func _ready():
	highlight_material = highlight_mesh.get_surface_override_material(0)

func _process(delta):
	highlight_material.albedo_color.a8 += TRANS_INCREMENT
	if highlight_material.albedo_color.a8 >= 255 or highlight_material.albedo_color.a8 <= 0:
		TRANS_INCREMENT *= -1
		
func set_to_cell(cell : Vector3):
	highlight_mesh.global_position = cell + Vector3.UP*0.1
