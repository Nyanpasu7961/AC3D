extends Control
class_name UIComponent

@onready var control_containers = $TurnUIControl
@onready var skill_scroll = $SkillSelection/SkillScroll
@onready var skill_list : VBoxContainer = $SkillSelection/SkillScroll/SkillList
@onready var confirm_container = $SkillSelection/ConfirmHBox
@onready var confirm_button : Button = $SkillSelection/ConfirmHBox/ConfirmButton
@onready var back_button : Button = $SkillSelection/ConfirmHBox/BackButton



func get_act(action : String = ""):
	if action == "": return control_containers
	return control_containers.get_node(action + "Container").get_node(action)

func is_hovered():
	var view_mouse_pos = get_viewport().get_mouse_position()
	for box in get_children():
		if box.visible and Rect2(box.position, box.size).has_point(view_mouse_pos):
			return true
	return false

class ButtonHandler:
	var button : Button
	var skill : Skill
	
	func _init(b : Button, s : Skill):
		button = b
		skill = s

func disconnect_all_signals_name(button : Button, method : String):
	for c in button.get_signal_connection_list(method):
		button.disconnect(method, c["callable"])

func clear_skill_list():
	for button in skill_list.get_children():
		button.visible = false
		disconnect_all_signals_name(button, "pressed")

func set_skill_list(skills : Array):
	skill_scroll.visible = true
	
	var button_pointers = []
	
	var button_nodes = skill_list.get_children()
	while button_nodes.size() < skills.size():
		skill_list.add_child(Button.new())
	
	for i in range(skills.size()):
		button_nodes[i].visible = true

		button_nodes[i].text = skills[i].name
		button_pointers.append(ButtonHandler.new(button_nodes[i], skills[i]))

	return button_pointers

func set_confirm():
	confirm_button.visible = true
	return confirm_button
