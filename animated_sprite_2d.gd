extends AnimatedSprite2D


var animation_informations = {
	"hit": AnimationInformation.new("hit", true, false, "idle", 0.5),
	"idle": AnimationInformation.new("idle", false, true, "idle", 1),
	"walk": AnimationInformation.new("walk", false, true, "idle", 1),
	"die": AnimationInformation.new("die", true, false, "idle", 0),
	"hurt": AnimationInformation.new("hurt", true, false, "idle", 0.8),
	"heavy_hit": AnimationInformation.new("heavy_hit", true, false, "idle", 0.2)
}

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	frame_changed.connect(_on_frame_change)

func _process(delta: float) -> void:
	pass

func _on_frame_change():
	if animation == "hit" and frame == 3:
		get_parent().hit_other_entities()
	if animation == "heavy_hit" and frame == 8:
		get_parent().hit_other_entities()

func _on_animation_finished():
	if animation_informations[animation].play_once:
		force_play(animation_informations[animation].fallback)

func play_anim(to_anim: String) -> void:
	if to_anim == "hurt" and animation != "heavy_hit":
		play(to_anim)
		get_parent().set_speed_multiplier(animation_informations[animation].speed_prc)
	if to_anim not in animation_informations:
		push_error("animation_information for " + to_anim + "not declared")
	if to_anim == animation:
		return
	if animation_informations[animation].breakable:
		play(to_anim)
		get_parent().set_speed_multiplier(animation_informations[animation].speed_prc)

func force_play(to_anim: String) -> void:
	if to_anim not in animation_informations:
		push_error("animation_information for " + to_anim + "not declared")
	play(to_anim)
	get_parent().set_speed_multiplier(animation_informations[animation].speed_prc)
	
