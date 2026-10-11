extends Control

@export var ButtonsNode: Control
@export var BackButton: Button
var HistoryBox: RichTextLabel
var buttons: Array
var selectingskill := false

## This has to be an Array of JRPGBaseSkill
var selectedcharskills: Array

func _ready() -> void:
	JRPGSignalBus.instance.SelectedChar.connect(GetSelectedChar)
	JRPGSignalBus.instance.ResultToUI.connect(addToHistory)
	
	await get_tree().create_timer(1000).timeout
	
	get_all_children_of_type(ButtonsNode, Button, buttons)

func _physics_process(delta: float) -> void:
	if !selectedcharskills.is_empty() && selectingskill == false:
		buttons[0].disabled = false
		buttons[-1].disabled = false
	elif buttons.size() == 0:
		get_all_children_of_type(ButtonsNode, Button, buttons)
	

func GetSelectedChar(Char: JRPGBaseBattleChar):
	if(Char == null):
		Back()
		selectedcharskills = []
		buttons[0].disabled = true
		buttons[-1].disabled = true
		return
	selectedcharskills = Char.Char.equipped_skills

func ClickSkillsButton():
	selectingskill = true
	for i:int in selectedcharskills.size():
		if i < buttons.size():
			var button: Button = buttons[i]
			var skill: JRPGBaseSkill = selectedcharskills[i]
			
			disconnectbutton(button)
			
			button.text = skill.Name
			button.disabled = false
			button.pressed.connect(func(): JRPGSignalBus.instance.SelectedSkill.emit(skill))
	
	BackButton.visible = true

func Back():
	selectingskill = false
	
	for button: Button in buttons:
		button.text = ""
		disconnectbutton(button)
		button.disabled = true
	
	buttons[0].text = "Skills"
	buttons[0].pressed.connect(ClickSkillsButton)
	buttons[0].disabled = false
	
	buttons[-1].text = "run"
	buttons[-1].pressed.connect(ClickRun)
	buttons[-1].disabled = false
	
	BackButton.visible = false

func ClickRun():
	JRPGSignalBus.instance.EndBattle.emit()

func get_all_children_of_type(current_node: Node, type, result: Array) -> void:	for child in current_node.get_children():
		if is_instance_of(child, type):
			result.append(child)
		get_all_children_of_type(child, type, result)

func disconnectbutton(button: Button):
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection.callable)

func addToHistory(text: String):
	if HistoryBox != null: 
		HistoryBox.text += "> " + text + "\n"
