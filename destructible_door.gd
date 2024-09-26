extends StaticBody2D

var tool_tip_right_x = 0
var tool_tip_left_x = 0

var hit_sound_1 = preload("res://assets/sounds/hit_chest_1.ogg")
var hit_sound_2 = preload("res://assets/sounds/hit_chest_2.ogg")
var hit_sound_3 = preload("res://assets/sounds/hit_chest_3.ogg")

var open_sound = preload("res://assets/sounds/open_chest.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = destruction_state
	tool_tip_right_x = $ToolTip.position.x
	tool_tip_left_x = tool_tip_right_x * -1
	$ToolTip/AnimatedSprite2D.animation = "KEYBOARD_E"

@export var destruction_state = 0

@export var open = false

var cooldown = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown = max(0, cooldown - delta)
	if open:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
	if open and destruction_state == 3:
		$ToolTip.visible = false
		$AnimatedSprite2D.frame = 3
		return
	$AnimatedSprite2D.frame = 3
	if not open:
		$AnimatedSprite2D.frame = destruction_state
	
	$ToolTip.visible = false
	
	if cooldown == 0:
		for object in $InteractionArea.get_overlapping_bodies():
			if object.has_method("player"):
				$ToolTip.visible = true
				if object.position.x < position.x:
					$ToolTip.position.x = tool_tip_right_x
				else:
					$ToolTip.position.x = tool_tip_left_x
	
	if $ToolTip.visible:
		if Input.is_key_pressed(KEY_E):
			if cooldown == 0:
				open = not open
				cooldown = 0.3
				$AudioStreamPlayer2D.stream = open_sound
				$AudioStreamPlayer2D.play()

func handle_hit(from_left: bool, dmg: int):
	if destruction_state == 3 or open:
		return
	destruction_state += 1
	match $AnimatedSprite2D.frame:
		0: $AudioStreamPlayer2D.stream = hit_sound_1
		1: $AudioStreamPlayer2D.stream = hit_sound_2
		2: $AudioStreamPlayer2D.stream = hit_sound_3
	$AudioStreamPlayer2D.play()
	if destruction_state == 3:
		open = true
