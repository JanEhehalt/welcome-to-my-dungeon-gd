extends Node2D

var buy_sound = preload("res://assets/sounds/woosh.ogg")

@export var texture: Texture2D
@export var price: int

@export var restock: bool = false

var tool_tip_right_x = 0
var tool_tip_left_x = 0

@export var player: CharacterBody2D = null
@export var shop_owner: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = texture
	$ToolTip/AnimatedSprite2D.animation = "KEYBOARD_E"
	tool_tip_right_x = $ToolTip.position.x
	tool_tip_left_x = tool_tip_right_x * -1
	$PriceTag2D.animation = str(price)
	$AnimatedSprite2D.animation_finished.connect(_handle_animation_finished)
	$AnimatedSprite2D.visible = false
	$Restock.visible = restock

var buy_cooldown = 0
var BUY_COOLDOWN_BASE = 0.25

var removing = false
var remove_animation_finished = false

func _handle_animation_finished():
	remove_animation_finished = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	buy_cooldown = max(0, buy_cooldown - delta)
	if not restock and removing and remove_animation_finished:
		get_parent().remove_child(self)
		return
	if removing and not remove_animation_finished:
		return
	if restock and removing and remove_animation_finished:
		removing = false
		remove_animation_finished = false
		$Sprite2D.visible = true
		$AnimatedSprite2D.visible = false
	$ToolTip.visible = false
	
	for object in $SellableArea.get_overlapping_bodies():
		if object.has_method("player"):
			$ToolTip.visible = true
			if object.global_position.x <= self.global_position.x:
				$ToolTip.position.x = tool_tip_right_x
			else:
				$ToolTip.position.x = tool_tip_left_x
	if $ToolTip.visible:
		if Input.is_key_pressed(KEY_E):
			if player.coin_counter >= price and buy_cooldown == 0:
				buy_cooldown = BUY_COOLDOWN_BASE
				handle_sold_item()
				remove()

func remove():
	removing = true
	$Sprite2D.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.stream = buy_sound
	$AudioStreamPlayer2D.play()

func delete():
	$AudioStreamPlayer2D.volume_db -= 25
	restock = false
	remove()
	
func handle_sold_item():
	player.coin_counter -= price
	if "key" in texture.resource_path:
		player.pick_up_key()
	if "big_potion" in texture.resource_path:
		player.hp += 3
	if "small_potion" in texture.resource_path:
		player.hp += 1
	if "bomb" in texture.resource_path:
		player.pick_up_bomb()
