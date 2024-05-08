extends CanvasLayer


var kart : SimpleRaycastCar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not kart: return
	%LabelSpeed.text = "SPEED: %.2f" % kart.get_speed()
