## Manages the spawning of basic enemies around the player's position.
##
## This script finds the player in the "player" group and periodically
## spawns a new enemy instance at a fixed radius in a random direction.
extends Node

## The scene to be instantiated when spawning an enemy.
@export var basic_enemy_scene: PackedScene

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


func _ready() -> void:
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


## Handles the instantiation and positioning of the enemy.
func _spawn_enemy() -> void:
	# Calculate a random position on the circle circumference
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position: Vector2 = player.global_position + (random_direction * SPAWN_RADIUS)
	
	# Instantiate and add to the scene tree
	var enemy: Node2D = basic_enemy_scene.instantiate() as Node2D
	
	# Adding to parent to avoid enemy moving along with the spawner's local transform
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = spawn_position


func _on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (0.1 / 12) * arena_difficulty
	
	# Dont go below 0.7s reduction (max 0.3s spawn time)
	time_off = min(time_off, 0.7)
	
	print("time_off: ", time_off)
	timer.wait_time = base_spawn_time - time_off
	
