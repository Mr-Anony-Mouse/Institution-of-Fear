extends Area2D

@export var projectile_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var attack_timer: Timer = $AttackTimer
@onready var equip_sound: AudioStreamPlayer2D = $EquipSound
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var raycast: RayCast2D = $RayCast2D

var direction
var mouse_pos 

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	equip_weapon()

func _process(_delta: float) -> void:

	#look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("attack"):
		shoot()

func equip_weapon() -> void:
	print("weapon equipped")
	animated_sprite.play("Equip")
	equip_sound.play()

func shoot() -> void:
	if not attack_timer.is_stopped():
		return 
		
	attack_timer.start()
	animated_sprite.play("Shoot")
	print("BANG!BANG!BANG!")
	shoot_sound.pitch_scale = randf_range(0.8, 1.2)
	shoot_sound.play()
	
	await get_tree().create_timer(0.8).timeout
	
	if projectile_scene != null:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = muzzle.global_position
		projectile.direction = (get_global_mouse_position() - global_position).normalized()
		muzzle.add_child(projectile)

func _on_animation_finished() -> void:
	if animated_sprite.animation == "Equip" or animated_sprite.animation == "Shoot":
		animated_sprite.play("Idle")
