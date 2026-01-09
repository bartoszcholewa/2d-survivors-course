extends Node

const BASE_RANGE = 100
const BASE_DAMAGE = 15

@export var anvil_ability_scene: PackedScene

var anvil_count: int = 0

func _ready():
	$Timer.timeout.connect(_on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

	

func _on_timer_timeout():
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation_degrees = 360.0 / (anvil_count + 1)
	var anvil_distance = randf_range(0, BASE_RANGE)
	var sleeping: float = 0.55 - (anvil_count / 10.0)
	
	for i in anvil_count + 1:
		
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * anvil_distance)

		# Ray cast query - shoot ray from player position to dedicated enemy spawn
		# position and return dictionary with all collisions.
		# Protect spawning on top of collision by adding 20px ray offset
		var additional_check_offset = direction * 20
		var query_parameters = PhysicsRayQueryParameters2D.create(
			player.global_position, spawn_position + additional_check_offset, 1
		)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if not result.is_empty():
			spawn_position = result["position"]
			
		var anvil_ability_instance: Node2D = anvil_ability_scene.instantiate()
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability_instance)
		anvil_ability_instance.global_position = spawn_position
		anvil_ability_instance.hitbox_component.damage = BASE_DAMAGE
		await get_tree().create_timer(sleeping).timeout

	
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# Check if upgrade is for sword rate
	if upgrade.id == "anvil_count":
		# Get how many sword rate upgrades player has and make each one as 10% reduction
		anvil_count = current_upgrades["anvil_count"]["quantity"]
