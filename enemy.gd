extends Node2D

signal health_changed
var max_health = 100
var health = 100

func _ready() -> void:
	health = max_health
	health_changed.emit()
	
func take_damage(damage: float):
	health -= damage
	health_changed.emit()
