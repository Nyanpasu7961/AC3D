class_name UnitHolder
extends Node3D

# Used as an API to obtain unit skills and attributes
# Responsible for holding which units are active or not and are in battle.

var ui_control : UIComponent = null
var combat_serve : CombatService = null

var camera_body : CameraBody
var battle_map : BattleMap

var units = []
var active_unit : Unit

func initialise_units(control : UIComponent, bm : BattleMap, cam : CameraBody):
	ui_control = control
	battle_map = bm
	camera_body = cam
	
	# load unit information here
	# load_units(path)
	
	ui_control.get_act("MSkills").connect("pressed",Callable(self,"unit_main_skills"))
	ui_control.get_act("SSkills").connect("pressed",Callable(self,"unit_sub_skills"))
	ui_control.get_act("EndTurn").connect("pressed",Callable(self,"unit_end_turn"))
	ui_control.get_act("Attack").connect("pressed",Callable(self,"unit_basic_attack"))
	
	# Change when loading units from file
	for child in get_children():
		if child is Unit:
			child._initialise_unit_mvmt(bm, cam)

func unit_main_skills():
	return
	
func unit_sub_skills():
	return
	
func unit_end_turn():
	return
	
func unit_basic_attack():
	return
