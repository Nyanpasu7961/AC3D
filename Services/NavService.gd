class_name NavService
extends Node

var battle_map : BattleMap

var _astar_map = AStarCustom.new()
var _path : PackedVector3Array

var nav_cells : Array
var nav_cells_dict : Dictionary = {}
var max_height : int
var min_height : int

var max_y : int
var min_y : int
var avail_tiles : Array
var inverted_tiles : Array

var turn_changed = true

func _init_nav_serve(bm : BattleMap):
	battle_map = bm
	get_viewable_tiles()
	initialise_astar()

func sort_y_descend(a : Vector3i, b : Vector3i):
	return a.y > b.y

### Creates a semi-pillar starting from t.y up to y_max or at the defined heights.
func _pillar_generate(t: Vector3i, threshold : int, heights : Array = []) -> Array:
	if heights.is_empty():
		return range(t.y, threshold).map(func(h): return Vector3i(t.x, h, t.z))
	return heights.map(func(h): return Vector3i(t.x, h, t.z))

func _check_dict_has_tile(new_t : Vector3i) -> Array:
	if nav_cells_dict.has(new_t.x) and nav_cells_dict[new_t.x].has(new_t.z):
		return nav_cells_dict[new_t.x][new_t.z]
	return []

## Construct nav_cells in dictionary form. y-sorted descending by get_viewable_tiles().
func _create_nav_dict():
	for cell in nav_cells:
		if not nav_cells_dict.has(cell.x):
			nav_cells_dict[cell.x] = {}
		if not nav_cells_dict[cell.x].has(cell.z):
			nav_cells_dict[cell.x][cell.z] = []
			
		nav_cells_dict[cell.x][cell.z].append(cell.y)

func get_viewable_tiles():
	var cells = battle_map.get_used_cells().map(func (x): return x + Vector3i.UP)
	cells.sort_custom(func(a, b): return a.y > b.y)
	
	# Remove tiles that have a block above them.
	nav_cells = cells.filter(func (x): return (x + Vector3i.UP) not in cells)
	max_height = cells[0].y
	min_height = cells[cells.size()-1].y
	
	_create_nav_dict()
	
	battle_map.nav_cells = nav_cells
	return nav_cells

class FloodCell:
	var tile : Vector3i
	var step : int
	var forced_direction : Vector3i
	
	func _init(t, s):
		tile = t
		step = s

# Iterative flood fill algorithm
func cell_flood_fill(tile : Vector3i, move_range : int, jump_range : int, 
	flood_type : Utils.AreaType = Utils.AreaType.DIAMOND) -> Array:
	
	var directions = Utils.get_area_directions(flood_type)
	var check_cross = Utils.is_cross(flood_type)
	
	var fc_root = FloodCell.new(tile, 0)
	
	var queue = [fc_root]
	var result : Dictionary = {}
	
	var cells_to_check : Array
	
	while not queue.is_empty():
		
		var fc = queue.pop_front()
		var curr_cell = fc.tile
		var steps = fc.step
		
		# Check if max moves exceeded.
		if steps > move_range: continue
		# Check if on map.
		if curr_cell not in nav_cells: continue
		# Check if current cell is allocated to the minimum number of steps.
		if result.has(curr_cell) and result[curr_cell] <= steps: continue
		
		result[curr_cell] = steps
		
		# Obtain maximum height that can be jumped to.
		var blocked_jump = min(max_height, curr_cell.y+jump_range)
		## Assumes list is y-sorted descending.
		var nav_above = _check_dict_has_tile(curr_cell).filter(func(h): return h > curr_cell.y)
		
		if not nav_above.is_empty():
			blocked_jump = min(blocked_jump, nav_above.back()-1)
		
		# Go in forced direction if floodtype is a CROSS.
		# Exception for first step, need to initialise direction for future steps.
		var dir_to_check = [fc.forced_direction] if check_cross and steps > 0 else directions
		
		# Flood to adjacent cells directed by dir_to_check
		for dir in dir_to_check:
			var new_t = curr_cell + dir
			cells_to_check = flood_helper(new_t, steps, blocked_jump, jump_range)
			if check_cross:
				cells_to_check = add_cross_attribute(cells_to_check, dir)
			queue.append_array(cells_to_check)
		
	return result.keys()

func add_cross_attribute(to_check : Array, dir : Vector3i):
	return to_check.map(func(cell): 
		cell.forced_direction = dir; return cell)

func flood_helper(new_t : Vector3i, steps : int, blocked_jump : int, jump_range: int):
	var to_push_queue = []
	
	# Generate all possible jumps within new_t (x, z)-coordinates.
	var meow = _pillar_generate(new_t, blocked_jump+1).map(func(x): return FloodCell.new(x, steps+1))
	to_push_queue.append_array(meow)
	
	# Generate highest fall within new_t (x, z)-coordinates.
	var nav_res = _check_dict_has_tile(new_t).filter(func(h): return h < new_t.y and new_t.y - h < jump_range)
	if not nav_res.is_empty():
		new_t.y = nav_res.front()
		var new_fc = FloodCell.new(new_t, steps+1)
		to_push_queue.append(new_fc)
	
	return to_push_queue

## For defining movement borders.
const MAP_Y_MAX = 100000
const MAP_Y_MIN = -100000

# unit: Unit on the battlemap to be queried
# inverted : Gets all squares within unit's range if false, otherwise invert the squares if true.
func get_reachable_tiles(unit : Unit) -> Array:
	# Flood fill algorithm
	if turn_changed:
		var tsc = battle_map.local_to_map(unit.ts_cell)
		var mr = unit.attr_comp._base_attributes.MOVE
		var jr = unit.attr_comp._base_attributes.JUMP
		
		avail_tiles = cell_flood_fill(tsc, mr, jr)
		inverted_tiles = nav_cells.filter(func(x): return x not in avail_tiles)
		
		# Obtain border heights.
		max_y = MAP_Y_MIN
		min_y = MAP_Y_MAX
		
		for tile in avail_tiles:
			max_y = max(max_y, tile.y)
			min_y = min(min_y, tile.y)
	
	return avail_tiles

func get_border(avail_tiles : Array, unit : Unit):
	var move_range = unit.attr_comp._base_attributes.MOVE
	var jump_range = unit.attr_comp._base_attributes.JUMP
	
	var border_max = unit.ts_cell + Vector3i(move_range, 0, move_range)
	var border_min = unit.ts_cell - Vector3i(move_range, 0, move_range)
	border_max.y = max_y
	border_min.y = min_y-1
	
	var MAX_HEIGHT = border_max.y+2
	
	var unique_borders = []
	
	## Check adjacency of non-available to determine if they are borders.
	for t in inverted_tiles:
		var is_border = false
		
		for dir in Utils.DIRECTIONSi:
			var new_t = t + dir
			
			var new_heights = _check_dict_has_tile(new_t)
			if new_heights.is_empty(): continue
			var nav_res = _pillar_generate(new_t, 0, new_heights)
			
			for vec in nav_res:
				if vec in avail_tiles:
					is_border = true
					break
			
			if is_border: break
					
					
		if is_border:
			var border_height = MAX_HEIGHT
			var nav_res = _check_dict_has_tile(t)
			nav_res = nav_res.filter(func(tile): return tile > t.y)
			
			if not nav_res.is_empty():
				border_height = nav_res.front()-2
				
			var border_res = _pillar_generate(t, border_height)
			unique_borders.append_array(border_res)
	
	## After checking boundary, check possible border tiles not defined on the map.
	for t in avail_tiles:
		for dir in Utils.DIRECTIONSi:
			var new_t = t + dir
			
			if new_t in avail_tiles:
				continue
			if new_t in unique_borders:
				continue
			
			## IMPORTANT: This assumes nav_cells is y-sorted in descending order.
			var border_height = MAX_HEIGHT
			var nav_res = _check_dict_has_tile(new_t)
			# Tile to be checked, varying y-coordinate during validation.
			var check_t = new_t
			
			# Check: given a border tile, is there a highlighted tile below it?
			# Stop if there is nav tile on check.
			var nav_below = nav_res.filter(func(x): return x < new_t.y)
			if not nav_below.is_empty():
				var check_below = nav_below.front()
				check_t.y = check_below
				if check_t in avail_tiles:
					continue
				
			# Check for tile above.
			var nav_above = nav_res.filter(func(x): return x > new_t.y)
			if not nav_above.is_empty():
				var check_above = nav_above.back()
				
				check_t.y = check_above
				if check_t in avail_tiles:
					border_height = check_above
				
			var border_res = _pillar_generate(new_t, border_height)
			unique_borders.append_array(border_res)
		
	## Create the square ceiling and floor of the border.
	for x in range(border_min.x, border_max.x+1):
		for z in range(border_min.z, border_max.z+1):
			unique_borders.append_array([Vector3i(x, border_min.y, z), Vector3i(x, border_max.y+2, z)])
			
	return unique_borders

func grab_skill_area(unit : Unit, skill : Skill):
	return cell_flood_fill(unit.unit_cell, skill._range, skill._height_range)

# TODO: Change to obtain highlights for different area types.
func grab_skill_aoe(tile : Vector3i, skill : Skill):
	return cell_flood_fill(tile, max(0, skill._area_length-1), skill._height_range, skill._area_type)

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
		## Relies on y-sorted dictionary.
		# Obtain all tiles at (x, .., z) above t.
		var nav_above = _check_dict_has_tile(t).filter(func(x): return x > t.y)
		# Obtains lowest out of all filtered blocks.
		if not nav_above.is_empty():
			blocked_height = nav_above.back()
		
		for d in Utils.DIRECTIONSi:
			var new_t = t + d
			
			# Grab all blocks higher or equal to current tile, not exceeding or equal to blocked_height-1
			var new_nav_above = _check_dict_has_tile(new_t).filter(func(x): return x >= new_t.y and x < blocked_height)
			for h in new_nav_above:
				new_t.y = h
				var id2 = _astar_map.get_pointid(new_t)
				_astar_map.connect_points(id, id2)
			
			# Grab highest block from below current tile.
			var new_nav_below = _check_dict_has_tile(new_t).filter(func(x): return x < new_t.y)
			if not new_nav_below.is_empty():
				new_t.y = new_nav_below.front()
				var id2 = _astar_map.get_pointid(new_t)
				_astar_map.connect_points(id, id2)
		

func astar_reachable_tiles(unit : Unit):
	# Re-enable all previously disabled tiles.
	_astar_map.enable_all_disable()
	for t in inverted_tiles:
		_astar_map.disable_pt(t)
	

func astar_unit_path(unit : Unit, pos : Vector3i) -> PackedVector3Array:
	if turn_changed:
		astar_reachable_tiles(unit)
		turn_changed = false
	
	unit.unit_cell = battle_map.local_to_map(unit.global_position)
	
	# Need to translate down given block position i.e. block is placed above grid.
	_path = _astar_map.get_path(unit.unit_cell, pos)
	print(_path)
	if _path.is_empty(): return []
	
	unit.path_stack = _path
	unit._next_point = _path[0] as Vector3i
	
	return _path
