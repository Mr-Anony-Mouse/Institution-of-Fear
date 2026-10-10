extends Area2D

@export var damage: int = 25
var is_attacking: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var swing_sound: AudioStreamPlayer2D = $SwingSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var equip_sound: AudioStreamPlayer2D = $EquipSound
var test


func _ready() -> void:
	attack_collision.set_deferred("disabled", true)

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	#animated_sprite.flip_v = get_global_mouse_position().x < global_position.x
		
	if Input.is_action_pressed("attack") and attack_timer.is_stopped():
		attack()

func attack() -> void:
	is_attacking = true
	attack_collision.set_deferred("disabled", false)
	attack_timer.start()
	animated_sprite.play("Swing")
	
	print("whoosh")
	swing_sound.pitch_scale = randf_range(0.8, 1.2)
	swing_sound.play()
	
	await get_tree().create_timer(0.3).timeout
	
	is_attacking = false
	attack_collision.set_deferred("disabled", true)
	animated_sprite.play("Idle")

func _on_attack_area_area_entered(area: Area2D) -> void:
	if is_attacking and area.has_method("take_damage"):
		area.take_damage(damage)
		print("hit something!")
		hit_sound.play()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_attacking:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("hit enemy!")
			hit_sound.play()
		else:
			print("wall")
			hit_sound.play()
