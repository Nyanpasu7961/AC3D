class_name Skill

var skill_type : Utils.SkillType
var weapon_type : Utils.WeaponType
var modifiers : Array[AttrMod]
var statuses : Array[StatusAilment]

# MP cost of the skill.
var jewel_cost : int

# Power scaling in terms of percentage.
var power_scaling : float
# Range for the xz-axis
var range : int
# Range for the y-axis
var h_range : int

# Ignore defense
var piercing : bool = false

# TODO: Still need to finish for damaging skill types
func apply_skill(target : Unit):
	target.apply_modifiers(modifiers)
	target.apply_statuses(statuses)
	
	if skill_type == Utils.SkillType.STATUS:
		return 0
	
	return target.skill_damage(power_scaling)
