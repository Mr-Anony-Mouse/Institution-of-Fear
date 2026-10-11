@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Load your combat scene
	var combat_scene = preload("res://addons/turnbasedcombat/JRPGCombat.tscn")
	var combat_script = preload("res://addons/turnbasedcombat/Scripts/Combat.gd")
	
	# Register it as a custom node type. 
	# When a developer adds "TurnBasedSystem" to their scene tree, 
	# Godot will automatically instantiate your entire scene!
	add_custom_type(
		"TurnBasedSystem", 
		"Node2D", # Change to Control, Node3D, etc. depending on your root node type
		combat_script,     # Leave this null because you are passing a scene, not a blank script
		combat_scene
	)

func _exit_tree() -> void:
	# Clean up when the plugin is disabled
	remove_custom_type("TurnBasedSystem")
