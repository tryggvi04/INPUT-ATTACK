extends Node2D

@onready var failed_sound1 = preload("res://Assets/Sounds/jingle_chime_16_negative.wav")  # Preload the audio file as an AudioStream
@onready var failed_sound2 = preload("res://Assets/Sounds/jingle_chime_18_negative.wav")  # Preload the audio file as an AudioStream
@onready var failed_sound3 = preload("res://Assets/Sounds/jingle_chime_20_negative.wav")  # Preload the audio file as an AudioStream

@onready var success_sound = preload("res://Assets/Sounds/jingle_chime_04_positive.wav")  # Preload the audio file as an AudioStream


var sound_controller

var input_list = [] # keeps our QTE inputs
var attacking = false
var current_position = 0
signal attacking_signal
var slashSpeaker

var keys_UI

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
		handle_attack_input()



func attack():
	get_tree().get_first_node_in_group("turnOptions").visible = false
	keys_UI = get_tree().get_first_node_in_group("KeysUI")
	attacking = true
	attacking_signal.emit()
	input_list.shuffle()
	keysUI()
	current_position = 0  

func keysUI():
	for i in range(len(keys_UI.get_children(true))):
		keys_UI.get_child(i).visible = true
		if (keys_UI.get_child(i).is_in_group("Keys")):
			keys_UI.get_child(i).texture.region = texture_regions[input_list[i]]
			keys_UI.get_child(i).modulate = "ffffff"

func disable_keys():
	var keys_UI = get_tree().get_first_node_in_group("KeysUI")
	for i in range(len(keys_UI.get_children(true))):
		keys_UI.get_child(i).visible = false

# Handle QTE input during the attack
func handle_attack_input():
	# Check if any action in the input list is pressed
	for action in input_list:
		if Input.is_action_just_pressed(action):
			# If the correct action is pressed, advance the QTE sequence
			if action == input_list[current_position]:
				slashSpeaker.play()
				sound_controller.stream = load("res://Assets/Sounds/collect_coin_03.wav")
				sound_controller.play()
				keys_UI.get_child(current_position).modulate = "ffffff73"
				current_position += 1
				# If the sequence is complete, end the attack successfully
				if current_position >= len(input_list):
					end_attack(true)
				else:
					print("Next QTE: ", input_list[current_position])  # Print the next QTE input
			else:
				# If the wrong action is pressed, end the attack as a failure
				end_attack(false)
			return  # Exit after handling the input


func end_attack(success: bool):
	disable_keys()
	attacking = false
	attacking_signal.emit()
	if success:
		print("You did it!")  # Success message
		sound_controller.stream = success_sound
		sound_controller.play()
	else:
		print("You failed!")  # Failure message
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
	get_tree().get_first_node_in_group("turnOptions").visible = true
