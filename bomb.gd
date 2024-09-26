extends Node2D

var explosion_sound = preload("res://assets/sounds/bomb_explosion.ogg")
var place_sound = preload("res://assets/sounds/place_bomb.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.animation_finished.connect(_handle_finished_animation)
	$AnimatedSprite2D.frame_changed.connect(_handle_frame_changed)
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.stream = place_sound
	$AudioStreamPlayer2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _handle_finished_animation():
	get_parent().remove_child(self)
	
func _handle_frame_changed():
	if $AnimatedSprite2D.frame == 11:
		$AudioStreamPlayer2D.stop()
		$AudioStreamPlayer2D.stream = explosion_sound
		$AudioStreamPlayer2D.play()
		for entity in $Area2D.get_overlapping_bodies():
			if entity.has_method("handle_hit"):
				var from_left = position.x < entity.position.x
				entity.handle_hit(from_left, 1)
		
