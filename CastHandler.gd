class_name CastHandler
extends Node3D

@export var casth_template : CastHighlight

var _tocast_h = {}
var multimesh_count : int = 0

var multimesh_queue : Array[CastHighlight]

func add_cast_highlighter(sc : SkillCast, cells : Array):
	var casth : CastHighlight = null
	
	if multimesh_count <= _tocast_h.size():
		
		casth = casth_template.duplicate()
		
		add_child(casth)
		multimesh_count += 1
		
	if casth == null:
		casth = multimesh_queue.pop_front()
		
	casth.set_cell_highlighters(cells)
	# Associate source with highlighter.
	_tocast_h[sc] = casth
	
func remove_highlighter(sc : SkillCast):
	_tocast_h[sc].clear_highlighters()
	multimesh_queue.push_back(_tocast_h[sc])
	_tocast_h.erase(sc)
	
