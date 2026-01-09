extends Label
class_name Counter



@export var animation_player: AnimationPlayer
var counter: int = 0
var streak_mult: int = 1



func add_to_counter(amount: int, mult: int) ->void:
	counter += amount * mult
	self.text = str(counter)
		

func reset_counter() ->void:
	counter = 0


func _on_block_manager_blocks_matching(source: BuildBlockManager) -> void:
	add_to_counter(source.number_of_blocks, streak_mult)


func _on_custom_timer_timeout() -> void:
	reset_counter()
