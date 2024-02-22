class_name Skill
extends Resource

@export var _name : String = "None"
@export var _description : String = "No description."


@export var _skill_type : Utils.SkillType
@export var _weapon_type : Utils.WeaponType
@export var _modifiers : Array[AttrMod]
@export var _statuses : Array[StatusAilment]

# MP cost of the skill.
@export var _jewel_cost : int = 0

# AC Cast Time
@export var _cast_speed : int = 0

# Power scaling in terms of percentage.
@export var _power_scaling : float = 1.0
# Range for the xz-axis
@export var _range : int = 1
# Range for the y-axis
@export var _height_range : int = 1

# Area
@export var _area_length : int = 1
@export var _area_type : Utils.AreaType = Utils.AreaType.SQUARE

# Ignore defense
@export var _piercing : bool = false

# Overall skill damage multiplier
@export var _skill_effect : float = 0

# x_component = attribute type, y_component = scale factor
@export var _attribute_use : Array[Scaling]


func has_cast():
	return _cast_speed != 0

func obtain_cast_dict(aoe : Array):
	return {"cast_time": 0, "aoe": aoe}

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
