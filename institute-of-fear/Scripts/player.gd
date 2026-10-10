extends CharacterBody2D

@export var walk_speed: float = 150.0
@export var sprint_speed: float = 250.0
@export var max_health: int = 100

var current_health: int
var is_attacking: bool = false
var facing_direction: String = "Down" 

@onready var weapons: Node2D = $weapons 

func _ready() -> void:
	current_health = max_health

func _physics_process(_delta: float) -> void:
	if is_attacking:
		return
		
	update_mouse_facing()

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var current_speed: float
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	else:
		current_speed = walk_speed

	velocity = direction * current_speed
	move_and_slide()

func update_mouse_facing() -> void:
	weapons.look_at(get_global_mouse_position())
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking:
		attack()
	elif event.is_action_pressed("interact"):
		print("interacting")
	elif event.is_action_pressed("inventory"):
		print("inventory openned")

func attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO 
	
	if weapons.get_child_count() > 0:
		var current_weapon = weapons.get_child(0)
		if current_weapon.has_method("attack"):
			current_weapon.attack()
	
	await get_tree().create_timer(0.3).timeout
	
	is_attacking = false

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player Health: ", current_health)
	
	if current_health <= 0:
		print("Player Died")
		queue_free()
