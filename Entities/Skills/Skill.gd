class_name Skill
extends Resource

@export var name : String = "None"
@export var description : String = "No description."


@export var skill_type : Utils.SkillType
@export var weapon_type : Utils.WeaponType
@export var modifiers : Array[AttrMod]
@export var statuses : Array[StatusAilment]

# MP cost of the skill.
@export var jewel_cost : int = 0

# AC Cast Time
@export var cast_time : int = 0

# Power scaling in terms of percentage.
@export var power_scaling : float = 1.0
# Range for the xz-axis
@export var range : int = 1
# Range for the y-axis
@export var height_range : int = 1

# Area
@export var area_length : int = 1
@export var area_type : Utils.AreaType = Utils.AreaType.SQUARE

# Ignore defense
@export var piercing : bool = false

# x_component = attribute type, y_component = scale factor
@export var attribute_use : Array[Scaling]

# TODO: Still need to finish for damaging skill types
#func apply_skill(target : Unit):
#	target.apply_modifiers(modifiers)
#	target.apply_statuses(statuses)
#	
#	if skill_type == Utils.SkillType.STATUS:
#		return 0
	
	# Function for damage for the skill.
#	var damage_function = func(entity_attr : Dictionary):
#		var collated_scale = 0
#		for attr in attribute_use:
#			collated_scale += entity_attr[attr.x]*attr.y
#		return power_scaling*collated_scale
#	
#	return target.skill_damage(damage_function)
