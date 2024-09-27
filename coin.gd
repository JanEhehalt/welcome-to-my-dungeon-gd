extends CharacterBody2D

@export var attractionSpeed = 150

@export var disabled = false

@export var shadow_visible = true

@export var value = 1

var pickup_coin_sound = preload("res://assets/pickup_coin.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = str(value)
	$AudioStreamPlayer2D.finished.connect(_handle_sound_finish)
	if value == 1:
		$Shadow.apply_scale(Vector2(0.6, 0.6))


@export var i_secs = 0.7
var timer = 0

var start_rng = randi_range(1, 5)

func hover():
	$AnimatedSprite2D.position.y += cos(start_rng + timer*5) * 0.2

var finished_playing = false

func _handle_sound_finish():
	finished_playing = true

func _process(delta: float) -> void:
	if disabled and finished_playing:
		get_parent().remove_child(self)
		return
	if disabled:
		visible = false
		return
	if not shadow_visible:
		$Shadow.visible = false
	timer += delta
	hover()
	if timer < i_secs:
		return
	if timer > 10000:
		timer -= 9000
	for object in $PìckupArea.get_overlapping_bodies():
		if object.has_method("player"):
			object.pick_up_coin(value)
			disabled = true
			$AudioStreamPlayer2D.pitch_scale = 2/value
			$AudioStreamPlayer2D.stream = pickup_coin_sound
			$AudioStreamPlayer2D.play()
			return
	for object in $AttractionArea.get_overlapping_bodies():
		if object.has_method("player"):
			var direction: Vector2 = object.global_position - global_position - Vector2(0, -5)
			direction = direction.normalized() * attractionSpeed
			velocity = direction
	move_and_slide()
