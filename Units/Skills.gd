class_name Skill

var skill_type : Utils.SkillType
var weapon_type : Utils.WeaponType
var modifiers : Array[AttrMod]
var statuses : Array[StatusAilment]

# MP cost of the skill.
var jewel_cost : int

# AC Cast Time
var cast_time : int

# Power scaling in terms of percentage.
var power_scaling : float
# Range for the xz-axis
var range : int
# Range for the y-axis
var h_range : int

# Area
var area_length : int
var area_type : Utils.AreaType

# Ignore defense
var piercing : bool = false

# x_component = attribute type, y_component = scale factor
var attribute_use : Array[Vector2]

# TODO: Still need to finish for damaging skill types
func apply_skill(target : Unit):
	target.apply_modifiers(modifiers)
	target.apply_statuses(statuses)
	
	if skill_type == Utils.SkillType.STATUS:
		return 0
	
	# Function for damage for the skill.
	var damage_function = func(entity_attr : Dictionary):
		var collated_scale = 0
		for attr in attribute_use:
			collated_scale += entity_attr[attr.x]*attr.y
		return power_scaling*collated_scale
	
	return target.skill_damage(damage_function)
