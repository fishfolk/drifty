extends CanvasLayer


var kart : SimpleRaycastCar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if kart:
		for child in kart.get_children():
			if child is KartBalanceComponent:
				child.hud = self
			#if child is kart lap tracker component
			
			#if child is kart rank component


func set_balance(value):
	%BalanceBar.value = value


func update_rank():
	var rank = RaceManager.get_kart_rank(kart)
	# TODO: change to images
	%RankLabel.text = "Rank: %d" % rank


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not kart: return
	%SpeedLabel.text = "SPEED: %.2f" % kart.get_speed()
	update_rank()

