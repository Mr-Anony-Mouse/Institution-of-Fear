extends Control

signal finished(success: bool)

@export var marker_speed := 450.0
@export var zone_width := 50.0
@export var max_attempts := 3

@onready var bar: ColorRect = $Panel/Bar
@onready var marker: ColorRect = $Panel/Bar/Marker
@onready var progress: ProgressBar = $Panel/ProgressBar
@onready var attempts_label: Label = $Panel/AttemptsLabel
@onready var message_label: Label = $Panel/MessageLabel
@onready var pick_button: Button = $Panel/PickButton
@onready var retry_button: Button = $Panel/RetryButton
@onready var close_button: Button = $Panel/CloseButton

var zones: Array[ColorRect] = []
var total_zones := 0
var hits := 0
var attempts_left := 0
var direction := 1
var running := false


func _ready() -> void:
	pick_button.pressed.connect(_try_pick)
	retry_button.pressed.connect(start)
	close_button.pressed.connect(_on_close)
	hide()


func start() -> void:
	show()
	_clear_zones()
	_generate_zones()
	hits = 0
	attempts_left = max_attempts
	direction = 1
	marker.position.x = 0
	progress.value = 0
	message_label.text = ""
	retry_button.hide()
	pick_button.show()
	_update_attempts()
	running = true


func _process(delta: float) -> void:
	if not running:
		return
	marker.position.x += direction * marker_speed * delta
	var max_x := bar.size.x - marker.size.x
	if marker.position.x >= max_x:
		marker.position.x = max_x
		direction = -1
	elif marker.position.x <= 0:
		marker.position.x = 0
		direction = 1


func _unhandled_input(event: InputEvent) -> void:
	if running and event.is_action_pressed("ui_accept"): 
		_try_pick()


func _try_pick() -> void:
	if not running:
		return
	var marker_center := marker.position.x + marker.size.x / 2.0
	for zone in zones:
		if zone.visible and marker_center >= zone.position.x \
				and marker_center <= zone.position.x + zone.size.x:
			zone.hide()
			hits += 1
			progress.value = float(hits) / total_zones * 100.0
			if hits >= total_zones:
				_win()
			return
			
	attempts_left -= 1
	_update_attempts()
	if attempts_left <= 0:
		_lose()


func _win() -> void:
	running = false
	message_label.text = "Success!"
	pick_button.hide()
	await get_tree().create_timer(1.0).timeout
	hide()
	finished.emit(true)


func _lose() -> void:
	running = false
	message_label.text = "Failed!"
	pick_button.hide()
	retry_button.show()


func _on_close() -> void:
	running = false
	hide()
	finished.emit(false)


func _update_attempts() -> void:
	attempts_label.text = "Chances: %d" % attempts_left


func _generate_zones() -> void:
	total_zones = randi_range(3, 5)
	var tries := 0
	while zones.size() < total_zones and tries < 200:
		tries += 1
		var x := randf_range(0.0, bar.size.x - zone_width)
		var overlaps := false
		for z in zones:
			if abs(z.position.x - x) < zone_width + 10.0:  
				overlaps = true
				break
		if overlaps:
			continue
		var zone := ColorRect.new()
		zone.color = Color(0.2, 0.9, 0.3, 0.8)
		zone.position = Vector2(x, 0)
		zone.size = Vector2(zone_width, bar.size.y)
		bar.add_child(zone)
		bar.move_child(zone, 0) 
		zones.append(zone)
	total_zones = zones.size()


func _clear_zones() -> void:
	for z in zones:
		z.queue_free()
	zones.clear()
