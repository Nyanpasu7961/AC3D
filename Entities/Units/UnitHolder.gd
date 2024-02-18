class_name UnitHolder
extends Node3D

# Used as an API to obtain unit skills and attributes
# Responsible for holding which units are active or not and are in battle.

var ui_control : UIComponent = null
var combat_serve : CombatService = null
var nav_serve : NavService

var camera_body : CameraBody
var battle_map : BattleMap

var units = []
var active_unit : Unit

var selected_area : Vector3i

func initialise_units(control : UIComponent, bm : BattleMap, cam : CameraBody, ns : NavService):
	ui_control = control
	battle_map = bm
	camera_body = cam
	nav_serve = ns
	
	# load unit information here
	# load_units(path)
	
	ui_control.get_act("MSkills").connect("pressed", func(): unit_skills())
	ui_control.get_act("SSkills").connect("pressed", func(): unit_skills(false))
	ui_control.get_act("EndTurn").connect("pressed",Callable(self,"unit_end_turn"))
	ui_control.get_act("Attack").connect("pressed",Callable(self,"unit_basic_attack"))
	
	ui_control.back_button.connect("pressed", Callable(self, "back_to_skill_select"))
	
	# Change when loading units from file
	for child in get_children():
		if child is Unit:
			child._initialise_unit_mvmt(bm, cam)

func unit_skills(is_main_skills : bool = true):
	ui_control.clear_skill_list()
	var attributes = active_unit.attr_comp
	var skills = attributes._main_job.main_skills if is_main_skills else attributes._sub_job.sub_skills
	var buttons = ui_control.set_skill_list(skills)
	for h in buttons:
		h.button.connect("pressed", func(): skill_select_area(h.skill))
	
	back_to_skill_select()

# ss: active unit is movable, ssc: skill_container, cc: confirm buttons
func toggle_visibility(ss : bool, ssc : bool, cc : bool):
	active_unit.skill_select = ss
	ui_control.skill_selection_cont.visible = ssc
	ui_control.confirm_container.visible = cc

func back_to_skill_select():
	# Enable unit movement.
	toggle_visibility(false, true, false)
	ui_control.disconnect_all_signals_name(ui_control.confirm_button, "pressed")

func skill_select_area(skill : Skill):
	# Set select default to unit position.
	selected_area = active_unit.unit_cell
	
	toggle_visibility(true, true, true)
	
	var confirm_button = ui_control.confirm_button
	ui_control.disconnect_all_signals_name(confirm_button, "pressed")
	confirm_button.connect("pressed", func(): select_area_check(skill))
	
	var test_cells = nav_serve.grab_skill_area(active_unit, skill)
	battle_map.map_set_skill(test_cells)

func _input(event : InputEvent):
	if not active_unit is Unit: return
	
	# Only used when selecting tiles for a skill.
	if active_unit.skill_select and event.is_action_pressed("select_tile"):
		if ui_control.is_hovered(): return
		selected_area = camera_body.get_mouse_position()
		print(selected_area)

func select_area_check(skill : Skill):
	# Check if area selected is overlapped by an obstruction
	# if nav_cells.obstructed(selected_area): skill_select_area(skill)
	# If not, create a cast time window or deal damage to unit or blank.
	toggle_visibility(false, false, false)
	print(active_unit.skill_select, selected_area)
	return
	
func unit_end_turn():
	print(3)
	return

# Basic attacks are treated as skills.
func unit_basic_attack():
	print(4)
	return