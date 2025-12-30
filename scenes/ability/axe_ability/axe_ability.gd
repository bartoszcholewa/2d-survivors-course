extends Node2D

## Axe rotation radius from player
const AXE_ANIMATION_MAX_RADIUS = 100.0

## Number of axe rotations around player in tween animation
const AXE_ANIMATION_ROTATIONS := 2.0

## Time in seconds for full axe animation
const AXE_ANIMATION_DURATION := 3.0

@onready var hitbox_component = $HitboxComponent

var base_rotation = Vector2.RIGHT

## Tween singleton
var tween := create_tween()

func _ready() -> void:
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	reset_tween()
	tween.tween_method(tween_method, 0.0, AXE_ANIMATION_ROTATIONS, AXE_ANIMATION_DURATION)
	tween.tween_callback(queue_free)
	
	
# TODO: rename method
func tween_method(rotations: float) -> void:
	var percent := rotations / 2
	var current_radius := percent * AXE_ANIMATION_MAX_RADIUS
	var current_direction := base_rotation.rotated(rotations * TAU)
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
		
	global_position = player.global_position + (current_direction * current_radius)
	
	

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
