extends Resource
class_name JRPGAIStrategy

func evaluate_skill(Skill: JRPGBaseSkill, Self: JRPGBaseBattleChar, Context: JRPGContext) -> JRPGStrategyResult:
	print("Base Strategy. Extend this one for your own AIStrategy")
	return JRPGStrategyResult.new(Skill, null)

func CostCalucation(Skill: JRPGBaseSkill, Self: JRPGBaseBattleChar) -> float:
	var CostPenalty: float = 0.0
	
	match Skill.CostType:
		JRPGEnums.CostType.Magi:
			if Skill.Cost > Self.Char.current_magi:
				return -1
			if Skill.Cost > 0 and Self.Char.max_magi > 0:
				CostPenalty = (float(Skill.Cost) / Self.Char.max_magi) * 15.0
				
		JRPGEnums.CostType.Health:
			if Skill.Cost > Self.Char.current_hp:
				return -1
			if Skill.Cost > 0 and Self.Char.max_hp > 0:
				CostPenalty = (float(Skill.Cost) / Self.Char.max_hp) * 15.0 * 2.5
				if (float(Self.Char.current_hp) / Self.Char.max_hp) < 0.35:
					CostPenalty *= 2.0
	
	return CostPenalty
