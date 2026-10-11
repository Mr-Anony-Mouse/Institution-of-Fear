extends JRPGAIStrategy
class_name JRPGHealerStrategy

@export var HealThreshold := 0.5

func evaluate_skill(Skill: JRPGBaseSkill, Self: JRPGBaseBattleChar, Context: JRPGContext) -> JRPGStrategyResult:
	if Skill.DamageType != JRPGEnums.DamageType.Health:
		return JRPGStrategyResult.new(Skill, null, 0)
	
	if CostCalucation(Skill,Self) == -1:
		return JRPGStrategyResult.new(Skill, null, 0)
	
	if Skill.Target == JRPGEnums.Target.Ally:
		var LowestHealth: JRPGBaseBattleChar
		var LowestHPPercentage:= 1.0
		
		for Ally in Context.Allies:
			var HPPercentage := float(Ally.Char.current_hp) / float(Ally.Char.max_hp)
			
			if HPPercentage < LowestHPPercentage:
				LowestHPPercentage = HPPercentage
				LowestHealth = Ally
		if LowestHPPercentage <= HealThreshold:
			var Score = (1.0 - LowestHPPercentage) * 100.0
			Score = maxf(0.0, Score - CostCalucation(Skill,Self))
			
			return JRPGStrategyResult.new(Skill, LowestHealth, Score)
		
	elif Skill.Target == JRPGEnums.Target.All_Allies:
		var HPPercentage: float
		
		for Ally in Context.Allies:
			HPPercentage += float(Ally.Char.current_hp) / float(Ally.Char.max_hp)
		
		HPPercentage = HPPercentage / Context.Allies.size()
		
		if HPPercentage < HealThreshold:
			var Score = (1.0 - HPPercentage) * 100
			if Score < 70:
				Score + 20;
			Score = maxf(0.0, Score - CostCalucation(Skill,Self))
			
			return JRPGStrategyResult.new(Skill, Self, Score)
	
	elif Skill.Target == JRPGEnums.Target.Self:
		var HPPercentage: float = float(Self.Char.current_hp) / float(Self.Char.max_hp)
		
		if HPPercentage < HealThreshold:
			var Score = (1.0 - HPPercentage) * 100.0
			Score = maxf(0.0, Score - CostCalucation(Skill,Self))
			
			return JRPGStrategyResult.new(Skill, Self, Score)

	return JRPGStrategyResult.new(Skill, null, 0)
