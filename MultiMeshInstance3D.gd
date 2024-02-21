extends MultiMeshInstance3D

var meow = 4

var mat : StandardMaterial3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = multimesh.mesh.surface_get_material(0)

func _process(delta):
	if not visible: return
	mat.albedo_color.a8 += meow
	if mat.albedo_color.a8 >= 255 or mat.albedo_color.a8 <= 0:
		meow *= -1

# Cells used as input should be relative to the CastTimeHighlight position i.e. a unit's position.
# For eg. if unit.cell = (2, 1, 1) and require (2, 1, 2), the input cell should be (0, 1, 0)
func set_cell_highlighters(cells : Array):
	visible = true
	multimesh.instance_count = cells.size()
	for instance_number in cells.size():
		var cell = cells[instance_number] as Vector3
		multimesh.set_instance_transform(instance_number, Transform3D(Basis(), cell+Vector3.UP*0.05))
	
func clear_highlighters():
	visible = false
