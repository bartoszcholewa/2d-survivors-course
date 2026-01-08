extends CanvasLayer

var options_scene: PackedScene = preload("res://scenes/ui/options_menu.tscn")


func _ready() -> void:
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	
	
func on_play_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	
func on_options_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_menu_instance: Node = options_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))
	
func on_quit_pressed() -> void:
	get_tree().quit()
	
	
func on_options_back_pressed(option_instance: Node) -> void:
	option_instance.queue_free()
