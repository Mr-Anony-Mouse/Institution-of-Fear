extends Node2D

@export var player:JRPGSpecies
@export var sc:JRPGSpecies

func _ready() -> void:
	$JRPGCombat.PlayerTeam = [JRPGCharInstance.new(player)] as Array[JRPGCharInstance]
	$JRPGCombat.EnemyTeam = [JRPGCharInstance.new(sc)] as Array[JRPGCharInstance]
	
	$JRPGCombat.start()
