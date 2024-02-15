extends Control
class_name UIComponent

@onready var control_containers = $TurnUIControl
@onready var skill_scroll = $SkillScroll
@onready var skill_list : VBoxContainer = $SkillScroll/SkillList


func get_act(action : String = ""):
	if action == "": return control_containers
	return control_containers.get_node(action + "Container").get_node(action)

func is_hovered():
	var view_mouse_pos = get_viewport().get_mouse_position()
	for box in get_children():
		if box.visible and Rect2(box.position, box.size).has_point(view_mouse_pos):
			return true
	return false

func set_skill_list(skills : Array):
	skill_scroll.visible = true
	
	for s in skills:
		var button = Utils.create_skill_button(s)
		skill_list.add_child(button)
