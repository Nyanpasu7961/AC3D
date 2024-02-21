class_name CastHighlight
extends Node3D

@export var highlight_mesh : MeshInstance3D
@onready var multimesh_instance : MultiMeshInstance3D = $HighlightMultiMesh

var highlight_material : StandardMaterial3D

var TRANS_INCREMENT : int = 5

func _ready():
	#var test_cells : Array[Vector3] = [Vector3.ZERO, Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
	#set_cell_highlighters(test_cells)
	pass

func _process(delta):
	pass
		
# Cells used as input should be relative to the CastTimeHighlight position i.e. a unit's position.
# For eg. if unit.cell = (2, 1, 1) and require (2, 1, 2), the input cell should be (0, 1, 0)
func set_cell_highlighters(cells : Array):
	multimesh_instance.set_cell_highlighters(cells)

func clear_highlighters():
	multimesh_instance.clear_highlighters()
