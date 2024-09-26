extends StaticBody2D

var hit_wood_sound = preload("res://assets/sounds/hitWood.ogg")
var hit_chest_sound_1 = preload("res://assets/sounds/hit_chest_1.ogg")
var hit_chest_sound_2 = preload("res://assets/sounds/hit_chest_2.ogg")
var hit_chest_sound_3 = preload("res://assets/sounds/hit_chest_3.ogg")

var open_chest = preload("res://assets/sounds/open_chest.ogg")

var tool_tip_right_x = 0
var tool_tip_left_x = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.pause()
	$ToolTip/AnimatedSprite2D.animation = "KEYBOARD_E"
	tool_tip_right_x = $ToolTip.position.x
	tool_tip_left_x = tool_tip_right_x * -1

func handle_hit(from_left: bool, dmg: int):
	$AudioStreamPlayer2D.stop()
	match $AnimatedSprite2D.frame:
		0: $AudioStreamPlayer2D.stream = hit_chest_sound_1
		1: $AudioStreamPlayer2D.stream = hit_chest_sound_2
		2: $AudioStreamPlayer2D.stream = hit_chest_sound_3
		3: $AudioStreamPlayer2D.stream = hit_wood_sound
	$AudioStreamPlayer2D.play()
	
	if $AnimatedSprite2D.animation != "break":
		$AnimatedSprite2D.animation = "break"
	if $AnimatedSprite2D.frame < 3:
		$AnimatedSprite2D.frame += 1
		if $AnimatedSprite2D.frame == 3:
			spawn_coin()

var looted = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ToolTip.visible = false
	for object in $InteractionArea.get_overlapping_bodies():
		if object.has_method("player"):
			if $AnimatedSprite2D.animation == "shut":
				$ToolTip.visible = true
				if object.position.x < position.x:
					$ToolTip.position.x = tool_tip_right_x
				else:
					$ToolTip.position.x = tool_tip_left_x
	if $ToolTip.visible:
		if Input.is_key_pressed(KEY_E):
			$AudioStreamPlayer2D.stop()
			$AudioStreamPlayer2D.stream = open_chest
			$AudioStreamPlayer2D.play()
			$AnimatedSprite2D.animation = "open"
			spawn_coin()

func spawn_coin():
	if not looted:
		looted = true
		var coin = load("res://coin.tscn") as PackedScene
		var new_coin = coin.instantiate() as CharacterBody2D
		new_coin.value = 5
		new_coin.position = position
		new_coin.shadow_visible = false
		get_parent().add_child(new_coin)
	
