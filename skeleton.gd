extends CharacterBody2D



@export var BASE_MOVEMENT_SPEED = 20.0

var speed = BASE_MOVEMENT_SPEED

var player = null

@export var ATTACK_COOLDOWN_BASE = 2.5
var attack_cooldown = 0

var FLIP_COOLDOWN_BASE = 0.3
var flip_cooldown = 0

@export var HP_BASE = 5
var hp = HP_BASE 


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

	if $AnimatedSprite2D.animation == "skeleton_die":
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
	if is_path_to_player_blocked():
		return
	
	var movement: Vector2 = player.get_node("CollisionShape2D").global_position - global_position
	
	var player_in_outer_target_area = player in $OuterPlayerTargetArea.get_overlapping_bodies()
	var player_in_inner_target_area = player in $InnerPlayerTargetArea.get_overlapping_bodies()
	var wall_in_panic_area = false
	var player_in_panic_area = false
	for body in $PanicArea.get_overlapping_bodies():
		if body.name == "Walls":
			wall_in_panic_area = true
		if body == player:
			player_in_panic_area = true

	if player in $AttentionRange.get_overlapping_bodies():
		if attack_cooldown == 0:
			attack_cooldown = ATTACK_COOLDOWN_BASE
			$AnimatedSprite2D.play_anim("skeleton_hit")
	if player_in_outer_target_area:
		if player_in_inner_target_area:
			movement *= -1
			if player_in_panic_area:
				if player.global_position.y >= global_position.y:
					movement = movement.rotated(-PI/2)
				else:
					movement = movement.rotated(PI/2)
		else:
			movement *= 0
	
	velocity = movement.normalized() * speed
	
	var flip_vec = player.position - position
	if(flip_vec.x < 0):
		manage_flip(true)
	if(flip_vec.x > 0):
		manage_flip(false)
	move_and_slide()

func set_speed_multiplier(multiplier):
	speed = BASE_MOVEMENT_SPEED * multiplier


func hit_other_entities():
	var arrow = load("res://arrow.tscn") as PackedScene
	var new_arrow = arrow.instantiate() as CharacterBody2D
	var direction: Vector2 = player.get_node("CollisionShape2D").global_position - global_position
	direction = direction.rotated(get_random_angle_in_radians(-10, 10))
	new_arrow.direction = direction
	new_arrow.apply_scale(Vector2(0.6, 0.6))
	new_arrow.position = position
	get_parent().add_child(new_arrow)

func get_random_angle_in_radians(from: int, to: int):
	var min_radians = deg_to_rad(from)
	var max_radians = deg_to_rad(to)
	var random_value = randf()
	var random_angle_in_radians = min_radians + random_value * (max_radians - min_radians)
	return random_angle_in_radians

func manage_flip(flip: bool):
	if $AnimatedSprite2D.animation in ["skeleton_die", "skeleton_hit"]:
		return 
	if flip != $AnimatedSprite2D.flip_h and flip_cooldown == 0:
		flip_cooldown = FLIP_COOLDOWN_BASE
		$AnimatedSprite2D.flip_h = flip
		$CollisionShape2D.position.x *= -1

func handle_hit(from_left: bool, dmg: int):
	$AudioStreamPlayer2D.stop()
	#$AudioStreamPlayer2D.stream = hit_soft_sound
	hp -= dmg
	if hp <= 0:
		$AnimatedSprite2D.force_play("skeleton_die")
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play_anim("skeleton_hurt")

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
	ray_params.collision_mask = 2

	# 3. Perform the raycast
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	# 4. Check if the ray hit anything and if it was the "Walls" area
	if result and (result.collider.name == "Walls" or result.collider.name == "DestructibleDoor"):
		return true  # Path is blocked
	else:
		return false  # Path is clear
