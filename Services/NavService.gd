class_name NavAvailable
extends Node

@onready var battle_map : GridMap = $"../Environment/BattleMap"

var _astar_map = AStarCustom.new()
var _path : PackedVector3Array

var nav_cells
var max_height

var current_unit : Unit

var DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]

func _ready():
	nav_cells = battle_map.get_viewable_tiles()
	max_height = battle_map.max_height
	initialise_astar()

# Recursive flood fill algorithm
func cell_flood_fill(tile : Vector3i, move_range : int, jump_range : int, steps : int):
	if steps > move_range: return []
	if tile not in nav_cells: return []
	
	var arr = [tile]
	
	var blocked_height = jump_range+1
	var block_tile = tile
	
	# Check block min: 2 blocks above curr tile, max: max_height
	for h in range(2, jump_range+1):
		block_tile.y = h+tile.y
		if block_tile in nav_cells: 
			blocked_height = h
			break
	
	var to_check = []
	for dir in DIRECTIONSi:
		var new_tile = tile + dir
		
		# Only get the highest block below the current tile.
		for h in range(0, jump_range+1):
			var check_vec = new_tile + h*Vector3i.DOWN
			if check_vec in nav_cells:
				to_check.append(check_vec)
				break
		
		# Obtain blocks above current tile that are below the blocked height.
		for h in range(0, blocked_height):
			to_check.append(new_tile+h*Vector3i.UP)
	
	for t in to_check:
		arr.append_array(cell_flood_fill(t, move_range, jump_range, steps+1))
	
	return arr

# unit: Unit on the battlemap to be queried
# inverted : Gets all squares within unit's range if false, otherwise invert the squares if true.
func get_reachable_tiles(unit : Unit, inverted : bool = false):
	var tsc = battle_map.local_to_map(unit.ts_cell)
	var mr = unit.move_comp.move_range
	var jr = unit.move_comp.jump_range
	
	# Flood fill algorithm
	var avail_tiles = cell_flood_fill(tsc, mr, jr, 0)
	
	var unique_tiles = []

	# Check uniqueness
	for t in avail_tiles:
		if t not in unique_tiles: 
			unique_tiles.append(t)
	
	if inverted:
		var invert_tiles = []
		for t in nav_cells:
			if t not in unique_tiles:
				invert_tiles.append(t)
		return invert_tiles
	
	return unique_tiles

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
	
	# Need to translate down given block position i.e. block is placed above grid.
	_path = _astar_map.get_path(unit.unit_cell, pos)
	print(_path)
	if _path.is_empty(): return []
	
	unit.path_stack = _path
	unit._next_point = _path[0]
	return _path
