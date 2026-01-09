extends CanvasLayer

@export var arena_time_manager: Node
@export var enemy_manager: Node
@onready var time_left_value_label: Label = %TimeLeftValueLabel
@onready var enemy_count_value_label: Label = %EnemyCountValueLabel
@onready var enemy_spawn_per_second_value_label: Label = %EnemySpawnPerSecondValueLabel


func _process(delta: float) -> void:
	if arena_time_manager == null:
		return
	
	update_time_left_label()
	update_enemy_count_label()
	update_enemy_spawn_per_second_label()

func update_time_left_label():
	time_left_value_label.text = _format_seconds_to_string(arena_time_manager.timer.time_left)
	

func update_enemy_count_label():
	enemy_count_value_label.text = str(enemy_manager.active_enemy_count)


func update_enemy_spawn_per_second_label():
	enemy_spawn_per_second_value_label.text = str(enemy_manager.number_to_spawn)


func _format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(int(minutes)) + ":" + ("%02d" % floor(remaining_seconds))
	
