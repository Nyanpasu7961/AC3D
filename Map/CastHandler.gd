class_name CastMap
extends GridMap

var material : StandardMaterial3D
var OPACITY_SPEED = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh = mesh_library.get_item_mesh(0)
	material = mesh.surface_get_material(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible: return
	material.albedo_color.a8 += OPACITY_SPEED
	if material.albedo_color.a8 >= 255 or material.albedo_color.a8 <= 0:
		OPACITY_SPEED *= -1

var prev_tiles : Array = []
var casting_tiles : Dictionary = {}
var used_for_cast : Array = []

var has_changed = true

func clear_cast_highlighter():
	clear()

func remove_skill_to_cast(sc : SkillCast):
	_remove_cast_highlighter(casting_tiles[sc])
	#casting_tiles.erase(sc)
	has_changed = true

func add_skill_to_cast(sc : SkillCast, tiles : Array):
	casting_tiles[sc] = tiles
	place_cast_highlighter(tiles, false)
	has_changed = true

func _casting_tiles():
	if has_changed:
		used_for_cast = casting_tiles.values().reduce(func(a, b): return a + b, [])
		has_changed = false
	return used_for_cast

func place_cast_highlighter(tiles : Array, clear_prev : bool = true):
	#print(_casting_tiles())
	tiles = tiles.filter(func(x): return not x in _casting_tiles())
	if clear_prev:
		_remove_cast_highlighter(prev_tiles)
		prev_tiles = tiles
	else:
		prev_tiles = []
	_add_cast_highlighter(tiles)
	
func _add_cast_highlighter(tiles : Array):
	if not visible: 
		visible = true
	for cell in tiles:
		set_cell_item(cell, 0)

func _remove_cast_highlighter(tiles : Array):
	for cell in tiles:
		set_cell_item(cell, -1)
		
	if get_used_cells().size() <= 0:
		visible = false
