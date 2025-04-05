extends Node2D

signal health_changed
var max_health = 100
var health = 100

var key_image

var damage = 5


var texture_regions = {
	"UP": Rect2i(1.0, 2, 13, 12),       # Region for QTE_1
	"DOWN": Rect2i(17, 2, 13, 12),      # Region for QTE_W
	"LEFT": Rect2i(33, 2, 13, 12),     # Region for QTE_Q
	"RIGHT": Rect2i(49, 2, 13, 12)      # Region for QTE_E
}


func _ready() -> void:
	health = max_health
	health_changed.emit()
	
	key_image = %key_image
	
	new_attack()
	
func take_damage(damage: float):
	health -= damage
	health_changed.emit()
	
func new_attack():
	var rng = RandomNumberGenerator.new()
	var num = rng.randi_range(0, 3)
	
	var attack_direction
	
	match  num:
		0:
			attack_direction = "UP"
		1:
			attack_direction = "RIGHT"
		2:
			attack_direction = "LEFT"
		3:
			attack_direction = "DOWN"
	key_image.texture.region = texture_regions[attack_direction]
	%damage_num.text = str(damage)
			
