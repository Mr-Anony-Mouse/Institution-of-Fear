extends Node2D
class_name JRPGBaseBattleChar

var Animator: AnimationPlayer
var AIControl: JRPGAIController
var Char: JRPGCharInstance
var StatusEffects: Dictionary[JRPGBaseEffect,int]
var Team: JRPGEnums.Team

var HitChance: float = 1;
var Defense: float = 1;
var Strength: float = 1;

var AvailableAction := false

func _ready() -> void:
	Animator = $Animationplayer
	AIControl = $AIControl
	
	JRPGSignalBus.instance.StartTurn.connect(ApplyEffect.bind(true))
	JRPGSignalBus.instance.EndTurn.connect(ApplyEffect.bind(false))

func playstart(pos : Vector2):
	var tween = get_tree().create_tween()
	
	var time := 0.01 * global_position.distance_to(pos)
	tween.tween_property(self, "global_position", pos, time)
	
	if pos.x > global_position.x:
		Animator.play("WalkRight")
	elif pos.x < global_position.x:
		Animator.play("WalkLeft")
		
	await tween.finished
	Animator.play("Idle")
	JRPGSignalBus.instance.StartDone.emit()

func AITurn(Context: JRPGContext):
	AIControl.ChooseAction(self, Context);

func ApplySkill(Amount: int, DamageType: JRPGEnums.DamageType, Element: JRPGEnums.Elements, Caster: JRPGBaseBattleChar):
	if DamageType == JRPGEnums.DamageType.Damage:
		Char.current_hp -= Amount * Defense;
		JRPGSignalBus.instance.ResultToUI.emit(Caster.Char.species.Name + " attacked " + Char.species.Name + " for " + str(Amount) + " damage")
		
	elif DamageType == JRPGEnums.DamageType.Health:
		Char.current_hp = clampi(Char.current_hp + Amount, Char.current_hp, Char.max_hp)
		JRPGSignalBus.instance.ResultToUI.emit(Caster.Char.species.Name + " Healed " + Char.species.Name + " for " + str(Amount) + " health")
		
func ApplyEffect(Char: JRPGBaseBattleChar, Team: JRPGEnums.Team, StartofTurn: bool):
	var remove: Array[JRPGBaseEffect] = []
	
	for effect: JRPGBaseEffect in StatusEffects:
		if effect.isStartOfTurn == StartofTurn:
			StatusEffects[effect] -= 1
			if StatusEffects[effect] == 0:
				remove.append(effect)
			else:
				effect.Apply(self)
	for item: JRPGBaseEffect in remove:
		item.remove(self);
		StatusEffects.erase(item)

func TakeDamage(Amount: int, Effect: JRPGBaseEffect = null):
	Char.current_hp -= Amount;
	if Effect:
		JRPGSignalBus.instance.ResultToUI.emit(Effect.Name + " Damaged " + Char.species.Name + " for " + str(Amount) + " health")

func Heal(Amount: int, Effect: JRPGBaseEffect = null):
	Char.current_hp = clampi(Char.current_hp + Amount, Char.current_hp, Char.max_hp)
	if Effect:
		JRPGSignalBus.instance.ResultToUI.emit(Effect.Name + " Healed " + Char.species.Name + " for " + str(Amount) + " health")

func DrainMagi(Amount: int, Effect: JRPGBaseEffect = null):
	Char.current_magi -= Amount;
	if Effect:
		JRPGSignalBus.instance.ResultToUI.emit(Effect.Name + " drained " + str(Amount) + " magi from " + Char.species.Name)

func FillMagi(Amount: int, Effect: JRPGBaseEffect = null):
	Char.current_magi = clampi(Char.current_magi + Amount, Char.current_magi, Char.max_magi)
	if Effect:
		JRPGSignalBus.instance.ResultToUI.emit(Effect.Name + " filled " + Char.species.Name + "'s magi for " + str(Amount))

func update_state_highlight(state: JRPGEnums.HighlightState, selected: JRPGBaseBattleChar, hovered: JRPGBaseBattleChar) -> void:
	match state:
		JRPGEnums.HighlightState.SELECTABLE_PLAYER:
			if Team != JRPGEnums.Team.Player: 
				HighLight(false, Color(0.781, 0.781, 0.781, 1.0))
				return
				
			if self == selected:
				HighLight(true, Color(0.97, 1.0, 0.445, 1.0))
			elif self == hovered && AvailableAction:
				HighLight(true, Color(0.97, 1.0, 0.445, 1.0))
			elif AvailableAction:
				HighLight(true, Color(0.644, 0.357, 0.0, 1.0))

		JRPGEnums.HighlightState.TARGET_ENEMY:
			# Special case: Always keep the acting player highlighted yellow
			if self == selected:
				HighLight(true, Color(0.97, 1.0, 0.445, 1.0))
				return
				
			if Team == JRPGEnums.Team.Enemy:
				var red = Color(1.0, 0.242, 0.242, 1.0) if self == hovered else Color(0.473, 0.0, 0.0, 1.0)
				HighLight(true, red)
			else:
				HighLight(false, Color(0.781, 0.781, 0.781, 1.0))

		JRPGEnums.HighlightState.TARGET_ALLY:
			if Team == JRPGEnums.Team.Player:
				if self == hovered:
					HighLight(true, Color(0.0, 0.742, 0.0, 1.0))
				elif self == selected:
					HighLight(true, Color(0.97, 1.0, 0.445, 1.0))
				else:
					HighLight(true, Color(0.0, 0.512, 0.0, 1.0))
			else:
				HighLight(false, Color(0.781, 0.781, 0.781, 1.0))

func _on_select_area_mouse_entered() -> void:
	JRPGSignalBus.instance.MouseOver.emit(self)

func _on_select_area_mouse_exited() -> void:
	JRPGSignalBus.instance.MouseOut.emit(self)

func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			JRPGSignalBus.instance.Clicked.emit(self)

func HighLight(enable: bool, color: Color):
	material.set_shader_parameter("outline_enabled", enable)
	material.set_shader_parameter("outline_color", color)
