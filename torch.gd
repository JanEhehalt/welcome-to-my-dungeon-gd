extends StaticBody2D

var extinguish_sound = preload("res://assets/sounds/extinguish.wav")
var burning_sound = preload("res://assets/sounds/torchBurning.ogg")
var hit_metal_sound = preload("res://assets/sounds/hitMetal.ogg")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AudioStreamPlayer2D.stream = burning_sound
	$AudioStreamPlayer2D.play()
	
func _on_frame_changed():
	if $AnimatedSprite2D.animation == "fall":
		if $AnimatedSprite2D.frame == 2:
			$AudioStreamPlayer2D.stop()
			$AudioStreamPlayer2D.stream = extinguish_sound
			$AudioStreamPlayer2D.play()
			

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "fall" or $AnimatedSprite2D.animation == "extinguish":
		$PointLight2D.enabled = false

var flicker_speed = 1.5
var base_intensity = 1.2
var flicker_intensity = 0.8
var base_size = 1.5 
var flicker_size = 0.8

func _process(delta: float) -> void:
	var new_intensity = base_intensity + randf_range(-flicker_intensity, flicker_intensity)
	$PointLight2D.energy = lerp($PointLight2D.energy, new_intensity, delta * flicker_speed) 
	
	var new_size = base_size + randf_range(-flicker_size, flicker_size)
	$PointLight2D.texture_scale = lerp($PointLight2D.texture_scale, new_size, delta * flicker_speed)
	
	if $AnimatedSprite2D.animation == "shake":
		if $AnimatedSprite2D.frame == 3:
			$AnimatedSprite2D.animation = "burn"
	if $AnimatedSprite2D.animation == "fall" or $AnimatedSprite2D.animation == "extinguish":
		match $AnimatedSprite2D.frame:
			1: $PointLight2D.energy = 0.66
			2: $PointLight2D.energy = 0.33

var hit_counter = 0

func handle_player_hit(from_left: bool, dmg: int):
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.stream = hit_metal_sound
	$AudioStreamPlayer2D.play()
	if hit_counter == 2:
		fall(from_left)
	else:
		hit_counter += 1
		$AnimatedSprite2D.animation = "shake"
		$AnimatedSprite2D.frame = 0

func fall(from_left: bool):
	if $AnimatedSprite2D.animation == "fall":
		return
	if from_left:
		$AnimatedSprite2D.flip_h = true
		$StandingCollisionShape.position.x *= -1
		$FallenCollisionShape.position.x *= -1
		$AnimatedSprite2D.position.x *= -1
	$StandingCollisionShape.disabled = true
	$FallenCollisionShape.disabled = false
	$AnimatedSprite2D.play("fall")
	
	

func extinguish():
	$AnimatedSprite2D.play("extinguish")

func burn():
	$AnimatedSprite2D.play("burn")

func enflame():
	$AnimatedSprite2D.play_backwards("extinguish")
