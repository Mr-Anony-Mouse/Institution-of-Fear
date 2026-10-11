extends Node
class_name JRPGAIController

## A list of evaluation strategies this specific enemy uses [br](e.g., [color=BD1A00]Aggressive[/color], [color=1FFF5C]Healer[/color], [color=5EB9D1]Self-Preservation[/color])
@export var strategies: Array[JRPGAIStrategy]
var SkillHistory: Dictionary[String,int]

func ChooseAction(ai_character: JRPGBaseBattleChar, combat_context: JRPGContext):
	
	for skill in SkillHistory:
		SkillHistory[skill] += 1
	
	var best_skill: JRPGBaseSkill = null
	var best_target: Array[JRPGBaseBattleChar] = []
	var highest_score: float = -1.0
	
	for skill in ai_character.Char.equipped_skills:
		for strategy in strategies:
			var evaluation = strategy.evaluate_skill(skill, ai_character, combat_context)
			
			if JRPGCombatManager.SpamPenalty:
				evaluation.Score = SpamPenalty(evaluation.Score, evaluation.Skill.Name)
			if JRPGCombatManager.RandomizeAttacks:
				evaluation.Score = RandomizeScore(evaluation.Score)
			
			if evaluation.Score > highest_score:
				highest_score = evaluation.Score
				best_skill = skill
				best_target = [evaluation.Target]
				
	if best_skill.Target == JRPGEnums.Target.All_Enemies:
		best_target = combat_context.Enemies
	elif best_skill.Target == JRPGEnums.Target.All_Allies:
		best_target = combat_context.Allies
	
	await best_skill.Activate(ai_character, best_target)
	SkillHistory[best_skill.Name] = 0
	JRPGSignalBus.instance.DidAction.emit()

func RandomizeScore(Score: int) -> int:
	randomize()
	
	var Fuzz = randf_range(-5,5)
	Score += Fuzz
	
	return Score
 
func SpamPenalty(Score: int, Skillname: String) -> int:
	var previous:= SkillHistory.get(Skillname, 1000)
	
	if previous == 1:
		Score = Score * 0.3
	elif previous < 3:
		Score = Score * 0.75
	
	return Score
