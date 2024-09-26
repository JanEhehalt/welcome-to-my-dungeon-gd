extends CharacterBody2D

@export var BASE_MOVEMENT_SPEED = 100

var swing_sound_1 = preload("res://assets/sounds/swing.wav")
var swing_sound_2 = preload("res://assets/sounds/swing2.wav")
var swing_sound_3 = preload("res://assets/sounds/swing3.wav")

@export var BASE_DMG = 2
var dmg = BASE_DMG

@export var BASE_HP = 10
var hp = BASE_HP

var speed: float = 0


func player():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_speed_multiplier(1)

func set_speed_multiplier(multiplier):
	speed = BASE_MOVEMENT_SPEED * multiplier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hp = min(BASE_HP, hp)
	hp = max(hp, 0)
	$HUD/hp_bar.frame = int(hp)
	$HUD/coin_amount.text = str(coin_counter)
	$HUD/key_amount.text = str(key_counter)
	$HUD/bomb_amount.text = str(bomb_counter)
	bomb_countdown = max(0, bomb_countdown - delta)
	
	var movement = Vector2(0, 0)
	movement.x = Input.get_axis("move_left", "move_right")
	movement.y = Input.get_axis("move_up", "move_down")
	velocity = movement.normalized() * speed
	
	if(movement.x < 0):
		manage_flip(true)
	if(movement.x > 0):
		manage_flip(false)
	
	if movement.length() > 0:
		$AnimatedSprite2D.play_anim("player_walk")
	else:
		$AnimatedSprite2D.play_anim("player_idle")
	if Input.is_key_pressed(KEY_SPACE):
		if $AnimatedSprite2D.animation != "player_hit":
			$AnimatedSprite2D.play_anim("player_hit")
			if $AnimatedSprite2D.animation == "player_hit":
				$AudioStreamPlayer2D.stop()
				match randi()%3:
					0: $AudioStreamPlayer2D.stream = swing_sound_1
					1: $AudioStreamPlayer2D.stream = swing_sound_2
					2: $AudioStreamPlayer2D.stream = swing_sound_3
				$AudioStreamPlayer2D.play()
	if Input.is_key_pressed(KEY_Q):
		place_bomb()

func manage_flip(flip: bool):
	if $AnimatedSprite2D.animation == "player_hit" or Input.is_key_pressed(KEY_SPACE):
		return
	if flip != $AnimatedSprite2D.flip_h:
		$AnimatedSprite2D.flip_h = flip
		$CollisionShape2D.position.x *= -1
		$SwordArea/CollisionShape2D.position.x *= -1

func hit_other_entities():
	for object in $SwordArea.get_overlapping_bodies():
		if object.has_method("handle_hit"):
			if position.x <= object.position.x:
				object.handle_hit(true, dmg)
			else:
				object.handle_hit(false, dmg)

@export var coin_counter: int = 0
@export var key_counter: int = 0
@export var bomb_counter: int = 0

func pick_up_coin(value: int):
	coin_counter += value

func pick_up_key():
	key_counter += 1

func pick_up_bomb():
	bomb_counter += 1
	
var bomb_countdown = 0
func place_bomb():
	if bomb_countdown == 0 and bomb_counter > 0:
		bomb_countdown = 0.5
		bomb_counter -= 1
		var bomb = load("res://bomb.tscn") as PackedScene
		var new_bomb = bomb.instantiate() as Node2D
		var offset = Vector2()
		if velocity.y > 0:
			offset.y = -5
		else:
			offset.y = 5
		new_bomb.position = position + offset
		get_parent().add_child(new_bomb)

func _physics_process(delta: float) -> void:
	move_and_slide()
	
func handle_hit(from_left: bool, dmg: int):
	hp -= dmg
	$AnimatedSprite2D.play_anim("player_hurt")
