## Manages the spawning of basic enemies around the player's position.
##
## This script finds the player in the "player" group and periodically
## spawns a new enemy instance at a fixed radius in a random direction.
extends Node

## The scene to be instantiated when spawning an enemy.
@export var basic_enemy_scene: PackedScene

## Distance from the player where enemies will be spawned.
const SPAWN_RADIUS: float = 375.0

## Cached reference to the player node.
var player: Node2D


func _ready() -> void:
	_initialize_player_reference()
	_connect_signals()


## Finds the player node and validates its existence.
func _initialize_player_reference() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	
	# Development-time check
	assert(player != null, "EnemySpawner: Player node not found! Ensure Player is in 'player' group.")


## Connects internal or external signals.
func _connect_signals() -> void:
	var timer: Timer = $Timer
	assert(timer != null, "EnemySpawner: Timer node not found as a child!")
	timer.timeout.connect(_on_timer_timeout)


## Callback triggered by the Timer to spawn a new enemy.
func _on_timer_timeout() -> void:
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
	get_parent().add_child(enemy)
	enemy.global_position = spawn_position
	
