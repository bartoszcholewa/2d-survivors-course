extends Node

@export var axe_ability_scene: PackedScene

var damage = 10

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	
	
func on_timer_timeout():
	# Get player node
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	# Get layer for weapons
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	# Create new axe instance
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	
	# Add new axe to foreground layer
	foreground.add_child(axe_instance)
	
	# Set axe position on top of a player
	axe_instance.global_position = player.global_position
	
	# Set axe damage
	axe_instance.hitbox_component.damage = damage
	
	
