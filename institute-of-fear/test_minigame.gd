extends Node

@onready var minigame = $LockpickGame

func _ready() -> void:
	minigame.finished.connect(_on_finished)
	minigame.start()  

func _on_finished(success: bool) -> void:
	print("Unlocked" if success else "Left or failed")
	
	#this is just the temp script and scene delete this when you wnat just added to test the loocpicking gape 
	#enjoyy
