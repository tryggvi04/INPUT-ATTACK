extends TextureProgressBar

var controller

func _ready() -> void:
	controller = get_tree().get_first_node_in_group("attackController")

func _process(delta: float) -> void:
	value = controller.perfect_time * 100 / controller.base_perfect_time
