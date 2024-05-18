extends GPUParticles3D

@export var lifespan : float = 5.0
var life_time : float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	life_time += delta
	if life_time >= lifespan:
		queue_free()
