extends HBoxContainer

var char: JRPGCharInstance

func _process(delta: float) -> void:
	$Label.text = char.species.Name
	
	if has_node("Panel/MagiBar"):
		$Panel/MagiBar.value = char.current_magi * 100 / char.max_magi
	$Panel/HPBar.value = char.current_hp * 100 / char.max_hp
