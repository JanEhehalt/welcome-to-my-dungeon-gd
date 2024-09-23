class_name AnimationInformation

extends Node

var anim_name: String
var play_once: bool
var breakable: bool
var fallback: String
var speed_prc: float

func _init(anim_name, play_once, breakable, fallback, speed_prc) -> void:
	self.anim_name = anim_name
	self.play_once = play_once
	self.breakable = breakable
	self.fallback = fallback
	self.speed_prc = speed_prc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
