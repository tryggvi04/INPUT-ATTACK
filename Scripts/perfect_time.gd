extends TextureProgressBar

var controller: Node2D = null
func _process(delta: float) -> void:
	if controller != null:
		value = controller.perfect_time * 100 / controller.base_perfect_time
