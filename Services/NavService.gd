class_name NavAvailable
extends Node

@onready var battle_map : GridMap = $"../Environment/BattleMap"

var _astar_map = AStarCustom.new()
var _path : PackedVector3Array

var nav_cells : Array
var max_height : int
var min_height : int

var current_unit : Unit

var DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]

func _ready():
	nav_cells = get_viewable_tiles()
	initialise_astar()

func sort_y_descend(a, b):
	return a.y > b.y

func get_viewable_tiles():
	var cells = battle_map.get_used_cells().map(func (x): return x + Vector3i.UP)
	cells.sort_custom(sort_y_descend)
	
	# Remove tiles that have a block above them.
	nav_cells = cells.filter(func (x): return (x + Vector3i.UP) not in cells)
	max_height = cells[0].y
	min_height = cells[cells.size()-1].y
	
	battle_map.nav_cells = nav_cells
	return nav_cells

class FloodCell:
	var tile : Vector3i
	var step : int
	
	func _init(t, s):
		tile = t
		step = s

# Iterative flood fill algorithm
func cell_flood_fill(tile : Vector3i, move_range : int, jump_range : int):
	
	var fc_root = FloodCell.new(tile, 0)
	
	var queue = [fc_root]
	var result : Dictionary = {}
	
	while not queue.is_empty():
		
		var fc = queue.pop_front()
		var curr_cell = fc.tile
		var steps = fc.step
		
		if steps > move_range: continue
		if curr_cell not in nav_cells: continue
		
		if result.has(curr_cell):
			if result[curr_cell] <= steps: continue
		
		result[curr_cell] = steps
		
		var blocked_jump = min(max_height-curr_cell.y, jump_range)
		
		for h in range(2, blocked_jump):
			if curr_cell + h*Vector3i.UP in nav_cells:
				blocked_jump = h-1
				break
		
		for dir in DIRECTIONSi:
			var new_t = curr_cell+dir
			
			for h in range(0, blocked_jump+1):
				var added_cell = new_t + h*Vector3i.UP
				var new_fc = FloodCell.new(added_cell, steps+1)
				queue.push_back(new_fc)
			
			for h in range(0, -jump_range-1, -1):
				var added_cell = new_t + h*Vector3i.UP
				
				if added_cell in nav_cells:
					var new_fc = FloodCell.new(added_cell, steps+1)
					queue.push_back(new_fc)
					break
	
	return result.keys()

# unit: Unit on the battlemap to be queried
# inverted : Gets all squares within unit's range if false, otherwise invert the squares if true.
func get_reachable_tiles(unit : Unit, inverted : bool = false):
	var tsc = battle_map.local_to_map(unit.ts_cell)
	var mr = unit.move_comp.move_range
	var jr = unit.move_comp.jump_range
	
	# Flood fill algorithm
	var avail_tiles = cell_flood_fill(tsc, mr, jr)
	
	if inverted:
		var invert_tiles = []
		for t in nav_cells:
			if t not in avail_tiles:
				invert_tiles.append(t)
		return invert_tiles
	
	return avail_tiles


func get_border(avail_tiles : Array, unit : Unit):
	var move_range = unit.move_comp.move_range
	var jump_range = unit.move_comp.jump_range
	
	var border_max = unit.unit_cell + Vector3(move_range, jump_range, move_range)
	var border_min = unit.unit_cell - Vector3(move_range, jump_range, move_range)
	
	var unique_borders = []
	
	for t in avail_tiles:
		for dir in DIRECTIONSi:
			var new_t = t + dir
			
			if new_t in avail_tiles:
				continue
			if new_t in unique_borders:
				continue
			
			# Check: given a border tile, is there a highlighted tile below it?
			var tile_below = false
			for h in range(new_t.y, border_min.y, -1):
				var check_t = Vector3i(new_t.x, h, new_t.z)
				if check_t in avail_tiles:
					tile_below = true
					break
			if tile_below: continue
			
			
			
			for h in range(new_t.y, border_max.y+2):
				new_t.y = h
				if new_t in avail_tiles: break
				unique_borders.append(new_t)
	
	for x in range(border_min.x, border_max.x+1):
		for z in range(border_min.z, border_max.z+1):
			unique_borders.append(Vector3i(x, border_min.y, z))
			unique_borders.append(Vector3i(x, border_max.y+2, z))
			
	return unique_borders

func initialise_astar():
	
	var tile_no = nav_cells.size()
	_astar_map.reserve_space(tile_no)

	# Add all points to astar
	for t in nav_cells:
		var id = _astar_map.get_pointid(t)
		_astar_map.add_point(id, t)
	
	# Connect all adjacent points.
	for t in nav_cells:
		var id = _astar_map.get_pointid(t)
		
		# Get lowest block above current tile.
		var blocked_height = max_height+1
		var curr_tile = Vector3(t.x, 0, t.z)
		
		for h in range(t.y+1, max_height+1):
			curr_tile.y = h
			var id2 = _astar_map.get_pointid(curr_tile)
			if !_astar_map.has_point(id2): continue
			blocked_height = h
			break
		
		for d in DIRECTIONSi:
			var new_t = t + d
			
			# Grab all blocks higher than current tile, not exceeding or equal to blocked_height-1
			for h in range(t.y+1, blocked_height-1):
				new_t.y = h
				var id2 = _astar_map.get_pointid(new_t)
				if !_astar_map.has_point(id2): continue
				_astar_map.connect_points(id, id2)
			
			# Grab highest block from below current tile.
			for h in range(t.y, -1, -1):
				new_t.y = h
				var id2 = _astar_map.get_pointid(new_t)
				if !_astar_map.has_point(id2): continue
				_astar_map.connect_points(id, id2)
				break
		

func astar_reachable_tiles(unit : Unit):
	# Re-enable all previously disabled tiles.
	_astar_map.enable_all_disable()
	
	var invert_avail_tiles = get_reachable_tiles(unit, true)
	for t in invert_avail_tiles:
		_astar_map.disable_pt(t)
	

func astar_unit_path(unit : Unit, pos : Vector3i) -> PackedVector3Array:
	if current_unit != unit:
		astar_reachable_tiles(unit)
		current_unit = unit
	
	unit.unit_cell = battle_map.local_to_map(unit.global_position)
	
	# Need to translate down given block position i.e. block is placed above grid.
	_path = _astar_map.get_path(unit.unit_cell, pos)
	print(_path)
	if _path.is_empty(): return []
	
	
	unit.path_stack = _path
	unit._next_point = _path[0]
	
	return _path
