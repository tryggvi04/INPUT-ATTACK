extends Node2D

@onready var failed_sound1 = preload("res://Assets/Sounds/jingle_chime_16_negative.wav")  # Preload the audio file as an AudioStream
@onready var failed_sound2 = preload("res://Assets/Sounds/jingle_chime_18_negative.wav")  # Preload the audio file as an AudioStream
@onready var failed_sound3 = preload("res://Assets/Sounds/jingle_chime_20_negative.wav")  # Preload the audio file as an AudioStream

@onready var success_sound = preload("res://Assets/Sounds/jingle_chime_04_positive.wav")  # Preload the audio file as an AudioStream

var base_block = 1
var perfect_time_block = 3

var sound_controller

var input_list = [] # keeps our QTE inputs
var randomized_inputs = []
var attacking = false
var current_position = 0
signal attacking_signal
var slashSpeaker

var keys_UI

var base_perfect_time = 1
var perfect_time = 1

var block_list = {
	"KEY_UP": 0,   
	"KEY_DOWN": 0,     
	"KEY_LEFT": 0,   
	"KEY_RIGHT": 0   
}
var texture_regions = {
	"KEY_UP": Rect2i(1.0, 2, 13, 12),       # Region for QTE_1
	"KEY_DOWN": Rect2i(17, 2, 13, 12),      # Region for QTE_W
	"KEY_LEFT": Rect2i(33, 2, 13, 12),     # Region for QTE_Q
	"KEY_RIGHT": Rect2i(49, 2, 13, 12)      # Region for QTE_E
}

func _ready() -> void:
	slashSpeaker = get_tree().get_first_node_in_group("SlashSpeaker")
	sound_controller = get_tree().get_first_node_in_group("sound_player")
	
	input_list.append("KEY_UP")
	input_list.append("KEY_DOWN")
	input_list.append("KEY_LEFT")
	input_list.append("KEY_RIGHT")
	

func _process(delta: float) -> void:
	if attacking:
		handle_block_inputs()
		perfect_time -= delta
		
		if (perfect_time < -0.05):
			get_tree().get_first_node_in_group("perfect_time_UI").visible = false



func block():
	get_tree().get_first_node_in_group("perfect_time_UI").get_child(0).controller = self
	get_tree().get_first_node_in_group("perfect_time_UI").visible = true
	get_tree().get_first_node_in_group("turnOptions").visible = false
	keys_UI = get_tree().get_first_node_in_group("KeysUI")
	attacking = true
	attacking_signal.emit()
	randomized_inputs = shuffle_inputs(input_list)
	keysUI()
	current_position = 0  

func shuffle_inputs(list: Array):
	var return_list = []
	var rng = RandomNumberGenerator.new()
	for i in range(len(list)):
		var num = rng.randi_range(0, 100)
		if num <= 25:
			return_list.append(input_list[0])
		elif num <= 50:
			return_list.append(input_list[1])
		elif num <= 75:
			return_list.append(input_list[2])
		elif num <= 100:
			return_list.append(input_list[3])
	print(return_list)
	return return_list
	

func keysUI():
	for i in range(len(keys_UI.get_children(true))):
		keys_UI.get_child(i).visible = true
		if (keys_UI.get_child(i).is_in_group("Keys")):
			keys_UI.get_child(i).texture.region = texture_regions[randomized_inputs[i]]
			keys_UI.get_child(i).modulate = "ffffff"

func disable_keys():
	var keys_UI = get_tree().get_first_node_in_group("KeysUI")
	for i in range(len(keys_UI.get_children(true))):
		keys_UI.get_child(i).visible = false

# Handle QTE input during the attack
func handle_block_inputs():
	# Check if any action in the input list is pressed
	for action in input_list:
		if Input.is_action_just_pressed(action):
			
			# If the correct action is pressed, advance the QTE sequence
			if action == randomized_inputs[current_position]:
				if (abs(perfect_time) <= 0.05):
					block_list[action] += perfect_time_block
					sound_controller.stream = load("res://Assets/Sounds/collect_coin_03.wav")
					sound_controller.play()
				else:
					block_list[action] += base_block
				
				slashSpeaker.play()
				keys_UI.get_child(current_position).modulate = "ffffff73"
				current_position += 1
				# If the sequence is complete, end the attack successfully
			else:
				keys_UI.get_child(current_position).modulate = "ffffff73"
				current_position += 1
				# If the wrong action is pressed, end the attack as a failure
				var rng = RandomNumberGenerator.new()
				var my_random_number = rng.randi_range(1, 3)
				
				match my_random_number:
					1:
						sound_controller.stream = failed_sound1
					2:
						sound_controller.stream = failed_sound2
					3:
						sound_controller.stream = failed_sound3
				sound_controller.play()
			if current_position >= len(randomized_inputs):
				end_block(true)
			else:
				print("Next QTE: ", randomized_inputs[current_position])  # Print the next QTE input
				get_tree().get_first_node_in_group("perfect_time_UI").visible = true
			
			perfect_time = base_perfect_time


func end_block(success: bool):
	get_tree().get_first_node_in_group("perfect_time_UI").visible = false
	disable_keys()
	attacking = false
	attacking_signal.emit()
	get_tree().get_first_node_in_group("turnOptions").visible = true
	randomized_inputs = []
	print(block_list)
