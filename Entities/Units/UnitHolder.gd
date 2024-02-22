class_name UnitHolder
extends Node3D

# Used as an API to obtain unit skills and attributes
# Responsible for holding which units are active or not and are in battle.
# All entities (incl. enemies) with attribute components are called Units.

var ui_control : UIComponent = null
var combat_serve : CombatService = null
var nav_serve : NavService
var casth : CastHighlight

var camera_body : CameraBody
var battle_map : BattleMap

var units = []
var active_unit : Unit

var current_selected_skill : Skill
var selected_area : Vector3i
var skill_avail_area : Array
var skill_aoe : Array


var cell_size

func initialise_units(control : UIComponent, bm : BattleMap, cam : CameraBody, ns : NavService, cth : CastHighlight):
	ui_control = control
	battle_map = bm
	camera_body = cam
	nav_serve = ns
	casth = cth
	
	cell_size = bm.cell_size
	
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
			child._initialise_unit_mvmt(bm, cam, control, ns)
			units.append(child)

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

func unhighlight_skill():
	battle_map.map_set_skill([])
	casth.clear_highlighters()

func back_to_skill_select():
	# Enable unit movement.
	unhighlight_skill()
	toggle_visibility(false, true, false)
	ui_control.disconnect_all_signals_name(ui_control.confirm_button, "pressed")

func skill_select_area(skill : Skill):
	current_selected_skill = skill
	# Set select default to unit position.
	selected_area = active_unit.unit_cell
	highlight_the_area()
	
	toggle_visibility(true, true, true)
	
	var confirm_button = ui_control.confirm_button
	ui_control.disconnect_all_signals_name(confirm_button, "pressed")
	confirm_button.connect("pressed", func(): select_area_check(skill))
	
	skill_avail_area = nav_serve.grab_skill_area(active_unit, skill)
	battle_map.map_set_skill(skill_avail_area)

func _input(event : InputEvent):
	if not active_unit is Unit: return
	
	# Only used when selecting tiles for a skill.
	if active_unit.skill_select and event.is_action_pressed("select_tile"):
		if ui_control.is_hovered(): return
		selected_area = battle_map.l_transform_m(camera_body.get_mouse_position())
		highlight_the_area()

func highlight_the_area():
	# Need to change from flood fill to something simpler.
	skill_aoe = nav_serve.grab_skill_aoe(selected_area, current_selected_skill)
	# Translate relative to highlight position
	var highlighted_area = skill_aoe.map(func(x): return x - selected_area)
	
	casth.global_position = selected_area
	# Center multimesh to grid.
	casth.global_position += Vector3(cell_size.x/2, 0, cell_size.z/2)
	casth.set_cell_highlighters(highlighted_area)
	

func skill_area_has_entity() -> Array:
	return units.filter(func(unit): return unit.unit_cell in skill_aoe)

func select_area_check(skill : Skill):
	if not selected_area in skill_avail_area: print("Invalid skill select position."); return
	
	if not skill.has_cast():
		var units_in_area = skill_area_has_entity()
		if units_in_area.is_empty(): print("Invalid skill select position."); return
		
		for unit in units_in_area:
			unit.deal_damage(200)
	
	else:
		# Record the skill to be cast on aoe positions.
		combat_serve.skill_on_cast[skill._name] = skill.obtain_cast_dict(skill_aoe)
	
	# Check if area selected is overlapped by an obstruction
	# if nav_cells.obstructed(selected_area): skill_select_area(skill)
	# If not, create a cast time window or deal damage to unit or blank.
	toggle_visibility(false, false, false)
	unhighlight_skill()
	return
	
func unit_end_turn():
	print(3)
	return

# Basic attacks are treated as skills.
func unit_basic_attack():
	print(4)
	return
