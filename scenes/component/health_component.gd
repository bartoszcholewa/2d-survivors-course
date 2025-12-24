extends Node
class_name HealthComponent

signal died

@export var max_health: float = 10
var current_health: float

func _ready() -> void:
	current_health = max_health

func damage(amount: float):
	current_health = max(current_health - amount, 0)
	
	# Fix for:
	# vial_drop_component.gd:20 @ on_died(): Can't change this state while flushing queries. Use call_deferred() or set_deferred() to change monitoring state instead.
	Callable(check_death).call_deferred()


func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
