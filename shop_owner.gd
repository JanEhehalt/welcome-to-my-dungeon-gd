extends CharacterBody2D

#
# ROOM
#	|- SHOP_ID
#		|- AudioStreamPlayer2D
#		|- shop_area
#		|- MOVEMENT_POINTS
#			|- point1
#			|- point2
#		| - SELLABLES
#			|- sellable1
#			|- sellable2
#	|- ENTITIES
#		|- player
#		|- shop_owner

var die_sound = preload("res://assets/sounds/extinguish.wav")

@export var BASE_MOVEMENT_SPEED = 20.0
var speed = BASE_MOVEMENT_SPEED

var player: CharacterBody2D = null

var shop: Node2D = null
var movement_points: Array[Node] = []
var shop_area: Area2D = null

var movement_target_point: Vector2 = Vector2()

@export var HP_BASE = 5
var hp = HP_BASE 

@export var SHOP_ID = 0

func _ready() -> void:
	for entity in get_parent().get_children():
		if entity.has_method("player"):
			player = entity
			break
	for entity in get_parent().get_parent().get_children():
		if entity.name == "shop_"+str(SHOP_ID):
			shop = entity
	if not shop:
		push_error("shop_" + str(SHOP_ID) + " EXISTIERT NICHT")
	for child in shop.get_children():
		if child.name == "movement_points":
			movement_points = child.get_children()
		if child.name == "shop_area":
			shop_area = child as Area2D
	movement_target_point = position

@export var WAIT_TIME: float = 5
@export var WAIT_TIME_RNG: float = 1

var wait_time_counter = 0

func _process(delta: float) -> void:
	
	if $AnimatedSprite2D.animation == "shop_owner_die":
		$CollisionShape2D.disabled = true
		return
	var movement = Vector2()
	
	
	if player in shop_area.get_overlapping_bodies(): # MOVEMENT FOLLOWING PLAYER
		speed = BASE_MOVEMENT_SPEED * 2
		movement = player.position - position
		if position.distance_to(player.position) < 40:
			if(movement.x < 0):
				manage_flip(true)
			if(movement.x > 0):
				manage_flip(false)
			movement = Vector2()
	else: # MOVEMENT TOWARDS TARGET POINTS
		speed = BASE_MOVEMENT_SPEED
		movement = movement_target_point - position
		if movement_target_point.distance_to(position) < 5:
			wait_time_counter = max(0, wait_time_counter - delta)
			movement = Vector2()
			if wait_time_counter == 0:
				movement_target_point = movement_points.pick_random().position
				wait_time_counter = WAIT_TIME + randf_range(-WAIT_TIME_RNG, WAIT_TIME_RNG)
	
	movement = movement.normalized() * speed
	velocity = movement
	if(movement.x < 0):
		manage_flip(true)
	if(movement.x > 0):
		manage_flip(false)
		
	move_and_slide()
	
	
func manage_flip(flip: bool):
	$AnimatedSprite2D.flip_h = flip

func handle_hit(from_left: bool, dmg: int):
	hp -= dmg
	$AudioStreamPlayer2D.stream = die_sound
	if hp <= 0:
		$AnimatedSprite2D.play_anim("shop_owner_die")
		for sellable in shop.get_node("sellables").get_children():
			sellable.delete()
		$AudioStreamPlayer2D.pitch_scale = 0.4
	else:
		$AudioStreamPlayer2D.pitch_scale = 1.3
		$AnimatedSprite2D.play_anim("shop_owner_hurt")
	$AudioStreamPlayer2D.play()

func set_speed_multiplier(multiplier: float):
	speed = BASE_MOVEMENT_SPEED * multiplier
