class_name NavAvailable
extends Node

@onready var battle_map : GridMap = $"../Environment/BattleMap"

var _astar_map = AStarCustom.new()
var _path : PackedVector3Array

var nav_cells = []
var max_height

var tiles_obtained = false
var current_unit : Unit

var DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]

func _ready():
	get_viewable_tiles()
	initialise_astar()
	
	battle_map.nav_cells = nav_cells

func sort_y_descend(a, b):
	return a.y > b.y

func manhattan_xz(a, b):
	return abs(a.x - b.x) + abs(a.z - b.z)

func get_viewable_tiles():
	if tiles_obtained: return
	var cells = battle_map.get_used_cells().map(func (x): return x + Vector3i.UP)
	cells.sort_custom(sort_y_descend)
	nav_cells = cells.filter(func (x): return (x + Vector3i.UP) not in cells)
	tiles_obtained = true
	
	# Obtain maximum height of the map.
	max_height = cells[0].y
	
# unit: Unit on the battlemap to be queried
# inverted : Gets all squares within unit's range if false, otherwise invert the squares if true.
func get_reachable_tiles(unit : Unit, inverted : bool = false):
	var tsc = battle_map.local_to_map(unit.ts_cell)
	var mr = unit.move_comp.move_range
	var jr = unit.move_comp.jump_range
	
	# Grab all tiles within unit's move_range and jump_range
	var avail_tiles = nav_cells.filter(func (a): return inverted != ((abs(a.y - tsc.y) <= jr) and ((manhattan_xz(a, tsc) <= mr))) )
	return avail_tiles

#func get_tile_xz(xz_vector : Vector3):
	

func initialise_astar():
	var tile_no = nav_cells.size()
	_astar_map.reserve_space(tile_no)

	# Add all points to astar
	for t in nav_cells:
		var id = _astar_map.get_pointid(t)
		_astar_map.add_point(id, t)
	
	# Connect all adjacent points regardless of height.
	for t in nav_cells:
		var id = _astar_map.get_pointid(t)
		for d in DIRECTIONSi:
			var new_t = t + d
			
			for h in max_height:
				new_t.y = h
				var id2 = _astar_map.get_pointid(new_t)
				if !_astar_map.has_point(id2): continue
				_astar_map.connect_points(id, id2)

func astar_reachable_tiles(unit : Unit):
	# Re-enable all previously disabled tiles.
	_astar_map.enable_all_disable()
	
	var invert_avail_tiles = get_reachable_tiles(unit, true)
	#print(nav_cells.filter(func (x): return x not in invert_avail_tiles))
	for t in invert_avail_tiles:
		_astar_map.disable_pt(t)

func astar_unit_path(unit : Unit, pos : Vector3i) -> PackedVector3Array:
	if current_unit != unit:
		astar_reachable_tiles(unit)
		current_unit = unit
	
	# Need to translate down given block position i.e. block is placed above grid.
	_path = _astar_map.get_path(unit.unit_cell, pos)
	if _path.is_empty(): return []
	
	
	unit.path_stack = _path
	unit._next_point = _path[0]
	return _path

func _process(delta):
	pass
