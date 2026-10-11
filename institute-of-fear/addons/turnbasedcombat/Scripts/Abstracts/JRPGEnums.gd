class_name JRPGEnums

enum DamageType{
	Damage,
	NegativeStat,
	PositiveStat,
	Health,
}

enum AttackType{
	Physical,
	Magi
}

enum StatusEffects{
	Buff,
	Debuff,
	## Damage over time
	DOT,
	## Heal over time
	HOT,  
	Custom
}

enum Target{
	##Target a single Enemy
	Enemy, 
	##Target all Enemies
	All_Enemies,
	##Target single Ally
	Ally,
	##Target all Allies
	All_Allies,
	##Target Self
	Self
}

enum Elements{
	Fire,
	Ice,
	Earth,
	Poison,
	Physical,
	Magik
}

enum StatTarget{
	Health,
	Magi,
	Hit_Chance,
	Defense,
	Speed,
	Strength
}

enum  Team{
	Player,
	Enemy
}

enum EffectType{
	Modify,
	Tickperturn
}

enum CalcType{
	Flat,
	Percentage
}

enum  CostType{
	Health,
	Magi,
}

enum EffectDuration{
	## Adds duration of effects together
	Add,
	## Sets duration to the amount set in the effect
	Refresh,
	## Doesnt apply effect
	Ignore,
}

enum HighlightState {
	NONE,
	SELECTABLE_PLAYER,
	TARGET_ENEMY,
	TARGET_ALLY,
}
