class_name AStarCustom
extends AStar3D

var id_count = 0
var ids = {}

var disabled_ids = []
var unique_ids = []

func get_pointid(tile : Vector3i) -> int:
	if ids.has(tile):
		return ids[tile]
		
	var count = id_count
	ids[tile] = count
	id_count += 1
	return count

func get_all_points(ta : Array):
	ta = ta.map(get_pointid)
	print(ta)
	return ta
	
func disable_pt(tile : Vector3i):
	var id = get_pointid(tile)
	#if id in disabled_ids: return
	disabled_ids.append(id)
	set_point_disabled(id)

func enable_all_disable():
	for id in disabled_ids:
		set_point_disabled(id, false)
	disabled_ids.clear()

func get_path(v1 : Vector3i, v2 : Vector3i) -> PackedVector3Array:
	var id1 = get_pointid(v1)
	var id2 = get_pointid(v2)
	print(v1, v2)
	return get_point_path(id1, id2)
