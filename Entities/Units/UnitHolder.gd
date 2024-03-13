class_name UnitHolder
extends Node3D

## Used as an API to obtain unit skills and attributes.
## The middleman between the UI control and unit characters.
## Responsible for holding which units are active or not and are in battle.
## All entities (incl. enemies) with attribute components are called Units.

var ui_control : UIComponent = null
var combat_serve : CombatService = null
var nav_serve : NavService

var camera_body : CameraBody
var battle_map : BattleMap

var active_unit : Unit

# Keeps track of selected skills and squares.
# Kept as global to reduce calls to flood cell in NavServe.
var _current_selected_skill : Skill
var _selected_cell : Vector3i
var _skill_avail_area : Array
var _skill_aoe  : Array

var cell_size

func _input(event : InputEvent):
	if not active_unit is Unit: return
	# Only used when selecting tiles for a skill.
	if active_unit.skill_select and event.is_action_pressed("select_tile"):
		if ui_control.is_hovered(): return
		_selected_cell = battle_map.l_transform_m(camera_body.get_mouse_position())
		_highlight_the_area()

func _initialise(control : UIComponent, bm : BattleMap, cam : CameraBody, ns : NavService, cs : CombatService):
	ui_control = control
	battle_map = bm
	camera_body = cam
	nav_serve = ns
	combat_serve = cs
	
	cell_size = bm.cell_size
	
	# Setup UI buttons to interact with unit attributes and skills.
	ui_control.get_act("MSkills").connect("pressed", Callable(self,"_main_unit_skills"))
	ui_control.get_act("SSkills").connect("pressed", Callable(self,"_sub_unit_skills"))
	ui_control.get_act("EndTurn").connect("pressed",Callable(self,"_unit_end_turn"))
	ui_control.get_act("Attack").connect("pressed",Callable(self,"_unit_basic_attack"))
	ui_control.back_button.connect("pressed", Callable(self, "_back_to_skill_select"))
	
	# Load units into the combat service.
	var units = get_children().filter(func(x): return x is Unit)
	for us in units:
		us._initialise_unit_mvmt(bm, cam, control, ns)
	combat_serve.add_units(units)

func _prepare_ui_skills(skills : Array):
	ui_control.skill_scroll.visible = true
	ui_control.skill_selection_cont.visible = true
	ui_control.clear_skill_list()
	ui_control.set_skill_list(skills, _skill_select_area)
	_back_to_skill_select()

func _main_unit_skills():
	_prepare_ui_skills(active_unit._obtain_main_skills())
	
func _sub_unit_skills():
	_prepare_ui_skills(active_unit._obtain_sub_skills())

func _unhighlight_skill():
	battle_map.map_set_skill([])
	battle_map.place_cast_highlighter([])

func _back_to_skill_select():
	# Enable unit movement.
	_unhighlight_skill()
	active_unit.skill_select = false
	ui_control.confirm_container.visible = false
	
	ui_control.disconnect_all_signals_name(ui_control.confirm_button, "pressed")

func _skill_select_area(skill : Skill):
	active_unit.skill_select = true
	ui_control.confirm_container.visible = true
	
	_current_selected_skill = skill
	# Set selection default to unit position.
	_selected_cell = active_unit.unit_cell
	_highlight_the_area()
	
	var confirm_button = ui_control.confirm_button
	ui_control.disconnect_all_signals_name(confirm_button, "pressed")
	confirm_button.connect("pressed", _select_area_check.bind(skill))
	
	_skill_avail_area = nav_serve.grab_skill_area(active_unit, skill)
	battle_map.map_set_skill(_skill_avail_area)

func _highlight_the_area():
	# Need to change from flood fill to something simpler.
	# Meh, its probably fast enough though.
	_skill_aoe  = nav_serve.grab_skill_aoe (_selected_cell, _current_selected_skill)
	battle_map.place_cast_highlighter(_skill_aoe )

func _skill_area_has_entity(area : Array) -> Array:
	return combat_serve._units_in_area(area)

func _select_area_check(skill : Skill):
	if not _selected_cell in _skill_avail_area: print("Invalid skill select position."); return
	
	if not skill.has_cast():
		# Check if area selected is overlapped by an obstruction
		# if nav_cells.obstructed(_selected_cell): skill_select_area(skill)
		# If not, create a cast time window or deal damage to unit or blank.
		var units_in_area = _skill_area_has_entity(_skill_aoe)
		if units_in_area.is_empty(): print("Invalid skill select position."); return
		
		for unit in units_in_area:
			unit.deal_damage(200)
	
	else:
		# Record the skill to be cast on aoe positions.
		var skill_to_cast = skill._obtain_cast_dict(active_unit, _skill_aoe)
		combat_serve.skill_on_cast.append(skill_to_cast)
		battle_map.add_skill_to_cast(skill_to_cast, _skill_aoe)
	
	_skill_select_inactive()
	_unit_end_turn()
	return

func _skill_select_inactive():
	active_unit.skill_select = false
	ui_control.skill_selection_cont.visible = false
	ui_control.confirm_container.visible = false
	_unhighlight_skill()

func _change_active(unit : Unit):
	unit.is_active = true
	active_unit = unit
	print(active_unit.name)
	camera_body.target = active_unit

func _end_active():
	active_unit._end_turn()
	active_unit = null

func _unit_end_turn():
	_skill_select_inactive()
	_end_active()
	combat_serve.turn_end()
	nav_serve.turn_changed = true
	return

func _select_orientation():
	
	pass

# Basic attacks are treated as skills.
func _unit_basic_attack():
	ui_control.skill_selection_cont.visible = true
	ui_control.skill_scroll.visible = false
	var battack = active_unit._obtain_basic_attack()
	_skill_select_area(battack)
