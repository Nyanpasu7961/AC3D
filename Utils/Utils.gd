class_name Utils

enum AttributeTypes {MAXHP, MAXJ, PATK, PDEF, MATK, MDEF, DEX, AGI, MOVE, JUMP}
enum ValueTypes {FLAT, PERCENTADD, PERCENTMULTIPLY}
enum DurationType {NONE, TURN, CLOCKTIME}

enum SkillType {PHYSICAL, MAGIC, STATUS}
enum WeaponType {SLASH, MISSILE, STRIKE}

static func create_material(color, texture=null, shaded_mode=0):
	var material = StandardMaterial3D.new()
	material.flags_transparent = true
	material.albedo_color = Color(color)
	material.albedo_texture = texture
	material.shading_mode = shaded_mode
	return material

