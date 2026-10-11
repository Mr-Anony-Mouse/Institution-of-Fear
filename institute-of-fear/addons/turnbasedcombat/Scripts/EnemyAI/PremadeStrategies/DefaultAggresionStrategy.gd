extends JRPGAIStrategy
class_name JRPGDefaultAggressionStrategy

@export_range(0.0, 1.0)  var GroupAttackThreshold:= 0.1

func evaluate_skill(Skill: JRPGBaseSkill, Self: JRPGBaseBattleChar, Context: JRPGContext) -> JRPGStrategyResult:
	if Skill.DamageType != JRPGEnums.DamageType.Damage:
		return JRPGStrategyResult.new(Skill, null, 0)
		
	if Context.Enemies.is_empty():
		push_error("Enemy list should not be empty in context")
		return JRPGStrategyResult.new(Skill, null, 0)
		
	if CostCalucation(Skill,Self) == -1:
		return JRPGStrategyResult.new(Skill, null, 0)
	
	# --- SINGLE TARGET ENEMY ---
	if Skill.Target == JRPGEnums.Target.Enemy:
		var Target = Context.Enemies[0] 
		for Enemy in Context.Enemies:
			if Enemy.Char.current_hp < Target.Char.current_hp:
				Target = Enemy
			
		var Score = float(Skill.BaseDamage) * 1.5 
		Score = maxf(0.0, Score - CostCalucation(Skill,Self))
		
		return JRPGStrategyResult.new(Skill, Target, Score)
		
	# --- ALL ENEMIES ---
	elif Skill.Target == JRPGEnums.Target.All_Enemies:
		var TotalEnemies := Context.Enemies.size()
		
		var RawValue = float(Skill.BaseDamage) * TotalEnemies
		
		var Score = RawValue * (1.0 + GroupAttackThreshold)
		Score = maxf(0.0, Score - CostCalucation(Skill,Self))
		
		return JRPGStrategyResult.new(Skill, Context.Enemies[0], Score)
		
	return JRPGStrategyResult.new(Skill, null, 0)
