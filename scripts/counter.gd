extends Label
class_name Counter


@export var animation_player: AnimationPlayer

var counter: int = 0
var multiplier: int = 1


func _process(_delta: float) -> void:
	self.text = str(counter)
	

func add_to_counter(amount: int) ->void:
	for i in amount:
		counter += 1 * multiplier
		

func reset_counter() ->void:
	counter = 0
	
	
func update_counter_label(new_value: int) ->void:
	self.text = str(new_value)
