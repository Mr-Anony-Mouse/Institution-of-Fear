extends JRPGTurnManager

var turn := 0;

var TargetAlly: bool
var TargetEnemy: bool
var SelectedSkill: JRPGBaseSkill

func _ready() -> void:
	JRPGSignalBus.instance.PlayerTurn.connect(CheckPlayerTurn)
	JRPGSignalBus.instance.EnemyTurn.connect(CallEnemies)
	JRPGSignalBus.instance.EndTurn.connect(func(char,team): Turn())
	JRPGSignalBus.instance.Clicked.connect(SelectTarget)
	JRPGSignalBus.instance.SelectedSkill.connect(PrepareSkillTargeting)
	
	await JRPGSignalBus.instance.StartDone
	Turn()

func Turn():
	if turn == 0:
		turn = 1
		
		for i:int in PlayerTeam.size():
			PlayerTeam[i].AvailableAction = true
		
		JRPGSignalBus.instance.PlayerTurn.emit()
		JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.SELECTABLE_PLAYER)
		JRPGSignalBus.instance.ResultToUI.emit("Player turn")
		JRPGSignalBus.instance.StartTurn.emit(null, JRPGEnums.Team.Player)
	else:
		turn = 0
		JRPGSignalBus.instance.EnemyTurn.emit()
		JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.NONE)
		JRPGSignalBus.instance.ResultToUI.emit("Enemy turn")
		JRPGSignalBus.instance.StartTurn.emit(null, JRPGEnums.Team.Enemy)

func CheckPlayerTurn():
	var playerturn := true
	
	for i:int in PlayerTeam.size():
		var character: JRPGBaseBattleChar = PlayerTeam[i]
		if character.Char.IsAlive() && character.AvailableAction:
			playerturn = false;
			break;
	
	if playerturn:
		JRPGSignalBus.instance.EndTurn.emit(null, JRPGEnums.Team.Player)

func SelectTarget(MouseTarget: JRPGBaseBattleChar):
	if turn != 1 || MouseTarget == null:
		return;
	
	print("selected char: " + MouseTarget.to_string())
	
	if (TargetAlly && MouseTarget.Team == JRPGEnums.Team.Player) || (TargetEnemy && MouseTarget.Team == JRPGEnums.Team.Enemy):
		TargetAlly = false
		TargetEnemy = false
		SelectedCharacter.AvailableAction = false;
		await SelectedSkill.Activate(SelectedCharacter, [MouseTarget])
		JRPGSignalBus.instance.SelectedChar.emit(null)
		JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.SELECTABLE_PLAYER)
		SelectedCharacter = null
		CheckPlayerTurn()
	elif MouseTarget.Team == JRPGEnums.Team.Player && SelectedCharacter == null && MouseTarget.AvailableAction:
		SelectedCharacter = MouseTarget
		JRPGSignalBus.instance.SelectedChar.emit(MouseTarget)

func PrepareSkillTargeting(Skill: JRPGBaseSkill):
	if Skill == null:
		return
	print("selected skill: " + Skill.Name)
	SelectedSkill = Skill
	match SelectedSkill.Target:
		JRPGEnums.Target.All_Enemies:
			var enemies: Array[JRPGBaseBattleChar]
			for node:JRPGBaseBattleChar in get_tree().get_nodes_in_group("BattleChar"):
				if node.Team == JRPGEnums.Team.Enemy:
					enemies.append(node)
			SelectedSkill.activate(SelectedCharacter, enemies)
			JRPGSignalBus.instance.SetSelectedChar.emit(null)
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.SELECTABLE_PLAYER)
			
		JRPGEnums.Target.Enemy:
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.TARGET_ENEMY)
			TargetEnemy = true;
			
		JRPGEnums.Target.All_Allies:
			var allies: Array[JRPGBaseBattleChar]
			for node:JRPGBaseBattleChar in get_tree().get_nodes_in_group("BattleChar"):
				if node.Team == JRPGEnums.Team.Player:
					allies.append(node)
			SelectedSkill.activate(SelectedCharacter, allies)
			JRPGSignalBus.instance.SetSelectedChar.emit(null)
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.SELECTABLE_PLAYER)
			
		JRPGEnums.Target.Ally:
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.TARGET_ALLY)
			TargetAlly = true;
			
		JRPGEnums.Target.Self:
			SelectedSkill.activate(SelectedCharacter, [SelectedCharacter])
			JRPGSignalBus.instance.SetSelectedChar.emit(null)
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.SELECTABLE_PLAYER)
			
		_:
			JRPGSignalBus.instance.SetSelectedChar.emit(null)
			JRPGSignalBus.instance.SetHighlightState.emit(JRPGEnums.HighlightState.NONE)
			push_error("Unhandled target: %s" % SelectedSkill.Target)

func CallEnemies():
	for Char: JRPGBaseBattleChar in EnemyTeam:
		var context := JRPGContext.new()
		context.Allies = EnemyTeam
		context.Enemies = PlayerTeam
		
		Char.AITurn(context)
		await JRPGSignalBus.instance.DidAction;
	
	JRPGSignalBus.instance.EndTurn.emit(null, JRPGEnums.Team.Enemy)
