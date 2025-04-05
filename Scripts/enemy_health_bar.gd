extends TextureProgressBar

@onready var enemy = get_parent()

func _ready():
	enemy.health_changed.connect(update)
	update()
	
func update():
	value = enemy.health * 100 / enemy.max_health
