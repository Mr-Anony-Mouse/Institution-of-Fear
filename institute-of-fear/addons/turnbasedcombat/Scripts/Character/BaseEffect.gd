extends Resource
class_name JRPGBaseEffect

@export_group("Identity")
@export var Name : String
## The visual of the effect. Played at the position of the affected char. 
## Examples: fire particles for burning, blood for bleeding.
@export var EffectVis : PackedScene

@export_group("Application")
## Chance (0 to 100) that the effect successfully applies to the target.
@export_range(0, 100) var HitChance : int = 100
## Amount of turns the effect stays active.
@export var Duration : int = 3
## Dictates what happens when a effect that is already effecting a target gets cast on the target again
@export var DurationType: JRPGEnums.EffectDuration
## Dictates if the effect gets triggerd at the start or end of a characters turn
@export var isStartOfTurn: bool = true

@export_group("Mechanics")
## Does this modify a stat for the duration, or tick damage/healing every turn?
@export var EffectType : JRPGEnums.EffectType = JRPGEnums.EffectType.Tickperturn
## Which stat gets affected (e.g., HP, MP, ATK, DEF)
@export var statTarget : JRPGEnums.StatTarget = JRPGEnums.StatTarget.Health
## Is the amount a flat value (+10) or a percentage (+10%)?
@export var CalculationType : JRPGEnums.CalcType = JRPGEnums.CalcType.Flat
## How much the stat is affected. (Positive for buffs/healing, negative for debuffs/damage)
@export var Amount : int = 1

func Attach(Caster: JRPGBaseBattleChar, Target: JRPGBaseBattleChar):
	if !EffectVis:
		push_warning("Error: No effect visual specified for: " + Name)
	
	randomize()

	if HitChance < 100:
		if !randi_range(0, 99) < HitChance:
			return
	
	if Target.StatusEffects.has(self):
		match DurationType:
			JRPGEnums.EffectDuration.Add:
				Target.StatusEffects[self] = Target.StatusEffects[self] + Duration 
			JRPGEnums.EffectDuration.Refresh:
				Target.StatusEffects[self] = Duration
	else:
		Target.StatusEffects[self] = Duration

func Apply(Target: JRPGBaseBattleChar):
	print("Apply effect to " + Target.Char.species.Name)
	JRPGSignalBus.instance.ResultToUI.emit(Target.Char.species.Name + " is affected by " + Name)
	
	if EffectVis != null:
		var effectvisinstance = EffectVis.instantiate()
		Target.add_child(effectvisinstance)
		effectvisinstance.Visualize()
		
	if EffectType == JRPGEnums.EffectType.Modify:
		return
	
	match statTarget:
		JRPGEnums.StatTarget.Health:
			if Amount < 0:
				Target.TakeDamage(Amount, self)
			elif Amount > 0:
				Target.Heal(Amount, self)
		JRPGEnums.StatTarget.Magi:
			if Amount < 0:
				Target.DrainMagi(Amount, self)
			elif Amount > 0:
				Target.FillMagi(Amount, self)
		JRPGEnums.StatTarget.Hit_Chance:
			push_error("Not implemented yet!")
		JRPGEnums.StatTarget.Defense:
			push_error("Not implemented yet!")
		JRPGEnums.StatTarget.Speed:
			push_error("Not implemented yet!")
		JRPGEnums.StatTarget.Strength:
			push_error("Not implemented yet!")

func Remove(Target: JRPGBaseBattleChar):
	if EffectType != JRPGEnums.EffectType.Modify:
		return;
	
	match statTarget:
		JRPGEnums.StatTarget.Health:
			push_error("Not implemented yet!")
		JRPGEnums.StatTarget.Magi:
			push_error("Not implemented yet!")
		JRPGEnums.StatTarget.Hit_Chance:
			Target.HitChance = Target.HitChance - Amount
		JRPGEnums.StatTarget.Defense:
			Target.Defense = Target.Defense - Amount
		JRPGEnums.StatTarget.Speed:
			Target.Speed = Target.Speed - Amount
		JRPGEnums.StatTarget.Strength:
			Target.Strength = Target.Strength - Amount
