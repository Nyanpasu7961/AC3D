extends MultiMeshInstance3D

var meow = 4

var mat : StandardMaterial3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(20):
		for z in range(20):
			multimesh.set_instance_transform(x*20+z, Transform3D(Basis(), Vector3(x, 0, -z)))
		
	mat = multimesh.mesh.surface_get_material(0)

func _process(delta):
	mat.albedo_color.a8 += meow
	if mat.albedo_color.a8 >= 255 or mat.albedo_color.a8 <= 0:
		meow *= -1
