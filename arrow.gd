extends CharacterBody2D


@export var speed = 200.0

@export var dmg = 1

var direction: Vector2

var player: CharacterBody2D

func _ready() -> void:
	for entity in get_parent().get_children():
		if entity.has_method("player"):
			player = entity as CharacterBody2D

func _physics_process(delta: float) -> void:
	
	if player in $damage_area.get_overlapping_bodies():
		var from_left = global_position.x < player.global_position.x 
		player.handle_hit(from_left, dmg)
		get_parent().remove_child(self)
		return
	
	
	for entity in $damage_area.get_overlapping_bodies():
		if entity.name == "Walls" or "DestructibleDoor" in entity.name:
			get_parent().remove_child(self)
			return
		
	
	rotation = direction.angle()
	velocity = direction.normalized() * speed
	move_and_slide()
