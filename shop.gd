extends Node2D

var shop_theme = preload("res://assets/sounds/shop_theme.ogg")

@export var player: CharacterBody2D = null
@export var shop_owner: CharacterBody2D = null

@export var default_db = -20
@export var min_db = -50
@export var db_reduction_per_second = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer2D.stream = shop_theme
	$AudioStreamPlayer2D.volume_db = min_db


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shop_owner.hp <= 0:
		if $AudioStreamPlayer2D.volume_db <= min_db:
			$AudioStreamPlayer2D.stop()
		else:
			$AudioStreamPlayer2D.volume_db -= db_reduction_per_second * delta
		return
	if player in $shop_area.get_overlapping_bodies():
		if $AudioStreamPlayer2D.volume_db <= default_db:
			$AudioStreamPlayer2D.volume_db += db_reduction_per_second * delta
		if not $AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
	else:
		if $AudioStreamPlayer2D.volume_db <= min_db:
			$AudioStreamPlayer2D.stop()
		else:
			$AudioStreamPlayer2D.volume_db -= db_reduction_per_second * delta
