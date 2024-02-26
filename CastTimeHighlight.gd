class_name CastHighlight
extends Node3D

var OPACITY_SPEED = 5

@onready var mmi : MultiMeshInstance3D = $HighlightMultiMesh
var material : StandardMaterial3D 

func _ready():
	material = mmi.multimesh.mesh.surface_get_material(0)

func _process(delta):
	if not visible: return
	material.albedo_color.a8 += OPACITY_SPEED
	if material.albedo_color.a8 >= 255 or material.albedo_color.a8 <= 0:
		OPACITY_SPEED *= -1

# Cells used as input should be relative to the CastTimeHighlight position i.e. a unit's position.
# For eg. if unit.cell = (2, 1, 1) and require (2, 1, 2), the input cell should be (0, 1, 0)
func set_cell_highlighters(cells : Array):
	visible = true
	
	mmi.multimesh.instance_count = cells.size()
	for instance_number in cells.size():
		var cell = cells[instance_number] as Vector3
		mmi.multimesh.set_instance_transform(instance_number, Transform3D(Basis(), cell+Vector3.UP*0.05))

func clear_highlighters():
	visible = false
