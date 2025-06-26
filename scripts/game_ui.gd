extends PanelContainer

@export var timer: CustomTimer
@onready var progress_bar:= $TextureProgressBar

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if timer.is_stopped:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		current_tween.tween_property(progress_bar,"value",0,0.15)
	else:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		current_tween.tween_property(progress_bar,"value",(timer.duration - timer.time_left) / timer.duration * 100,0.15)
