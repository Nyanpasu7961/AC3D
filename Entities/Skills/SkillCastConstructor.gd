class_name SkillCastConstructor

var _id_count : int = 0

static var _instance : SkillCastConstructor = null

static func get_instance():
	if _instance == null:
		_instance = SkillCastConstructor.new()
	return _instance

func create_skillcast(skill : Skill, aoe : Array):
	var res = SkillCast.new(skill, aoe)
	res._id = _id_count
	_id_count += 1
	return res
