extends JRPGAIStrategy
class_name JRPGOpportunistStrategy

## The health threshold under which an enemy is considered "executable" (e.g., 25% HP)
@export_range(0.0, 1.0) var ExecuteThreshold := 0.25
## Bonus scoring multiplier applied when a skill can successfully kill or execute a target.
@export var KillShotWeight := 2.5
## Value placed on spreading status ailments to clean targets.
@export var StatusInflictWeight := 40.0

func evaluate_skill(Skill: JRPGBaseSkill, Self: JRPGBaseBattleChar, Context: JRPGContext) -> JRPGStrategyResult:
	if Skill.is_healing:
		return JRPGStrategyResult.new(Skill, null, 0)
		
	if Context.Enemies.is_empty():
		push_error("Enemy list should not be empty in context")
		return JRPGStrategyResult.new(Skill, null, 0)
		

	if CostCalucation(Skill,Self) == -1:
		return JRPGStrategyResult.new(Skill, null, 0)

	# ---  SINGLE TARGET LOGIC ---
	if Skill.Target == JRPGEnums.Target.Enemy:
		var BestTarget: JRPGBaseBattleChar = Context.Enemies[0] 
		var HighestTargetValue: float = -1.0
		
		for Enemy in Context.Enemies:
			var CurrentValue: float = 0.0
			var EnemyHPPercentage := float(Enemy.Char.current_hp) / float(Enemy.Char.max_hp)
			
			if Skill.BaseDamage > 0:
				if EnemyHPPercentage <= ExecuteThreshold:
					CurrentValue += (1.0 - EnemyHPPercentage) * 30.0
				
				if Skill.BaseDamage >= Enemy.Char.current_hp:
					CurrentValue += Skill.BaseDamage * KillShotWeight
			
			if Skill.Effect != null:
				if not Enemy.HasEffect(Skill.Effect): 
					CurrentValue += StatusInflictWeight * (float(Skill.HitChance) / 100.0)
				else:
					CurrentValue -= 20.0
					
			if CurrentValue > HighestTargetValue:
				HighestTargetValue = CurrentValue
				BestTarget = Enemy
				
		var Score = (float(Skill.BaseDamage) * 1.0) + HighestTargetValue
		Score = maxf(0.0, Score - CostCalucation(Skill,Self))
		
		return JRPGStrategyResult.new(Skill, BestTarget, Score)
		
	elif Skill.Target == JRPGEnums.Target.All_Enemies:
		var AoEValue: float = float(Skill.BaseDamage) * Context.Enemies.size()
		
		if Skill.Effect != null:
			var CleanTargets := 0
			for Enemy in Context.Enemies:
				if not Enemy.HasEffect(Skill.Effect):
					CleanTargets += 1
			
			AoEValue += (CleanTargets * StatusInflictWeight)
			
		var Score = AoEValue * 1.1
		Score = maxf(0.0, Score - CostCalucation(Skill,Self))
		
		return JRPGStrategyResult.new(Skill, Context.Enemies[0], Score)

	return JRPGStrategyResult.new(Skill, null, 0)
