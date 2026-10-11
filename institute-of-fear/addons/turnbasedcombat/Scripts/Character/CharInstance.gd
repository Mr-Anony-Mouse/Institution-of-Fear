extends RefCounted
class_name JRPGCharInstance

var species: JRPGSpecies

var level := 1
var ExPoints := 0

var max_hp: int
var max_magi: int
var current_hp: int
var current_magi: int

var unlocked_skills : Array[JRPGBaseSkill]
var equipped_skills : Array[JRPGBaseSkill]

func _init(_species: JRPGSpecies, _level := 1):
	species = _species
	level = _level
	recalc_stats()
	current_hp = max_hp
	current_magi = max_magi
	unlocked_skills = species.Base_Skills.duplicate()
	equipped_skills = species.Base_Skills.duplicate()

func recalc_stats():
	max_hp = species.Max_Base_HP + species.HP_Growth * (level - 1)
	max_magi = species.Max_Base_Magi + species.Magi_Growth * (level - 1)

func IsAlive()-> bool:
	return current_hp > 0
