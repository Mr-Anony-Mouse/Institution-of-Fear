extends Resource
class_name JRPGBaseSkill

@export_group("UI & Identity")
@export var Name: String
@export_multiline var Description: String
@export var Icon: Texture2D
## Name of the animation in the AnimationPlayer instance of BaseBattle.
@export var AnimationName: String

@export_group("Targeting & Costs")
## Defines who can be targeted by this skill (e.g., Single Enemy, All Allies, Self).
@export var Target: JRPGEnums.Target
## What resource type this skill consumes.
@export var CostType: JRPGEnums.CostType = JRPGEnums.CostType.Magi
## How much of the CostType resource is consumed. 0 = no cost.
@export var Cost: int = 0

@export_group("Accuracy & Attributes")
## Chance (0 to 100) that the skill will successfully hit the target. (Usually 100 for healing/buffs).
@export_range(0, 100) var HitChance: int = 100
## Is this skill meant to deal damage or heal?
@export var DamageType: JRPGEnums.DamageType
## Elemental attribute of the attack (used to calculate target strengths and weaknesses).
@export var Element: JRPGEnums.Elements

@export_group("Mechanics & Math")
## Base power of the skill before stat calculations are applied.
@export var BaseDamage: int
## How many times this skill strikes the target(s) per use.[br]
## [color=red][b]NOT YET IMPLEMENTED[/b][/color]
@export var HitCount: int = 1

@export_group("Status Effects")
## An optional status effect that can linger on the target over multiple turns after the skill hits.
@export var Effect: JRPGBaseEffect

func Activate(Caster: JRPGBaseBattleChar, Targets: Array[JRPGBaseBattleChar]):
	randomize()
	
	if !Caster:
		push_error("Error: No caster specified")
		return
	if !Caster.Animator:
		push_error("Error: Caster has no AnimationPlayer specified")
		return
	if AnimationName.strip_edges() == "":
		push_error("Error: No skill animation specified")
		return
	if !Caster.Animator.has_animation(AnimationName):
		push_error("Error: Casters AnimationPlayer does not have animation: " + AnimationName)
		return
	JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.NONE);
	Caster.Animator.play(AnimationName)
	
	await Caster.Animator.SkillDone
	
	for target in Targets:
		if target == null:
			continue
		
		randomize()
		if HitChance < 100:
			if !randi_range(0, 99) < HitChance:
				JRPGSignalBus.instance.ResultToUI.emit(Name + " missed " + target.Char.species.Name)
				continue
		
		var FinalDamage := BaseDamage
		
		target.ApplySkill(FinalDamage, DamageType, Element, Caster)
		
		if Effect:
			Effect.Attach(Caster, target)
