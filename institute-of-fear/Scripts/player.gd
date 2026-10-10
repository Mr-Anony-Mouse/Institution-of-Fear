extends CharacterBody2D

@export var walk_speed: float = 150.0
@export var sprint_speed: float = 250.0
@export var max_health: int = 100

# Drag your weapon .tscn files here in the inspector
@export var weapon_scenes: Array[PackedScene] = []
@onready var arsenal_controller: Node2D = $ArsenalController

var current_health: int
var is_attacking: bool = false
var facing_direction: String = "Down"

var current_weapon_index: int = 0
var weapon: Area2D = null

@onready var arsenal: Node2D = $ArsenalController/Arsenal

func _ready() -> void:
	current_health = max_health
	if weapon_scenes.size() > 0:
		_equip_weapon(0)

# ------------------------------------------------------------------
# Weapon management
# ------------------------------------------------------------------

func _equip_weapon(index: int) -> void:
	if weapon_scenes.is_empty():
		return
	if index < 0 or index >= weapon_scenes.size():
		return
	
	current_weapon_index = index
	
	# Free the old weapon
	if is_instance_valid(weapon):
		weapon.queue_free()
		weapon = null
	
	# Instantiate and add the new one
	var scene: PackedScene = weapon_scenes[current_weapon_index]
	weapon = scene.instantiate()
	arsenal.add_child(weapon)

func _switch_weapon(direction: int) -> void:
	if weapon_scenes.is_empty():
		return
	var new_index := wrapi(current_weapon_index + direction, 0, weapon_scenes.size())
	_equip_weapon(new_index)

# ------------------------------------------------------------------
# Physics / movement
# ------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	update_mouse_facing()

	if is_attacking:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	velocity = direction * current_speed
	move_and_slide()

func update_mouse_facing() -> void:
	if is_instance_valid(weapon):
		arsenal_controller.look_at(get_global_mouse_position())

# ------------------------------------------------------------------
# Input
# ------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking:
		attack()
	elif event.is_action_pressed("interact"):
		print("interacting")
	elif event.is_action_pressed("inventory"):
		print("inventory opened")
	elif event.is_action_pressed("scroll_up"):
		_switch_weapon(-1)
	elif event.is_action_pressed("scroll_down"):
		_switch_weapon(1)

# ------------------------------------------------------------------
# Attack
# ------------------------------------------------------------------

func attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO

	if is_instance_valid(weapon) and weapon.has_method("attack"):
		weapon.attack()

	await get_tree().create_timer(0.3).timeout
	is_attacking = false

# ------------------------------------------------------------------
# Health
# ------------------------------------------------------------------

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player Health: ", current_health)
	if current_health <= 0:
		print("Player Died")
		queue_free()
