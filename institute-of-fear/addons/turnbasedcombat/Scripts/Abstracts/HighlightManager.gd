extends Node

var hovered: JRPGBaseBattleChar
var selected: JRPGBaseBattleChar
var State: JRPGEnums.HighlightState

func _ready() -> void:
	await JRPGSignalBus.instance.StartDone
	JRPGSignalBus.instance.MouseOver.connect(mouseover)
	JRPGSignalBus.instance.MouseOut.connect(mouseout)
	#JRPGSignalBus.instance.UpdateHighlight.connect(UpdateHighlight)
	JRPGSignalBus.instance.SelectedChar.connect(setselectedChar)
	JRPGSignalBus.instance.SetHighlightState.connect(UpdateHighlightstate)

func setselectedChar(Char: JRPGBaseBattleChar):
	selected = Char
	UpdateHighlight()

func mouseover(Char: JRPGBaseBattleChar):
	hovered = Char
	UpdateHighlight()

func mouseout(Char: JRPGBaseBattleChar):
	hovered = null
	UpdateHighlight()

func UpdateHighlight():
	var all_chars = get_tree().get_nodes_in_group("BattleChar")
	
	# Handle the baseline: If NONE, unhighlight everything instantly
	if State == JRPGEnums.HighlightState.NONE:
		for child in all_chars:
			child.HighLight(false, Color(0.781, 0.781, 0.781, 1.0))
		return

	# Otherwise, let each character figure out its own color based on context
	for child in all_chars:
		child.update_state_highlight(State, selected, hovered)

func UpdateHighlightstate(state: JRPGEnums.HighlightState):
	State = state
	UpdateHighlight()
