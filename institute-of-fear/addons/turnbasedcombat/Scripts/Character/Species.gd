extends Resource
class_name JRPGSpecies

@export var Name : String
@export var Max_Base_HP : int
@export var Max_Base_Magi : int
@export var HP_Growth : int
@export var Magi_Growth : int
@export var Magi_Regen: int
@export var Weakness : JRPGEnums.Elements
@export var Strength : JRPGEnums.Elements
@export var Base_Skills : Array[JRPGBaseSkill] # Skills every instance starts with
@export var Learnable_Skills : Array[JRPGBaseSkill] # Skills the instance can learn
