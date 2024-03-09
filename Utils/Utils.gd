extends Resource
class_name Utils

enum AttributeTypes {MAXHP, MAXJ, PATK, PDEF, MATK, MDEF, DEX, AGI, MOVE, JUMP}
enum ValueTypes {FLAT, PERCENTADD, PERCENTMULTIPLY}
enum DurationType {NONE, TURN, CLOCKTIME}

enum SkillType {PHYSICAL, MAGIC, STATUS}
enum WeaponType {SLASH, MISSILE, STRIKE}
enum AreaType {SQUARE, CROSS, XY_CROSS, DIAMOND, CHECKBOARD}

enum TeamType {ALLY, ENEMY, NONE}

enum Orientation {NORTH, EAST, SOUTH, WEST}

const DIRECTIONSi = [Vector3i.FORWARD, Vector3i.BACK, Vector3i.RIGHT, Vector3i.LEFT]
const DIAGONAL_DIRECTIONS = [Vector3i(1, 0, 1), Vector3i(1, 0, -1), Vector3i(-1, 0, 1), Vector3i(-1, 0, -1)]

static func _sort_by_prediction(a : CTAttributes, b : CTAttributes):
	if a._clock_cycles == b._clock_cycles:
		return a._pred_ready_ct >= b._pred_ready_ct
	return a._clock_cycles > b._clock_cycles

static func create_material(color, texture=null, shaded_mode=0):
	var material = StandardMaterial3D.new()
	material.flags_transparent = true
	material.albedo_color = Color(color)
	material.albedo_texture = texture
	material.shading_mode = shaded_mode
	return material

static func create_skill_button(skill : Skill):
	var button = Button.new()
	button.text = skill.name
	button.name = skill.name
	return button

static func erase_all_children(node : Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func is_cross(type : AreaType) -> bool:
	return type == AreaType.CROSS or type == AreaType.XY_CROSS

static func get_area_directions(type : AreaType):
	match type:
		AreaType.SQUARE:
			return DIRECTIONSi + DIAGONAL_DIRECTIONS
		AreaType.CROSS:
			return DIAGONAL_DIRECTIONS
		AreaType.XY_CROSS:
			return DIRECTIONSi
		AreaType.DIAMOND:
			return DIRECTIONSi
		AreaType.CHECKBOARD:
			return DIAGONAL_DIRECTIONS

static func get_vec_orientation(ori : Orientation):
	match ori:
		Orientation.NORTH:
			return Vector3i.FORWARD
		Orientation.SOUTH:
			return Vector3i.BACK
		Orientation.EAST:
			return Vector3i.RIGHT
		Orientation.WEST:
			return Vector3i.LEFT
