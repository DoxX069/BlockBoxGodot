extends PanelContainer

@onready var timer:= $Timer
@onready var progress_bar:= $TextureProgressBar
var timer_max

func _ready() -> void:
	timer_max = timer.get_wait_time()

func _physics_process(_delta: float) -> void:
	if timer.is_stopped():
		progress_bar.value = 0
	else:
		progress_bar.value = (timer_max - timer.get_time_left()) / timer_max * 100
