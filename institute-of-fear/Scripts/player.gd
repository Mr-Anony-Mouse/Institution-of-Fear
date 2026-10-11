extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var walk_speed: float = 150.0
@export var sprint_speed: float = 250.0

@export var max_health: int = 100
var current_health: int
@export var potion_heal_amount: int = 25 

# Drag your weapon .tscn files here in the inspector
@export var weapon_scenes: Array[PackedScene] = []
@onready var arsenal_controller: Node2D = $ArsenalController


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
@onready var action_menu: PopupMenu = $InventoryUI/ActionMenu

var selected_slot_index: int = -1
var context_slot_index: int = -1

const POTION_SCENE = preload("res://Scenes/health_potion.tscn")
const LOCKPICK_SCENE = preload("res://Scenes/lock_pick.tscn")
const AMMO_SCENE = preload("res://Scenes/ammo.tscn")

func _ready() -> void:
	current_health = max_health
	if weapon_scenes.size() > 0:
		_equip_weapon(0)
		print ("1")
		# Force the array to always have 12 empty slots
	inventory.resize(12)
	inventory.fill(null)
	for i in range(slot_grid.get_child_count()):
		var slot = slot_grid.get_child(i)
		slot.gui_input.connect(_on_slot_clicked.bind(i))
	action_menu.id_pressed.connect(_on_action_menu_id_pressed)
		
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
		
		
		#____________
		#inventory
		#------------
		
func add_item(item_texture: Texture2D, amount: int = 1, is_stackable: bool = false) -> void:
	if is_stackable:
		for i in range(inventory.size()):
			if inventory[i] != null and inventory[i]["texture"] == item_texture:
				inventory[i]["amount"] += amount
				print("Stacked! Amount is now: ", inventory[i]["amount"])
				update_inventory_ui()
				return
				
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = {"texture": item_texture, "amount": amount, "stackable": is_stackable}
			print("Item picked up!")
			update_inventory_ui()
			return
			
	print("Inventory Full!")
	
func update_inventory_ui() -> void:
	for i in range(slot_grid.get_child_count()):
		var slot = slot_grid.get_child(i)
		
		var icon = slot.get_node_or_null("Icon") 
		var label = slot.get_node_or_null("AmountLabel") 
		
		if inventory[i] != null:
			if icon != null:
				icon.texture = inventory[i]["texture"]
			
			if label != null:
				if inventory[i]["amount"] > 1:
					label.text = str(inventory[i]["amount"])
				else:
					label.text = ""
		else:
			if icon != null:
				icon.texture = null
			if label != null:
				label.text = ""
				
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
			if inventory[slot_index] != null:
				context_slot_index = slot_index
				action_menu.clear()
				
				var tex = inventory[slot_index]["texture"]
				var item_path = tex.resource_path.to_lower()
				
				if "potion" in item_path or "health" in item_path:
					action_menu.add_item("Drink", 0) 
					
				action_menu.add_item("Drop", 1)  
				
				if action_menu.item_count > 0:
					action_menu.position = Vector2i(get_viewport().get_mouse_position())
					action_menu.popup()
				
				
func drop_item(index: int) -> void:
	if inventory[index] != null:
		var item_texture = inventory[index]["texture"]
		var item_amount = inventory[index]["amount"]
		var item_path = item_texture.resource_path.to_lower()
		
		inventory[index] = null
		update_inventory_ui()
		
		var dropped_item
		
		if "ammo" in item_path: 
			dropped_item = AMMO_SCENE.instantiate()
			if "amount_to_give" in dropped_item:
				dropped_item.amount_to_give = item_amount
		else:
			dropped_item = POTION_SCENE.instantiate()
			
		dropped_item.item_icon = item_texture
		
		get_parent().add_child(dropped_item)
		dropped_item.global_position = global_position + Vector2(0, 40)
		
		if dropped_item.has_node("Sprite2D"):
			var drop_sprite = dropped_item.get_node("Sprite2D")
			drop_sprite.texture = item_texture
			
			if item_texture is AtlasTexture:
				drop_sprite.region_enabled = true
				drop_sprite.region_rect = item_texture.region

func _on_action_menu_id_pressed(id: int) -> void:
	if context_slot_index == -1 or inventory[context_slot_index] == null:
		return
		
	if id == 0:
		drink_potion(context_slot_index)
	elif id == 1:
		drop_item(context_slot_index)
		
	context_slot_index = -1
	update_inventory_ui()

func drink_potion(index: int) -> void:
	current_health += potion_heal_amount
	if current_health > max_health:
		current_health = max_health
		
	print("Drank potion! Health is now: ", current_health)
	
	inventory[index] = null
	update_inventory_ui()
	
func check_ammo_count() -> int:
	var total = 0
	for item in inventory:
		if item != null:
			var item_path = item["texture"].resource_path.to_lower()
			var manual_name = item["texture"].resource_name.to_lower()
			if "ammo" in item_path or "ammo" in manual_name:
				total += item["amount"]
	return total
	
