class_name BattleMap
extends GridMap

@onready var border_map : GridMap = $BorderMap
@onready var move_high : GridMap = $MoveHighlight

@onready var skill_map : GridMap = $SkillStuff

@onready var cast_map : CastMap = $CastHandler

@onready var hover_high : MeshInstance3D = $HoverHighlight

var skill_mat : StandardMaterial3D

var TRANS_INCREMENT : int = 5

const BORDER_OFFSET_Y : int = 5

# Stores available tiles in use.
var nav_cells = []
var max_height : int
var min_height : int

var DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]

var grid_translate = Vector3(cell_size.x/2, 0, cell_size.z/2)
var hover_translate = Vector3.UP*0.02

func tile_translate(tile : Vector3, grab_center : bool = true):
	var res = snapped(tile-grid_translate, cell_size)
	if grab_center: res += grid_translate
	return res

func set_hover(tile : Vector3):
	var highlight_tile = l_transform_m(tile)
	if highlight_tile in nav_cells:
		hover_high.global_position = tile_translate(tile) + hover_translate

func set_movement_high(cell_list : Array):
	move_high.clear()
	for cell in cell_list:
		move_high.set_cell_item(l_transform_m(cell), 1)

# New local_to_map, since raycast + gridmap does not like the local_to_map function.
# i.e. heights given from local_to_map transform are incorrect.		
func l_transform_m(cell : Vector3) -> Vector3i:
	cell.y = snapped(cell.y, cell_size.y)
	var map_cell = local_to_map(cell)
	return map_cell

func set_border(border_tiles : Array):
	border_map.clear()
	for cell in border_tiles:
		border_map.set_cell_item(cell, 0)

func map_set_skill(tiles : Array):
	skill_map.clear()
	for cell in tiles:
		skill_map.set_cell_item(l_transform_m(cell), 0)

## Cast Map Stuff
func add_skill_to_cast(sc : SkillCast, tiles : Array):
	cast_map.add_skill_to_cast(sc, tiles)

func rm_skill_to_cast(sc : SkillCast):
	cast_map.remove_skill_to_cast(sc)

func clear_cast_highlighter():
	cast_map.clear_cast_highlighter()

func place_cast_highlighter(tiles : Array, clear_prev : bool = true):
	cast_map.place_cast_highlighter(tiles, clear_prev)
	
