extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var walk_speed: float = 150.0
@export var sprint_speed: float = 250.0
@export var max_health: int = 100

# Drag your weapon .tscn files here in the inspector
@export var weapon_scenes: Array[PackedScene] = []
@onready var arsenal_controller: Node2D = $ArsenalController

var current_health: int
var is_attacking: bool = false
var facing_direction: String = "Down"

var direction: String

var current_weapon_index: int = 0
var weapon: Area2D = null

var inventory: Array = []
var max_inventory_size: int = 12

@onready var inventory_ui: CanvasLayer = $InventoryUI

@onready var arsenal: Node2D = $ArsenalController/Arsenal

@onready var slot_grid: GridContainer = $InventoryUI/Background/SlotGrid
var selected_slot_index: int = -1
var UI_inventory

const POTION_SCENE = preload("res://Scenes/health_potion.tscn")

func _ready() -> void:
	current_health = max_health
	if weapon_scenes.size() > 0:
		_equip_weapon(0)
		
		# Force the array to always have 12 empty slots
	inventory.resize(12)
	inventory.fill(null)
	for i in range(slot_grid.get_child_count()):
		var slot = slot_grid.get_child(i)
		slot.gui_input.connect(_on_slot_clicked.bind(i))
		
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

func _physics_process(delta: float) -> void:
	update_mouse_facing()

	if is_attacking:
		return

	#var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	animated_sprite_2d.speed_scale == 999 * delta if Input.is_action_pressed("sprint") else 1.0 * delta

	#velocity = direction * speed
	
	
	if Input.is_action_pressed("move_up"):
		direction = "up"
		velocity.x = 0
		velocity.y = -speed
		animated_sprite_2d.play("up")
	elif Input.is_action_pressed("move_down"):
		direction = "down"
		velocity.x = 0
		velocity.y = speed
		animated_sprite_2d.play("down")
	elif Input.is_action_pressed("move_left"):
		direction = "left"
		velocity.x = -speed
		velocity.y = 0
		animated_sprite_2d.play("left")
	elif Input.is_action_pressed("move_right"):
		direction = "right"
		velocity.x = speed
		velocity.y = 0
		animated_sprite_2d.play("right")
	else:
		velocity.x = 0
		velocity.y = 0
		if direction == "up":
			animated_sprite_2d.play("idle_up")
		elif direction == "down":
			animated_sprite_2d.play("idle_down")
		elif direction == "left":
			animated_sprite_2d.play("idle_left")
		elif direction == "right":
			animated_sprite_2d.play("idle_right")
	
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
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = inventory_ui.visible
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
		
func add_item(item_texture: Texture2D) -> void:

	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item_texture
			print("Item picked up!")
			update_inventory_ui()
			return
			
	print("Inventory Full!")
	
func update_inventory_ui() -> void:
	for i in range(slot_grid.get_child_count()):
		var slot = slot_grid.get_child(i)
		
		if slot.get_child_count() > 0:
			var icon = slot.get_child(0) 
			icon.texture = inventory[i]
			
			if i == selected_slot_index:
				slot.modulate = Color(0.5, 0.5, 0.5)
			else:
				slot.modulate = Color(1, 1, 1)

func _on_slot_clicked(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if selected_slot_index == -1:
				if inventory[slot_index] != null:
					selected_slot_index = slot_index
					update_inventory_ui()
			else:
				var temp_item = inventory[slot_index]
				inventory[slot_index] = inventory[selected_slot_index]
				inventory[selected_slot_index] = temp_item
				
				selected_slot_index = -1
				update_inventory_ui()
				
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			drop_item(slot_index)
			if selected_slot_index == slot_index:
				selected_slot_index = -1
				update_inventory_ui()

func drop_item(index: int) -> void:
	if inventory[index] != null:
		var item_texture = inventory[index]
		
		inventory[index] = null
		update_inventory_ui()
		
		var dropped_item = POTION_SCENE.instantiate()
		dropped_item.item_icon = item_texture
		dropped_item.global_position = global_position + Vector2(0, 40)
		get_tree().current_scene.add_child(dropped_item)
