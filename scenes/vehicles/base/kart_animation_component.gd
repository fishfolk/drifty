extends Node3D


@export var kart_balance_component : KartBalanceComponent
@export var kart_itemuse_component : KartItemUseComponent

var particle_bubble_packed = preload("res://scenes/effects/bubble_emote_scene.tscn")

var timer_emote : float = 0.0

@onready var kart : SimpleRaycastCar = get_parent()
@onready var bike_anim_tree : AnimationTree = $BikeAnimationTree
@onready var fish_anim_tree : AnimationTree = $FishAnimationTree


func _ready():
	kart_balance_component.balance_lost.connect(animate_hit)
	kart_balance_component.balance_lost_completely.connect(animate_hit.bind(true))
	kart_itemuse_component.used_melee_attack.connect(animate_melee)
	pass


func animate_emote():
	var instance = particle_bubble_packed.instantiate()
	self.add_child(instance)
	instance.emitting = true
	timer_emote += 0.5


func animate_melee(direction = 1):
	fish_anim_tree.set("parameters/melee_bspace/blend_position", direction)
	fish_anim_tree.set("parameters/melee_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func animate_hit(lost_balance_completely:bool=false):
	bike_anim_tree.set("parameters/hit_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if lost_balance_completely:
		fish_anim_tree.set("parameters/hit_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _physics_process(delta):
	if timer_emote > 0: timer_emote -= delta
	
	if kart.input.emote and timer_emote <= 0:
		animate_emote()
	
	_update_blendtrees(delta)


func _update_blendtrees(delta):
	var speed = kart.get_speed()
	var clamped_speed = clamp(speed/10.0, -1.0, 1.0)
	var steer = kart.steer_axis
	
	bike_anim_tree.set("parameters/steer_bspace/blend_position", steer)
	fish_anim_tree.set("parameters/steer_bspace/blend_position", steer)
	
	bike_anim_tree.set("parameters/drive_bspace/blend_position", clamped_speed)
	fish_anim_tree.set("parameters/drive_bspace/blend_position", clamped_speed)
