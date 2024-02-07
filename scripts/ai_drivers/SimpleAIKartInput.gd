class_name SimpleAIKartInput
extends KartInput
##


						
##
##
##
##



@export var debug_enabled := false :
	set(value):
		debug_enabled = value
		if nav_agent: nav_agent.debug_enabled = value

@export var chase_target: Node3D

enum AIChaseMode {
	POSITION, NODE3D
}
var chase_mode: AIChaseMode = AIChaseMode.POSITION

var nav_agent: NavigationAgent3D

func set_target_position(target_position):
	nav_agent.target_position = target_position
	#print("ok!")

func _ready():
	_setup_navigation()

func _physics_process(delta):
	#if chase_mode == AIChaseMode.NODE3D and chase_target:
	#	nav_agent.target_position = chase_target.global_position
	
	pass

## Private function. This is the function to override in subclasses.
func _update_input() -> void:
	#throttle = Input.get_action_strength("ui_up")
	#brakes = Input.get_action_strength("ui_down")
	#drift = Input.get_action_strength("drift")
	#steering = Input.get_axis("ui_left", "ui_right")
	nav_agent.velocity = car.linear_velocity
	
	var distance_vector = nav_agent.get_next_path_position() - car.global_position
	var direction = nav_agent.get_next_path_position() - car.global_position
	direction.y = 0
	direction = direction.normalized()
	var forward = -car.global_basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var dot : float = forward.normalized().dot(direction.normalized())
	var cross : Vector3 = forward.cross(direction)
	steering = sign(-cross.y) #* sign(dot)
	
	#if cross.y > 0.01:
		#steering = 1
	#elif cross.y < -0.01:
		#steering = -1
	#else:
		#steering = 0
	
	
	
	throttle = max(0, dot)
	#brakes = 1 - throttle
	
	#if distance_vector.length() < 10:
		#brakes = 0.5
	
	#direction = direction.normalized()
	#car.apply_central_force(direction * car.mass * 10)

func _setup_navigation():
	nav_agent = NavigationAgent3D.new()
	nav_agent.debug_enabled = debug_enabled
	nav_agent.max_speed = 30
	add_child(nav_agent)


