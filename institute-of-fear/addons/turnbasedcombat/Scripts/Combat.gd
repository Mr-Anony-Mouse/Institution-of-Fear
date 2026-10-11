extends Node2D
class_name JRPGCombatManager

enum TurnManagerStyle {
	## per turn the player can choose all of the characters to do something once
	PerTeam,
	## per turn the player get to choose the action of one character in the order of [color=green]ally1,ally2,ally3[/color],[color=red]enemy1,enemy2,enemy3[/color]
	OrderTeam,
	## per turn the player get to choose the action of one character in the order of [color=green]ally1[/color],[color=red]enemy1[/color],[color=green]ally2[/color],[color=red]enemy2[/color],[color=green]ally3[/color],[color=red]enemy3[/color]
	OrderAternating,
	## the turn order gets decided by the [color=yellow][b]speed[/b][/color] stat of the character
	OrderStat,
	## the turn order gets decided by the [color=yellow][b]speed[/b][/color] stat of the character and this stat can be affected mid battle
	LooseOrderStat,
}

## choice for which [b]TurnManager[/b] you want to use in combat
@export var turnmanagerstyle: TurnManagerStyle = TurnManagerStyle.PerTeam
@export var PlayerTeamNode: Node2D
@export var EnemyTeamNode: Node2D
## Filepath where all you character for the turn based combat are. they need to be structured like: res://[yourfolders]/[example]Battlechars/[speciesname]/Battle.tscn the structure is important otherwise this won't be able to find the characters. To see an example look at the template scene
@export var CharactersPath: String
@export_enum("History", "Team resources") var LeftPanel = "History"

@export_group("UI")
@export var Background: Texture2D
@export_subgroup("Theme")
@export var EnableCustomTheme: bool
@export var CustomTheme: Theme


## if true adds a little randomization to the choice of attacks the enemies do
static var RandomizeAttacks: bool = false
## if true tries to prevent enemy from spamming a single attack over and over
static var SpamPenalty: bool = false

## array of character for the players team [color=green][b]3 max[/b][/color]
var PlayerTeam: Array[JRPGCharInstance]
## array of character for the enemy team [color=green][b]3 max[/b][/color]
var EnemyTeam: Array[JRPGCharInstance]
var TurnManagerinstance: JRPGTurnManager


func start():
	
	match turnmanagerstyle:
		TurnManagerStyle.PerTeam:
			var preinstance = load("res://addons/turnbasedcombat/Scripts/TurnManagers/TurnManagerPerTeam.gd")
			TurnManagerinstance = preinstance.new()
			add_child(TurnManagerinstance)
			SetupPerTeam()
		TurnManagerStyle.OrderTeam:
			push_error("Not implemented yet!")
		TurnManagerStyle.OrderAternating:
			push_error("Not implemented yet!")
		TurnManagerStyle.OrderStat:
			push_error("Not implemented yet!")
		TurnManagerStyle.LooseOrderStat:
			push_error("Not implemented yet!")
	
	match LeftPanel:
		"History":
			var history = load("res://addons/turnbasedcombat/Nodes/textbox.tscn").instantiate()
			$"UI/Main UI/HBoxContainer".add_child(history)
			$UI.HistoryBox = history.get_child(0)
			$"UI/Main UI/HBoxContainer".move_child(history, 0)
		"Team resources":
			var teamresources = load("res://addons/turnbasedcombat/Nodes/TeamHP.tscn").instantiate()
			$"UI/Main UI/HBoxContainer".add_child(teamresources)
			teamresources.Setup(PlayerTeam)
			$"UI/Main UI/HBoxContainer".move_child(teamresources, 0)
			
	if EnableCustomTheme:
		var controlnodes = find_children("*", "Control")
		
		for controlnode: Control in controlnodes:
			controlnode.theme = CustomTheme
		
	if Background != null:
		$Background/TextureRect.theme = null
		$Background/TextureRect.texture = Background;
		$Background/TextureRect.position.x = (1152 - Background.get_size().x) / 2
		$Background/TextureRect.position.y = (648 - Background.get_size().y) / 2

func LoadChars() -> Array[JRPGBaseBattleChar]: 
	var characters: Array[JRPGBaseBattleChar] 
	
	for i:int in PlayerTeam.size():
		var instance : JRPGBaseBattleChar = load(CharactersPath + PlayerTeam[i].species.Name + "/battle.tscn").instantiate()
		instance.add_to_group("BattleChar")
		instance.Team = JRPGEnums.Team.Player
		characters.push_back(instance)
		PlayerTeamNode.add_child(instance)
		instance.global_position = PlayerTeamNode.get_child(i).global_position - Vector2(450,0)
		instance.Char = PlayerTeam[i]
		
		TurnManagerinstance.PlayerTeam.append(instance)
	
	for i:int in EnemyTeam.size():
		var instance : JRPGBaseBattleChar = load(CharactersPath + EnemyTeam[i].species.Name + "/battle.tscn").instantiate()
		instance.add_to_group("BattleChar")
		instance.Team = JRPGEnums.Team.Enemy
		characters.push_back(instance)
		EnemyTeamNode.add_child(instance)
		instance.global_position = EnemyTeamNode.get_child(i).global_position + Vector2(450,0)
		instance.Char = EnemyTeam[i]
		
		TurnManagerinstance.EnemyTeam.append(instance)
	
	return characters

func SetupPerTeam():
	var Characters: Array[JRPGBaseBattleChar] = LoadChars()
	
	var i := 0
	var j := 0
	
	for char:JRPGBaseBattleChar in Characters:
		if char.Team == JRPGEnums.Team.Player:
			char.playstart(PlayerTeamNode.get_child(i).global_position)
			i += 1
		elif char.Team == JRPGEnums.Team.Enemy:
			char.playstart(EnemyTeamNode.get_child(j).global_position)
			j += 1
