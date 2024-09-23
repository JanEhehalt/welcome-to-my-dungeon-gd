extends AudioStreamPlayer2D

#var step_sound_stone_1 = preload("res://assets/sounds/step_stone/stepstone_1.wav")
#var step_sound_stone_2 = preload("res://assets/sounds/step_stone/stepstone_2.wav")
#var step_sound_stone_3 = preload("res://assets/sounds/step_stone/stepstone_3.wav")
#var step_sound_stone_4 = preload("res://assets/sounds/step_stone/stepstone_4.wav")
#var step_sound_stone_5 = preload("res://assets/sounds/step_stone/stepstone_5.wav")
#var step_sound_stone_6 = preload("res://assets/sounds/step_stone/stepstone_6.wav")
#var step_sound_stone_7 = preload("res://assets/sounds/step_stone/stepstone_7.wav")
#var step_sound_stone_8 = preload("res://assets/sounds/step_stone/stepstone_8.wav")

var step_sound_rock = preload("res://assets/sounds/step_rock.wav")

#var step_sounds = [step_sound_stone_1, step_sound_stone_2, step_sound_stone_3, 
				   #step_sound_stone_4, step_sound_stone_5, step_sound_stone_6,
				   #step_sound_stone_7, step_sound_stone_8]
				
var step_sounds = [step_sound_rock]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if the parent is a CharacterBody2D and is moving
	if get_parent() is CharacterBody2D and get_parent().velocity != Vector2.ZERO:
		# Only play a new step sound if the previous one is not playing
		if not playing:
			# Play a random step sound
			var random_index = randi() % len(step_sounds)
			stream = step_sounds[random_index]
			pitch_scale = 1.1
			play()
