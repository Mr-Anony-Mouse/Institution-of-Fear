extends AnimationPlayer

signal SkillDone

func skilldone():
	SkillDone.emit()
