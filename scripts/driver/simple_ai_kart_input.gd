class_name SimpleAIKartInput
extends KartInput
##

## How often to refresh its target position, in seconds
@export var nav_refresh_interval : float = 0.1

## Chance for the driver to not skip any given nav refresh.
@export var intelligence_rate : float = 0.9

## How effective is the boost from the AI being behind in rankings?
## Default is 1.0
@export var handicap_boost_rate : float = 1.0

enum AIChaseMode {
	NODE3D, PATH3D
}
@export var chase_mode: AIChaseMode = AIChaseMode.PATH3D

## to be used only in NODE3D mode
@export var node3d_chase_target: Node3D
#@export var chase_path: Path3D

var nav_agent: NavigationAgent3D
var nav_refresh_timer: float = 0

var aiming_position := Vector3.ZERO

@export_category("DEBUG")
@export var nav_debug_enabled := false :
	set(value):
		nav_debug_enabled = value
		if nav_agent: nav_agent.debug_enabled = value
@export var path_follow_preview : PathFollow3D
@export var path_follow_preview2 : PathFollow3D

## This offset makes drivers not follow exactly the middle of the road
## -1 is 1 unit to the left, +1 is 1 unit to the right
var path_sideways_offset := 0.0
## Max distance to swerve from track center.
var safe_track_halfwidth := 10.0

var kart : SimpleRaycastCar = null
var track_progress_component : KartTrackProgressComponent = null

func set_target_position(target_position):
	aiming_position = target_position
	nav_agent.target_position = target_position
	#print("ok!")

func get_aiming_position():
	## This will use A-star to find a path towards the racing line,
	## and try to follow that.
	#return nav_agent.get_next_path_position() 
	
	## This will tightly follow the racing line as defined in the engine in Path mode,
	## and walk straight to the target in NODE3D mode.
	return aiming_position

func refresh_navigation_target():
	if randf() > intelligence_rate: return
	
	if chase_mode == AIChaseMode.NODE3D and node3d_chase_target:
		set_target_position(node3d_chase_target.global_position)
	
	if chase_mode == AIChaseMode.PATH3D and RaceManager.race_path:
		var chase_path : RacePath3D = RaceManager.race_path
		var closest_offset = chase_path.get_closest_offset(chase_path.to_local(car.global_position))
		
		if path_follow_preview:
			path_follow_preview.progress = closest_offset
		
		var speed = max(0, car.get_speed())
		# offset increases with speed as we want the AI to have time to respond. 
		# these are magic numbers that should be tweaked (in spatial units, here they are meters)
		closest_offset += 4 # always look forward a few meters
		closest_offset += speed * 0.9 # increasing this will make AI cut corners more often
		if path_follow_preview2:
			path_follow_preview2.progress = closest_offset
		var target_position: Vector3 = chase_path.sample_looping(closest_offset, true)
		
		
		if randf() < 0.5:
			path_sideways_offset += randf_range(-0.5, 0.5) - 0.01*sign(path_sideways_offset) #bias to the center
			#path_sideways_offset += randf_range(-0.5, 0.01) * sign(path_sideways_offset)
			path_sideways_offset = clampf(path_sideways_offset, -safe_track_halfwidth, safe_track_halfwidth) #assume max road width is 3
		## right hand rule to apply sideways offset
		var forward = chase_path.sample_looping(closest_offset+0.1, true) - target_position
		var up = Vector3.UP
		var right = forward.cross(up).normalized()
		target_position += right * path_sideways_offset
		
		set_target_position(target_position)


func _ready():
	_setup_references()
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


func _update_input(delta) -> void:
	if not enabled: 
		super(delta)
		return
	
	_follow_nav_path(delta)


func _setup_navigation():
	nav_agent = NavigationAgent3D.new()
	nav_agent.debug_enabled = nav_debug_enabled
	nav_agent.max_speed = 30
	nav_agent.path_max_distance = 0.5
	add_child(nav_agent)


func _setup_references():
	kart = get_parent()
	track_progress_component = kart.get_node("KartTrackProgressComponent")



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
		brakes = 0.9 if dot < 0.5 else 0
	
	steering = sign(-cross.y) #* sign(dot)
	
	# TODO: implement reverse behavior
	
	if track_progress_component:
		#_follow_path_handicap_boost(delta)
		pass

## unused
func _follow_path_handicap_boost(delta):
	var rank = RaceManager.get_kart_rank(kart)
	
	#nerf first place
	if rank == 1:
		throttle -= 0.2 * handicap_boost_rate # -10% throttle
	
	#buff anyone that's not podium finisher
	if rank <= 1: return
	
	var boost_mult = rank-2
	throttle += 0.03 * boost_mult * handicap_boost_rate
	# 8th place will have 18% more throttle
	# note that maximum speed is still the same, so we also change boost_extra_speed
	kart.boost_extra_speed = 0.2 * boost_mult * handicap_boost_rate
	# 8th place will have 1.2 extra units/s speed. A normal boost is 7 units/s
