extends Node3D



func _ready():
	var player_input = PlayerKartInput.new()
	$PictureBike.set_input_node(player_input)

func on_click_nav_test():
	var target_position = $AITarget.global_position
	var ai_driver = $AIControlledKart/SimpleAIKartInput
	ai_driver.set_target_position(target_position)


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event)
			on_click_nav_test()
