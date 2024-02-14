extends Control
class_name UIComponent

@onready var control_containers = $TurnUIControl

func get_act(action : String = ""):
	if action == "": return control_containers
	return control_containers.get_node(action + "Container").get_node(action)

func is_hovered():
	var view_mouse_pos = get_viewport().get_mouse_position()
	for box in get_children():
		if Rect2(box.position, box.size).has_point(view_mouse_pos) and box.visible:
			return true
	return false
