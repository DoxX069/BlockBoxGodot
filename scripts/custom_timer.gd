extends Node
class_name CustomTimer


@export var duration: float = 1
var elapsed_time: float = 0
var time_left: float
var is_running: bool = false
var is_stopped: bool = true
signal timeout


func _ready() -> void:
	pass
	

func _physics_process(delta: float) -> void:
	if is_running:
		elapsed_time += delta
		if elapsed_time >= duration:
			is_running = false
			finished()
	time_left = duration - elapsed_time
			
			
func start() ->void:
	is_stopped = false
	elapsed_time = 0
	is_running = true
	
	
func stop() ->void:
	is_stopped = true
	elapsed_time = 0
	is_running = false
	
	
func pause() ->void:
	is_running = false
	
	
func resume() ->void:
	is_running = true
	
	
func finished() ->void:
	stop()
	emit_signal("timeout")
	

func set_elapsed_time(new_time:float) ->void:
	if new_time < 0:
		elapsed_time = 0
	elapsed_time = new_time
	if elapsed_time >= duration:
		is_running = false
		finished()
