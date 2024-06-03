class_name ItemBoxArea
extends Area3D


@export var table : ItemTable = null

func _ready():
	$AnimationPlayer.seek(randf()) # offset animation randomly by up to a second
