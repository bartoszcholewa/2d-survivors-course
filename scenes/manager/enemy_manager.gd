## Manages the spawning of basic enemies around the player's position.
##
## This script finds the player in the "player" group and periodically
## spawns a new enemy instance at a fixed radius in a random direction.
extends Node

## The scene to be instantiated when spawning an enemy.
@export var basic_enemy_scene: PackedScene

@export var wizard_enemy_scene: PackedScene

@export var bat_enemy_scene: PackedScene

## Managers
@export var arena_time_manager: Node

## Timer
@onready var timer = $Timer

## Distance from the player where enemies will be spawned.
const SPAWN_RADIUS: float = 375.0

## Cached reference to the player node.
var player: Node2D

## Global variables
var base_spawn_time = 0

var enemy_table = WeightedTable.new()

var number_to_spawn: int = 1

## The current number of active enemies in the scene.
var active_enemy_count: int = 0


func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 10)
	# Set global
	base_spawn_time = timer.wait_time
	
	
	_initialize_player_reference()
	_connect_signals()


## Finds the player node and validates its existence.
func _initialize_player_reference() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	
	# Development-time check
	assert(player != null, "EnemySpawner: Player node not found! Ensure Player is in 'player' group.")


## Connects internal or external signals.
func _connect_signals() -> void:
	assert(timer != null, "EnemySpawner: Timer node not found as a child!")
	timer.timeout.connect(_on_timer_timeout)
	
	arena_time_manager.arena_difficulty_increased.connect(_on_arena_difficulty_increased)


## Callback triggered by the Timer to spawn a new enemy.
func _on_timer_timeout() -> void:
	# Reset timer
	timer.start()
	
	# Safety check for production: if player was freed (e.g. game over), stop spawning.
	if not is_instance_valid(player):
		return

	_spawn_enemy()


func _get_spawn_position() -> Vector2:
	
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		# Calculate a random position on the circle circumference
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		
		# Protect spawning on top of collision by adding 20px ray offset
		var additional_check_offset = random_direction * 20
		
		# Ray cast query - shoot ray from player position to dedicated enemy spawn
		# position and return dictionary with all collisions.
		var query_parameters = PhysicsRayQueryParameters2D.create(
			player.global_position, spawn_position + additional_check_offset, 1
		)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			# Break the loop if no collision found
			break
		else:
			# Set new direction by rotating by 90 deg and try again
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

## Handles the instantiation and positioning of the enemy.
func _spawn_enemy() -> void:

	for i in number_to_spawn:
		var enemy_scene = enemy_table.pick_item()
		# Instantiate and add to the scene tree
		var enemy: Node2D = enemy_scene.instantiate() as Node2D
		
		# Adding to parent to avoid enemy moving along with the spawner's local transform
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = _get_spawn_position()
		
		# Increment count when enemy enters the world
		active_enemy_count += 1
		
		# Connect to tree exited to decrement count automatically when freed
		enemy.tree_exited.connect(_on_enemy_tree_exited)

## Arena difficulty/second table:[br]
## - 6 -  0:30min[br]
## - 12 - 1:00min[br]
## - 18 - 1:30min
func _on_arena_difficulty_increased(arena_difficulty: int):

	
	var time_off = (0.1 / 12) * arena_difficulty
	
	# Dont go below 0.7s reduction (max 0.3s spawn time)
	time_off = min(time_off, 0.7)
	
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 15)
	elif arena_difficulty == 18:
		enemy_table.add_item(bat_enemy_scene, 8)
		
	if (arena_difficulty % 12) == 0:
		number_to_spawn += 1

## Called whenever an enemy node is removed from the scene tree.
func _on_enemy_tree_exited() -> void:
	# Decrement count and ensure it bever drops below zero
	active_enemy_count = max(active_enemy_count - 1, 0)
