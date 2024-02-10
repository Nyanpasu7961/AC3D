class_name BattleMap
extends GridMap

@onready var border_map : GridMap = $BorderMap
@onready var hover_high : GridMap = $HoverHighlight 
@onready var move_high : GridMap = $MoveHighlight

const BORDER_OFFSET_Y : int = 5

# Stores available tiles in use.
var nav_cells = []
var max_height : int
var min_height : int

var DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]

func set_hover(tile : Vector3):
	var highlight_tile = l_transform_m(tile)
	
	# Ignore hover if hovered tile is not on the grid.
	if highlight_tile in nav_cells:
		hover_high.clear()
		hover_high.set_cell_item(highlight_tile, 0)

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
