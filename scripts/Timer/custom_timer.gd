extends Node
class_name CustomTimer


@export var duration: float = 1
@export var elapsed_time: float = 0
var time_left: float
var is_running: bool = false
var is_stopped: bool = true
signal timeout

@export var build_block_manager: BlockManager
var reduce_time_correct: float = 1
var reduce_time_new_block: float = 1


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
	elapsed_time = clampf(new_time, 0, duration)
	print(" --- Current Time --- ")
	print(elapsed_time)


func _on_block_manager_blocks_matching() -> void:
	pause()
	set_elapsed_time(elapsed_time - reduce_time_correct * build_block_manager.number_of_blocks)
	if reduce_time_correct > 0.25:
		reduce_time_correct -= 0.15


func _on_remove_pressed() -> void:
	set_elapsed_time(elapsed_time + clampf(reduce_time_new_block, 0.5, 15))
	reduce_time_new_block -= 1
	reduce_time_correct = 1


func _on_add_pressed() -> void:
	set_elapsed_time(elapsed_time - clampf(reduce_time_new_block, 0.5, 15))
	reduce_time_new_block += 1
	reduce_time_correct = 1
