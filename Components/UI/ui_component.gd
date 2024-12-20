extends Control
class_name UIComponent

@onready var control_containers = $TurnUIControl

@onready var skill_selection_cont = $SkillSelection
@onready var skill_scroll = $SkillSelection/SkillScroll
@onready var skill_list : VBoxContainer = $SkillSelection/SkillScroll/SkillList
@onready var confirm_container = $SkillSelection/ConfirmHBox
@onready var confirm_button : Button = $SkillSelection/ConfirmHBox/ConfirmButton
@onready var back_button : Button = $SkillSelection/ConfirmHBox/BackButton

@onready var orientation_cont = $OrientationSelection

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
		if button.visible:
			disconnect_all_signals_name(button, "pressed")
			button.visible = false



func set_skill_list(skills : Array, skill_func : Callable):
	var button_pointers = []
	var btn_count_changed = false
	
	var button_nodes = skill_list.get_children()
	var button_count = button_nodes.size()
	var skill_count = skills.size()
	
	while button_count < skill_count:
		skill_list.add_child(Button.new())
		button_count += 1
		btn_count_changed = true
		
	if btn_count_changed:
		button_nodes = skill_list.get_children()
		btn_count_changed = false
	
	for i in range(skills.size()):
		var skill_button = button_nodes[i]
		skill_button.visible = true
		skill_button.text = skills[i]._name
		skill_button.connect("pressed", skill_func.bind(skills[i]))
