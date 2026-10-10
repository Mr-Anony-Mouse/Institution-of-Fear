extends Area2D

@export_category("Projectile Stats")
@export var speed: float = 600.0
@export var damage: int = 25
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.ZERO
var is_destroyed: bool = false 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $LifeTime
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

func _ready() -> void:
	top_level = true
	
	life_timer.wait_time = lifetime
	life_timer.start()

func _physics_process(delta: float) -> void:
	if not is_destroyed:
		global_position += direction * speed * delta

func _on_life_time_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if is_destroyed: 
		return
		
	if area.has_method("take_damage"):
		area.take_damage(damage)
		
	destroy_projectile()

func _on_body_entered(body: Node2D) -> void:
	if is_destroyed: 
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	destroy_projectile()

func destroy_projectile() -> void:
	is_destroyed = true
	speed = 0
	set_deferred("monitoring", false)
	hit_sound.play()
	
	if hit_sound.playing:
		await hit_sound.finished
		
	if animated_sprite.is_playing() and animated_sprite.animation == "Hit":
		await animated_sprite.animation_finished     
	queue_free()
