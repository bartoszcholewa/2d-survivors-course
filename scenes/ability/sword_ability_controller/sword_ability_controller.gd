extends Node

const MAX_RANGE = 150

@export var sword_ability: PackedScene

var damage = 5
var base_wait_time

# Cache the player reference
var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update player cache
	player = get_tree().get_first_node_in_group("player")
	
	# Set base wait time for sword attack
	base_wait_time = $Timer.wait_time
	
	# Listen to a signal
	$Timer.timeout.connect(on_timer_timeout)
	
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

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
	var sword_instance: SwordAbility = sword_ability.instantiate()

	# Add sword to scene
	player.get_parent().add_child(sword_instance)
	
	# Assign damage
	sword_instance.hitbox_component.damage = damage
	
	# Set sword position to closest enemy
	sword_instance.global_position = enemies[0].global_position
	
	# Randomize sword rotation ???? WHY? Without it the sword always face RIGHT
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	# Point sword animation toward enemy
	var enemy_direction = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# Check if upgrade is for sword rate
	if upgrade.id != "sword_rate":
		return
	
	# Get how many sword rate upgrades player has and make each one as 10% reduction
	var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
	
	# Reduce sword rate timer by percent
	$Timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	# Restart timer with new wait time value
	$Timer.start()
	
	print($Timer.wait_time)
