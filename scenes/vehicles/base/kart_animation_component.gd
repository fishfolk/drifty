class_name KartAnimationComponent
extends Node3D


@export var kart_balance_component : KartBalanceComponent
@export var kart_itemuse_component : KartItemUseComponent
@export var kart_model_node : Node3D
@export var bike_anim_tree : AnimationTree
@export var fish_anim_tree : AnimationTree

var particle_bubble_packed = preload("res://scenes/effects/bubble_emote_scene.tscn")

var timer_emote : float = 0.0

@onready var kart : SimpleRaycastCar = get_parent()


var model_fish : Node3D = null
var model_bike : Node3D = null


func _ready():
	kart_balance_component.balance_lost.connect(animate_hit)
	kart_balance_component.balance_lost_completely.connect(animate_hit.bind(true))
	kart_itemuse_component.used_melee_attack.connect(animate_melee)
	
	for child in kart_model_node.get_children():
		if child.name == "Fish": model_fish = child
		if child.name == "Bike": model_bike = child


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


func set_model_fish(model_packed:PackedScene):
	if model_fish: 
		kart_model_node.remove_child(model_fish)
		model_fish.queue_free()
	
	model_fish = model_packed.instantiate()
	model_fish.name = "Fish"
	kart_model_node.add_child(model_fish)
	var temp_anim_player = model_fish.get_node("AnimationPlayer")
	fish_anim_tree.anim_player = fish_anim_tree.get_path_to(temp_anim_player)


func set_model_bike(model_packed:PackedScene):
	if model_bike: 
		kart_model_node.remove_child(model_bike)
		model_bike.queue_free()
	
	model_bike = model_packed.instantiate()
	model_bike.name = "Bike"
	kart_model_node.add_child(model_bike)
	bike_anim_tree.anim_player = bike_anim_tree.get_path_to(model_bike.get_node("AnimationPlayer"))
	


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
