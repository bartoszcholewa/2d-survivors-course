extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10
var current_health: float

func _ready() -> void:
	current_health = max_health

func damage(amount: float):
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit()
	
	if amount > 0:
		health_decreased.emit()
	
	# Fix for:
	# vial_drop_component.gd:20 @ on_died(): Can't change this state while flushing queries. Use call_deferred() or set_deferred() to change monitoring state instead.
	Callable(check_death).call_deferred()

func heal(amount: int):
	damage(-amount)
	

func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)

func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
