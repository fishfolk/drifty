extends Node3D


var particle_bubble_packed = preload("res://scenes/effects/bubble_emote_scene.tscn")

var timer_emote : float = 0.0


@onready var car = get_parent()







func do_emote():
	var instance = particle_bubble_packed.instantiate()
	self.add_child(instance)
	instance.emitting = true
	timer_emote += 0.5


func _physics_process(delta):
	if timer_emote > 0: timer_emote -= delta
	
	if car.input.emote and timer_emote <= 0:
		do_emote()
