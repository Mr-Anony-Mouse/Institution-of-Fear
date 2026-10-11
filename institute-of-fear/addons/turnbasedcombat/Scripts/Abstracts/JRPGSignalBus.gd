extends Node
class_name JRPGSignalBus

#PUT SIGNALS HERE
signal StartTurn(Character: JRPGBaseBattleChar, Team: JRPGEnums.Team) #AddCharacterRef for effects
signal EndTurn(Character: JRPGBaseBattleChar, Team: JRPGEnums.Team) #AddCharacterRef for effects
signal PlayerTurn
signal EnemyTurn
signal DidAction
signal EndBattle

signal SelectedSkill(Skill: JRPGBaseSkill)

signal Start(pos : Vector2, char : JRPGBaseBattleChar)
signal StartDone
signal Clicked(char : JRPGBaseBattleChar)
signal MouseOver(char : JRPGBaseBattleChar)
signal MouseOut(char : JRPGBaseBattleChar)

#UI Signals
signal ResultToUI(text: String)
signal UpdateHighlight()
signal SelectedChar(char : JRPGBaseBattleChar)
signal SetHighlightState(State: JRPGEnums.HighlightState)

static var instance: JRPGSignalBus

func _enter_tree():
	if instance != null and instance != self:
		queue_free()
		return
	instance = self

func _exit_tree():
	if instance == self:
		instance = null
