extends CanvasLayer


var kart : SimpleRaycastCar = null
var track_progress_component : KartTrackProgressComponent = null

# Called when the node enters the scene tree for the first time.
func _ready():
	%LapLabel.text = ""
	if kart:
		for child in kart.get_children():
			if child is KartBalanceComponent:
				child.hud = self
			if child is KartTrackProgressComponent:
				track_progress_component = child
			
			#if child is kart rank component


func set_balance(value):
	%BalanceBar.value = value


func update_rank():
	if not track_progress_component: return
	var rank = RaceManager.get_kart_rank(kart)
	# TODO: change to images
	%RankLabel.text = "Rank: %d" % rank
	%LapLabel.text = "LAP  %d" % track_progress_component.current_lap
	%_debuginvalidlaplabel.visible = track_progress_component.invalid_lap


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not kart: return
	%SpeedLabel.text = "SPEED: %.1f" % kart.get_speed()
	update_rank()

