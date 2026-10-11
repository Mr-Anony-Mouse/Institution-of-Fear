extends Area2D

@export var item_icon: Texture2D 

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_item") and item_icon != null:
		body.add_item(item_icon)
		queue_free()
