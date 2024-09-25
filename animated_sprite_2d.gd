extends AnimatedSprite2D


var animation_informations = {
	"player_hit": AnimationInformation.new("player_hit", true, false, "player_idle", 0.5),
	"player_idle": AnimationInformation.new("player_idle", false, true, "player_idle", 1),
	"player_walk": AnimationInformation.new("player_walk", false, true, "player_idle", 1),
	"player_die": AnimationInformation.new("player_die", true, false, "player_die", 0),
	"player_hurt": AnimationInformation.new("player_hurt", true, false, "player_idle", 0.8),
	
	"slime_hit": AnimationInformation.new("slime_hit", true, false, "slime_idle", 0.5),
	"slime_idle": AnimationInformation.new("slime_idle", false, true, "slime_idle", 1),
	"slime_walk": AnimationInformation.new("slime_walk", false, true, "slime_idle", 1),
	"slime_die": AnimationInformation.new("slime_die", true, false, "slime_die", 0),
	"slime_hurt": AnimationInformation.new("slime_hurt", true, false, "slime_idle", 0.8),
	"slime_heavy_hit": AnimationInformation.new("slime_heavy_hit", true, false, "slime_idle", 0.2),
	
	"shop_owner_idle": AnimationInformation.new("shop_owner_idle", false, true, "shop_owner_idle", 1),
	"shop_owner_walk": AnimationInformation.new("shop_owner_walk", false, true, "shop_owner_idle", 1),
	"shop_owner_die": AnimationInformation.new("shop_owner_die", true, false, "shop_owner_die", 0),
	"shop_owner_hurt": AnimationInformation.new("shop_owner_hurt", true, false, "shop_owner_idle", 0.8)
}

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	frame_changed.connect(_on_frame_change)

func _process(delta: float) -> void:
	pass

func _on_frame_change():
	if animation == "player_hit" and frame == 3:
		get_parent().hit_other_entities()
	if animation == "slime_hit" and frame == 3:
		get_parent().hit_other_entities()
	if animation == "slime_heavy_hit" and frame == 8:
		get_parent().hit_other_entities()

func _on_animation_finished():
	if animation_informations[animation].play_once:
		if "die" in animation:
			return
		force_play(animation_informations[animation].fallback)

func play_anim(to_anim: String) -> void:
	if "die" in animation:
		return
	if "hurt" in to_anim and "heavy_hit" not in animation:
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
	
