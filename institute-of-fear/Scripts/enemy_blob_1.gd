extends CharacterBody2D

@export var max_health: int = 10
@export var damage: int = 5
@export var jump_speed: float = 100.0
@export var charge_speed: float = 250.0

var current_health: int
var is_dead: bool = false
var is_jumping: bool = false
var player_ref: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $PlayerDetectionArea/PlayerDetectionRayCast
@onready var path: Path2D = $Path2D
@onready var jump_timer: Timer = $JumpTimer
@onready var state_change_timer: Timer = $StateChangeTimer
@onready var attack_area_collision: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready() -> void:
	print("[DEBUG] Enemy_Blob spawned and _ready() called")
	current_health = max_health
	anim.play("Idle")
	state_change_timer.start()

func _physics_process(_delta: float) -> void:
	# Note: I am not putting a print here because it runs 60 times a second and will flood your console!
	if is_dead:
		return

	if is_jumping:
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_state_change_timer_timeout() -> void:
	print("[DEBUG] StateChangeTimer finished. Checking next move...")
	if is_dead:
		return
		
	if player_ref != null:
		print("[DEBUG] Player is in range. Checking line of sight...")
		raycast.target_position = to_local(player_ref.global_position)
		raycast.force_raycast_update()
		
		if raycast.is_colliding() and raycast.get_collider() == player_ref:
			print("[DEBUG] Line of sight clear! Charging player.")
			execute_jump(player_ref.global_position, charge_speed)
			return
		else:
			print("[DEBUG] Player is blocked by a wall.")
			
	var curve = path.curve
	if curve != null and curve.get_baked_points().size() > 0:
		print("[DEBUG] Player not seen. Wandering randomly on Path2D.")
		var random_offset = randf_range(0.0, curve.get_baked_length())
		var local_target = curve.sample_baked(random_offset)
		execute_jump(path.to_global(local_target), jump_speed)
	else:
		print("[DEBUG] WARNING: Path2D has no points. Enemy cannot wander.")

func execute_jump(target_pos: Vector2, speed: float) -> void:
	print("[DEBUG] Executing jump towards: ", target_pos, " at speed: ", speed)
	is_jumping = true
	anim.play("Jump")
	
	var direction = global_position.direction_to(target_pos)
	velocity = direction * speed
	
	jump_timer.start()

func _on_jump_timer_timeout() -> void:
	print("[DEBUG] JumpTimer finished. Stopping movement.")
	is_jumping = false
	velocity = Vector2.ZERO
	if not is_dead:
		anim.play("Idle")

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	print("[DEBUG] Something entered PlayerDetectionArea: ", body.name)
	if body.name == "Player" or body.has_method("take_damage"):
		print("[DEBUG] It is the Player! Locking target.")
		player_ref = body

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	print("[DEBUG] Something exited PlayerDetectionArea: ", body.name)
	if body == player_ref:
		print("[DEBUG] Player left range. Losing target.")
		player_ref = null

func _on_attack_area_body_entered(body: Node2D) -> void:
	print("[DEBUG] Something entered AttackArea: ", body.name)
	if is_dead:
		return
		
	if body.has_method("take_damage"):
		print("[DEBUG] Damaging player for ", damage)
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	print("[DEBUG] Blob took damage: ", amount)
	if is_dead:
		return
		
	current_health -= amount
	print("[DEBUG] Blob Health is now: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("[DEBUG] Blob die() triggered")
	is_dead = true
	is_jumping = false
	velocity = Vector2.ZERO
	
	state_change_timer.stop()
	jump_timer.stop()
	
	attack_area_collision.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
	anim.play("Death")

func _on_animated_sprite_2d_animation_finished() -> void:
	print("[DEBUG] Animation finished: ", anim.animation)
	if anim.animation == "Death":
		print("[DEBUG] Death animation done. Deleting blob.")
		queue_free()
