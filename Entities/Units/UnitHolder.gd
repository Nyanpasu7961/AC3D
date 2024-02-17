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
	
	ui_control.get_act("MSkills").connect("pressed",Callable(self,"unit_main_skills"))
	ui_control.get_act("SSkills").connect("pressed",Callable(self,"unit_sub_skills"))
	ui_control.get_act("EndTurn").connect("pressed",Callable(self,"unit_end_turn"))
	ui_control.get_act("Attack").connect("pressed",Callable(self,"unit_basic_attack"))
	
	ui_control.back_button.connect("pressed", Callable(self, "back_to_skill_select"))
	
	# Change when loading units from file
	for child in get_children():
		if child is Unit:
			child._initialise_unit_mvmt(bm, cam)

func unit_main_skills():
	ui_control.clear_skill_list()
	var skills = active_unit.attr_comp._main_job.main_skills
	var buttons = ui_control.set_skill_list(skills)
	for h in buttons:
		h.button.connect("pressed", func(): skill_select_area(h.skill))

func unit_sub_skills():
	ui_control.clear_skill_list()
	var skills = active_unit.attr_comp._sub_job.sub_skills
	var buttons = ui_control.set_skill_list(skills)
	for h in buttons:
		h.button.connect("pressed", func(): skill_select_area(h.skill))

func back_to_skill_select():
	# Enable unit movement.
	active_unit.skill_select = false
	ui_control.disconnect_all_signals_name(ui_control.confirm_button, "pressed")
	ui_control.confirm_container.visible = false

func skill_select_area(skill : Skill):
	# Set select default to unit position.
	selected_area = active_unit.unit_cell
	
	active_unit.skill_select = true
	ui_control.confirm_container.visible = true
	
	var confirm_button = ui_control.set_confirm()
	ui_control.disconnect_all_signals_name(confirm_button, "pressed")
	
	var test_cells = nav_serve.grab_skill_area(active_unit, skill)
	battle_map.map_set_skill(test_cells)
	
	ui_control.set_confirm().connect("pressed", func(): select_area_check(skill))

func select_area_check(skill : Skill):
	# Check if area selected is overlapped by an obstruction
	# if nav_cells.obstructed(selected_area): skill_select_area(skill)
	# If not, create a cast time window or deal damage to unit or blank.
	return



	
func unit_end_turn():
	print(3)
	return
	
func unit_basic_attack():
	print(4)
	return
