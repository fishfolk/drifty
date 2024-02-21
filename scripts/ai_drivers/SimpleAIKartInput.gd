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
@export var chase_path: Path3D

@export var nav_refresh_interval : float = 0.5
@export var intelligence_rate : float = 0.9

enum AIChaseMode {
	POSITION, NODE3D, PATH3D
}
@export var chase_mode: AIChaseMode = AIChaseMode.POSITION

var nav_agent: NavigationAgent3D
var nav_refresh_timer: float = 0

var aiming_position := Vector3.ZERO

func set_target_position(target_position):
	if randf() > intelligence_rate: return
	aiming_position = target_position
	nav_agent.target_position = target_position
	#print("ok!")

func get_aiming_position():
	return nav_agent.get_next_path_position()
	#return aiming_position

func refresh_navigation_target():
	if chase_mode == AIChaseMode.NODE3D and chase_target:
		set_target_position(chase_target.global_position)
	
	if chase_mode == AIChaseMode.PATH3D and chase_path:
		var closest_offset = chase_path.curve.get_closest_offset(global_position)
		
		var speed = max(0, car.get_speed())
		# offset increases with speed as we want the AI to have time to respond. 
		# these are magic numbers that should be tweaked (in spatial units, here they are meters)
		closest_offset += 4 # always look forward 2 meters
		closest_offset += speed * 0.9 # increasing this will make AI cut corners more often
		var target_position: Vector3 = chase_path.curve.sample_baked(closest_offset)
		set_target_position(target_position)


func _ready():
	_setup_navigation()

func _physics_process(delta):
	if not enabled: return
	
	nav_refresh_timer -= delta
	if nav_refresh_timer <= 0:
		refresh_navigation_target()
		nav_refresh_timer = nav_refresh_interval
	
	#if chase_mode == AIChaseMode.NODE3D and chase_target:
	#	nav_agent.target_position = chase_target.global_position
	
	pass

## Private function. This is the function to override in subclasses.
func _update_input(delta) -> void:
	#throttle = Input.get_action_strength("ui_up")
	#brakes = Input.get_action_strength("ui_down")
	#drift = Input.get_action_strength("drift")
	#steering = Input.get_axis("ui_left", "ui_right")
	if not enabled: 
		super(delta)
		return
	
	_follow_nav_path(delta)
	
	#var distance_vector = nav_agent.get_next_path_position() - car.global_position
	#var direction = nav_agent.get_next_path_position() - car.global_position
	#direction.y = 0
	#direction = direction.normalized()
	#var forward = -car.global_basis.z
	#forward.y = 0
	#forward = forward.normalized()
	#
	#var dot : float = forward.normalized().dot(direction.normalized())
	#var cross : Vector3 = forward.cross(direction)
	
	
	#if cross.y > 0.01:
		#steering = 1
	#elif cross.y < -0.01:
		#steering = -1
	#else:
		#steering = 0
	
	
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


func _follow_nav_path(delta):
	nav_agent.velocity = car.linear_velocity # why?
	
	
	var distance: Vector3 = get_aiming_position() - car.global_position
	var direction: Vector3 = Vector3(distance)
	direction.y = 0
	direction = direction.normalized()
	var forward = -car.global_basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var dot : float = forward.dot(direction)
	var cross : Vector3 = forward.cross(direction)
	
	# if target is in front of AI
	if dot > 0:
		# drive forward
		throttle = min(1, 0.5+dot) # throttle = max(0, dot) # throttle = 1 
		# if target is 45° or more to the side, apply the brakes a little
		brakes = 0.5 if dot < 0.5 else 0
		
	
	steering = sign(-cross.y) #* sign(dot)
	#throttle = max(0, dot)

