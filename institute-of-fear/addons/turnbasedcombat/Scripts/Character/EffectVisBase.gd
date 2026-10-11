extends Node2D
class_name JRPGEffectVisBase

func Visualize():
	$AnimationPlayer.play("Visualize")
	
	await $AnimationPlayer.animation_finished
	queue_free()
