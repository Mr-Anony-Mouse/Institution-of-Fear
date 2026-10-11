extends Node2D

@export var species:JRPGSpecies

func _ready() -> void:
	$Combat.PlayerTeam = [JRPGCharInstance.new(species), JRPGCharInstance.new(species), JRPGCharInstance.new(species)] as Array[JRPGCharInstance]
	$Combat.EnemyTeam = [JRPGCharInstance.new(species), JRPGCharInstance.new(species), JRPGCharInstance.new(species)] as Array[JRPGCharInstance]
	
	$Combat.start()
