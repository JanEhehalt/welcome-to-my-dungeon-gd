extends Node2D

@export var texture: Texture2D
@export var price: int

@export var restock: bool = false

var tool_tip_right_x = 0
var tool_tip_left_x = 0

@export var player: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = texture
	$ToolTip/AnimatedSprite2D.animation = "KEYBOARD_E"
	tool_tip_right_x = $ToolTip.position.x
	tool_tip_left_x = tool_tip_right_x * -1
	$PriceTag2D.animation = str(price)

var buy_cooldown = 0
var BUY_COOLDOWN_BASE = 0.25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	buy_cooldown = max(0, buy_cooldown - delta)
	if not visible:
		return
	$ToolTip.visible = false
	for object in $SellableArea.get_overlapping_bodies():
		if object.has_method("player"):
			$ToolTip.visible = true
			if object.position.x < position.x:
				$ToolTip.position.x = tool_tip_right_x
			else:
				$ToolTip.position.x = tool_tip_left_x
	if $ToolTip.visible:
		if Input.is_key_pressed(KEY_E):
			if player.coin_counter >= price and buy_cooldown == 0:
				buy_cooldown = BUY_COOLDOWN_BASE
				handle_sold_item()
				if not restock:
					visible = false

func handle_sold_item():
	player.coin_counter -= price
	if "key" in texture.resource_path:
		player.pick_up_key()
	if "big_potion" in texture.resource_path:
		player.hp += 5
	if "small_potion" in texture.resource_path:
		player.hp += 3
