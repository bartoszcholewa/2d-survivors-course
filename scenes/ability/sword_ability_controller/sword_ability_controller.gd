extends Node

const MAX_RANGE = 150

@export var sword_ability: PackedScene

# Cache the player reference
var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update player cache
	player = get_tree().get_first_node_in_group("player")
	
	# Listen to a signal
	$Timer.timeout.connect(on_timer_timeout)

func on_timer_timeout():
	# Get player node
	
	if player == null:
		print("Player node not found in on_timer_timeout()")
		return
	
	# Get enemies nodes and keep only those in range
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(
		func(enemy: Node2D):
			return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	if enemies.is_empty():
		return
		
	# Sort by closest to player
	enemies.sort_custom(
		func(a: Node2D, b: Node2D):
			var a_distance = a.global_position.distance_squared_to(player.global_position)
			var b_distance = b.global_position.distance_squared_to(player.global_position)
			return a_distance < b_distance
	)
	
	# Check for the Sword Ability
	# Since sword_ability is an @export variable, the code will crash if you 
	#	forget to drag and drop the Sword scene into the Inspector.
	if sword_ability == null:
		print("Sword ability not found in on_timer_timeout()")
	
	# Create new sword instance
	var sword_instance: Node2D = sword_ability.instantiate()

	# Add sword to scene
	player.get_parent().add_child(sword_instance)
	
	# Set sword position to closest enemy
	sword_instance.global_position = enemies[0].global_position
	
	# Randomize sword rotation ???? WHY? Without it the sword always face RIGHT
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	# Point sword animation toward enemy
	var enemy_direction = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()
