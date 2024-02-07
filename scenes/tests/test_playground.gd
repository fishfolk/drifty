extends Node3D



func on_click_nav_test():
	var target_position = $AITarget.global_position
	var ai_driver = $AIControlledKart/SimpleAIKartInput
	ai_driver.set_target_position(target_position)


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event)
			on_click_nav_test()
