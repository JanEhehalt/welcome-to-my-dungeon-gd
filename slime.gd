extends CharacterBody2D

var hit_soft_sound = preload("res://assets/sounds/hit_slime_soft.ogg")
var hit_hard_sound = preload("res://assets/sounds/hit_slime_metal.ogg")

@export var BASE_MOVEMENT_SPEED = 20.0

var speed = BASE_MOVEMENT_SPEED

var player = null

@export var ATTACK_COOLDOWN_BASE = 2
var attack_cooldown = 0

var FLIP_COOLDOWN_BASE = 0.3
var flip_cooldown = 0

@export var HP_BASE = 10
var hp = HP_BASE 

@export var HEAVY_ATTACK_BASE_CHANCE = 0.1
@export var HEAVY_ATTACK_CHANCE_INCREASE_PER_HIT = 0.3
var heavy_attack_chance = HEAVY_ATTACK_BASE_CHANCE

func _ready() -> void:
	for entity in get_parent().get_children():
		if entity.has_method("player"):
			player = entity
			return

var looted = false

		
func _process(delta: float) -> void:
	flip_cooldown = max(0, flip_cooldown - delta)
	attack_cooldown = max(0, attack_cooldown - delta)
	
	if is_path_to_player_blocked():
		return

	if $AnimatedSprite2D.animation == "slime_die":
		$CollisionShape2D.disabled = true
		if $AnimatedSprite2D.frame == 3:
			if not looted:
				looted = true
				var amount = randi_range(1,5)
				if amount == 5:
					spawn_coin(Vector2(), 5)
				else:
					for x in amount:
						spawn_coin(Vector2(randi_range(-5,5), randi_range(-2,2)))

	
	if player not in $AttentionRange.get_overlapping_bodies():
		return
	
	var speed_tmp = speed
	if $AnimatedSprite2D.animation == "slime_walk":
		if $AnimatedSprite2D.frame in [1, 2]:
			speed_tmp *= 1.5
	
	var movement: Vector2 = player.get_node("CollisionShape2D").global_position - $PlayerTargetArea/CollisionShape2D.global_position
	
	if player not in $PlayerTargetArea.get_overlapping_bodies():
		movement = movement.normalized() * speed_tmp
		velocity = movement
		move_and_slide()
		$AnimatedSprite2D.play_anim("slime_walk")
	elif attack_cooldown == 0:
		attack_cooldown = ATTACK_COOLDOWN_BASE
		if randf_range(0, 1) < heavy_attack_chance:
			$AnimatedSprite2D.play_anim("slime_heavy_hit")
			heavy_attack_chance = HEAVY_ATTACK_BASE_CHANCE
		else:
			$AnimatedSprite2D.play_anim("slime_hit")
	
	var flip_vec = player.position - position
	if(flip_vec.x < 0):
		manage_flip(true)
	if(flip_vec.x > 0):
		manage_flip(false)
	

func set_speed_multiplier(multiplier):
	speed = BASE_MOVEMENT_SPEED * multiplier


func hit_other_entities():
	if $AnimatedSprite2D.animation == "slime_hit":
		for entity in $AttackArea.get_overlapping_bodies():
			if entity.has_method("player"):
				entity = entity as CharacterBody2D
				entity.get_hit(1)
	if $AnimatedSprite2D.animation == "slime_heavy_hit":
		for entity in $HeavyAttackArea.get_overlapping_bodies():
			if entity.has_method("player"):
				entity = entity as CharacterBody2D
				entity.get_hit(3)
	

func manage_flip(flip: bool):
	if $AnimatedSprite2D.animation in ["slime_die", "slime_hit"]:
		return 
	if flip != $AnimatedSprite2D.flip_h and flip_cooldown == 0:
		flip_cooldown = FLIP_COOLDOWN_BASE
		$AnimatedSprite2D.flip_h = flip
		$CollisionShape2D.position.x *= -1
		$AttackArea/CollisionShape2D.position.x *= -1
		$HeavyAttackArea/CollisionShape2D.position.x *= -1
		$PlayerTargetArea/CollisionShape2D.position.x *= -1

func handle_player_hit(from_left: bool, dmg: int):
	heavy_attack_chance += HEAVY_ATTACK_CHANCE_INCREASE_PER_HIT
	$AudioStreamPlayer2D.stop()
	if $AnimatedSprite2D.animation == "slime_heavy_hit":
		$AudioStreamPlayer2D.stream = hit_hard_sound
	else:
		$AudioStreamPlayer2D.stream = hit_soft_sound
		hp -= dmg
		if hp <= 0:
			$AnimatedSprite2D.force_play("slime_die")
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play_anim("slime_hurt")

func spawn_coin(offset: Vector2 = Vector2(0, 0), value: int = 1):
	var coin = load("res://coin.tscn") as PackedScene
	var new_coin = coin.instantiate() as CharacterBody2D
	new_coin.value = value
	new_coin.position = position + offset
	new_coin.shadow_visible = false
	get_parent().add_child(new_coin)


func is_path_to_player_blocked():
	var line_start = global_position 
	var line_end = player.global_position

	# 2. Create a PhysicsRayQueryParameters2D object
	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.from = line_start
	ray_params.to = line_end
	#ray_params.collide_with_areas = true 
	ray_params.collision_mask = 1

	# 3. Perform the raycast
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	# 4. Check if the ray hit anything and if it was the "Walls" area
	if result and (result.collider.name == "Walls" or result.collider.name == "DestructibleDoor"):
		return true  # Path is blocked
	else:
		return false  # Path is clear
