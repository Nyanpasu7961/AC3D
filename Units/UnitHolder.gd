extends Node3D

var ui_control : UIComponent = null
var combat_serve : CombatService = null

func initialise_units(control : UIComponent):
	ui_control = control
	
	# load unit information here
	
	ui_control.get_act("MSkills").connect("pressed",Callable(self,"player_wants_to_move"))
	ui_control.get_act("SSkills").connect("pressed",Callable(self,"player_wants_to_wait"))
	ui_control.get_act("EndTurn").connect("pressed",Callable(self,"player_wants_to_cancel"))
	ui_control.get_act("Attack").connect("pressed",Callable(self,"player_wants_to_attack"))
