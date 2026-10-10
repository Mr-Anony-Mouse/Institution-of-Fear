extends CharacterBody2D

@export var max_health: int = 10
@export var damage: int = 5
@export var jump_speed: float = 45.0
@export var charge_speed: float = 180.0

var current_health: int
var player: Node2D = null
var is_attacking: bool = false
var is_dead: bool = false

# @onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $DetectionArea/PlayerRayCast
@onready var jump_timer: Timer = $JumpTimer

func _ready() -> void:
	current_health = max_health
	# sprite.play("Idle")
	jump_timer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if player != null and not is_attacking:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		
		if raycast.is_colliding() and raycast.get_collider() == player:
			charge_at_player()

	move_and_slide()

func charge_at_player() -> void:
	is_attacking = true
	jump_timer.stop() # Stop random jumping
	# sprite.play("Jump")
	
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * charge_speed
	
	await get_tree().create_timer(1.0).timeout
	
	is_attacking = false
	velocity = Vector2.ZERO
	# sprite.play("Idle")
	jump_timer.start()
	
# RANDOM MOVE 
func _on_jump_timer_timeout() -> void:
	if is_dead or is_attacking:
		return
		
	var random_dir = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	velocity = random_dir * jump_speed
	# sprite.play("Jump")
	
	await get_tree().create_timer(0.25).timeout
	
	if not is_dead and not is_attacking:
		velocity = Vector2.ZERO
		# sprite.play("Idle")
		
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.has_method("take_damage"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		
func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_dead or not is_attacking:
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	current_health -= amount
	print("enemy said ouch ", current_health)
	
	if current_health <= 0:
		is_dead = true
		
		queue_free()
