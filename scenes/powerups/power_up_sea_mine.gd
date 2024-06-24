extends PowerUp


func on_touched(kart_balance_component: KartBalanceComponent):
	kart_balance_component.balance = 0 # -= 50
	
	var car = kart_balance_component.car
	car.linear_velocity += Vector3.UP * 3
	
	queue_free()
