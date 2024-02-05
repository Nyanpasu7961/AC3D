class_name BattleMap
extends GridMap

@onready var hover_high : GridMap = $HoverHighlight 
@onready var move_high : GridMap = $MoveHighlight

# Stores available tiles in use.
var nav_cells = []
var max_height : int

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

func sort_y_descend(a, b):
	return a.y > b.y

func get_viewable_tiles():
	var cells = get_used_cells().map(func (x): return x + Vector3i.UP)
	cells.sort_custom(sort_y_descend)
	nav_cells = cells.filter(func (x): return (x + Vector3i.UP) not in cells)
	max_height = cells[0].y
	return nav_cells

func set_border():
	pass
