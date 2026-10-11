extends RefCounted
class_name JRPGStrategyResult

var Skill: JRPGBaseSkill 
var Target: JRPGBaseBattleChar
var Score:float = 0

func _init(skill: JRPGBaseSkill, target: JRPGBaseBattleChar, score: float = 0) -> void:
	Skill = skill
	Target = target
	Score = score
