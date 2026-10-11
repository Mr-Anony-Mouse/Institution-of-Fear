extends Area2D

@export var item_icon: Texture2D
var amount_to_give: int = 1 

@onready var sprite = $Sprite2D 

func _ready() -> void:
	collision_mask = 0 
	
	if item_icon != null:
		sprite.texture = item_icon
		
	await get_tree().create_timer(0.5).timeout
	
	collision_mask = 1

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_item"):
		print("Picking up ammo stack of: ", amount_to_give)  
		body.add_item(item_icon, amount_to_give, true) 
		queue_free()
