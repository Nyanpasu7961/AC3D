extends MeshInstance3D

# tile tint materials https://fffuel.co/cccolor/ 
var hover_mat = Utils.create_material("FFFFFF3F")

var reachable_mat = Utils.create_material("008fdbBF")
var hover_reachable_mat = Utils.create_material("0aa9ffBF")

var attackable_mat = Utils.create_material("d10000BF")
var hover_attackable_mat = Utils.create_material("ff4242BF")


enum HState {NONE, ATTACK, REACH}

var hover = false
var highlight = HState.NONE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	visible = (highlight != HState.NONE) or hover
	if !visible: return
	match highlight:
		HState.ATTACK: material_override = (hover_attackable_mat if hover else attackable_mat)
		HState.REACH: material_override = (hover_reachable_mat if hover else reachable_mat)
		HState.NONE:  material_override = hover_mat
