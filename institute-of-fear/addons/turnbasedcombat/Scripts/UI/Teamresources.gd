extends Panel

var team : Array[JRPGCharInstance]

func Setup(Team : Array[JRPGCharInstance]):
	for char : JRPGCharInstance in Team:
		var UI
		if char.max_magi != 0:
			UI = load("res://addons/turnbasedcombat/Nodes/CharStatBarForUI.tscn").instantiate()
		else:
			UI = load("res://addons/turnbasedcombat/Nodes/CharHPBarForUI.tscn").instantiate()
		
		UI.char = char
		$VBoxContainer.add_child(UI)
