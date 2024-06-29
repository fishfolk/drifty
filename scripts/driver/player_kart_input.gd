class_name PlayerKartInput
extends KartInput
##

@export var player_index : int = 0

var kart_hud_packed = preload("res://scenes/vehicles/hud/hud_kart.tscn")
var kart_hud = null

@onready var track_progress_component : KartTrackProgressComponent = get_parent().get_node_or_null("KartTrackProgressComponent")




func _ready():
	_setup_hud()
	if track_progress_component:
		track_progress_component.finished_race.connect(_on_race_finished)


func _update_input(delta) -> void:
	throttle = Input.get_action_strength("throttle")
	brakes = Input.get_action_strength("brakes")
	steering = Input.get_axis("ui_left", "ui_right")
	drift = Input.get_action_strength("drift")
	item = Input.get_action_strength("item")
	melee_left = Input.is_action_pressed("melee_left")
	melee_right = Input.is_action_pressed("melee_right")
	emote = Input.is_action_pressed("emote")
	#print_debug(car.get_speed())
	#print_debug("turning diameter: ", 2*car.get_turning_radius())


func _setup_hud():
	kart_hud = kart_hud_packed.instantiate()
	kart_hud.kart = car
	add_child(kart_hud)


func _on_race_finished():
	var finish_cam = car.get_node_or_null("RaceFinishCamera")
	if finish_cam:
		finish_cam.make_current()
