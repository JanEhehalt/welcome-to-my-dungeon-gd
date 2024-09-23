extends CharacterBody2D

var hit_soft_sound = preload("res://assets/sounds/hit_slime_soft.ogg")
var hit_hard_sound = preload("res://assets/sounds/hit_slime_metal.ogg")

@export var BASE_MOVEMENT_SPEED = 25.0

var speed = BASE_MOVEMENT_SPEED

var player = null

var ATTACK_COOLDOWN_BASE = 2
var attack_cooldown = 0

var FLIP_COOLDOWN_BASE = 0.3
var flip_cooldown = 0

func _ready() -> void:
	for entity in get_parent().get_children():
		if entity.has_method("player"):
			player = entity
			return

func _process(delta: float) -> void:
	flip_cooldown = max(0, flip_cooldown - delta)
	attack_cooldown = max(0, attack_cooldown - delta)
	
	var speed_tmp = speed
	if $AnimatedSprite2D.animation == "walk":
		if $AnimatedSprite2D.frame in [1, 2]:
			speed_tmp *= 0.5
	
	var movement: Vector2 = player.get_node("CollisionShape2D").global_position - $PlayerTargetArea/CollisionShape2D.global_position
	
	if player not in $PlayerTargetArea.get_overlapping_bodies():
		movement = movement.normalized() * speed_tmp
		velocity = movement
		move_and_slide()
		$AnimatedSprite2D.play_anim("walk")
	elif attack_cooldown == 0:
		attack_cooldown = ATTACK_COOLDOWN_BASE
		if randf_range(0, 1) < 0.2:
			$AnimatedSprite2D.play_anim("heavy_hit")
		else:
			$AnimatedSprite2D.play_anim("hit")
	
	var flip_vec = player.position - position
	if(flip_vec.x < 0):
		manage_flip(true)
	if(flip_vec.x > 0):
		manage_flip(false)

func set_speed_multiplier(multiplier):
	speed = BASE_MOVEMENT_SPEED * multiplier


func hit_other_entities():
	if $AnimatedSprite2D.animation == "hit":
		for entity in $AttackArea.get_overlapping_bodies():
			if entity.has_method("player"):
				entity = entity as CharacterBody2D
				entity.get_hit(1)
	if $AnimatedSprite2D.animation == "heavy_hit":
		for entity in $HeavyAttackArea.get_overlapping_bodies():
			if entity.has_method("player"):
				entity = entity as CharacterBody2D
				entity.get_hit(3)
	

func manage_flip(flip: bool):
	if $AnimatedSprite2D.animation == "hit":
		return 
	if flip != $AnimatedSprite2D.flip_h and flip_cooldown == 0:
		flip_cooldown = FLIP_COOLDOWN_BASE
		$AnimatedSprite2D.flip_h = flip
		$CollisionShape2D.position.x *= -1
		$AttackArea/CollisionShape2D.position.x *= -1
		$HeavyAttackArea/CollisionShape2D.position.x *= -1
		$PlayerTargetArea/CollisionShape2D.position.x *= -1

func handle_player_hit(from_left: bool):
	$AudioStreamPlayer2D.stop()
	if $AnimatedSprite2D.animation == "heavy_hit":
		$AudioStreamPlayer2D.stream = hit_hard_sound
	else:
		$AudioStreamPlayer2D.stream = hit_soft_sound
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play_anim("hurt")
