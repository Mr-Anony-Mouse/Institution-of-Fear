extends Node2D

@export var out_position :Vector2 = Vector2(0.0, -100.0)
@export var in_position :Vector2 = Vector2(0.0, 30.0)

func _unhandled_input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("interact")):
		var bodies = $outposition/Area2D.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Player"):
				$AnimatedSprite2D.play("default")
				await $AnimatedSprite2D.animation_finished
				body.global_position = $inposition.global_position
				$AnimatedSprite2D.play_backwards("default")
		bodies = $inposition/Area2D.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Player"):
				$AnimatedSprite2D.play("default")
				await $AnimatedSprite2D.animation_finished
				body.global_position = $outposition.global_position
				$AnimatedSprite2D.play_backwards("default")
	

func _ready() -> void:
	$outposition.position = out_position
	$inposition.position = in_position
	
