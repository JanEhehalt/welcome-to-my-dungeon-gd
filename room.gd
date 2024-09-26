extends Node2D

@export var knock_left_torch: StaticBody2D
@export var knock_right_torch: StaticBody2D

@export var shop_area: Area2D

@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if knock_left_torch.fell and knock_left_torch.fell_left:
		if player in shop_area.get_overlapping_bodies():
			player.get_node("HUD/locked").visible = true
			player.get_node("HUD/locked_rect").visible = true
	if knock_right_torch.fell and !knock_right_torch.fell_left:
		if player in shop_area.get_overlapping_bodies():
			player.get_node("HUD/locked").visible = true
			player.get_node("HUD/locked_rect").visible = true
