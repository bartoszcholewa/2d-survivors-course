extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene
@export var level_up_scene: PackedScene

@onready var card_container: HBoxContainer = $%CardContainer
@onready var level_up_container: HBoxContainer = $%LevelUpContainer

var level_up_instance: Node


func _ready() -> void:
	level_up_instance = level_up_scene.instantiate()
	get_tree().paused = true

func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):

	level_up_container.add_child(level_up_instance)
	level_up_instance.play_in()
	await get_tree().create_timer(0.3).timeout

	var delay: float = 0.0
	for upgrade in upgrades:
		var card_instance: Node = upgrade_card_scene.instantiate()
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += 0.1
		
		
func on_upgrade_selected(upgrade: AbilityUpgrade):
	level_up_instance.play_out()
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
