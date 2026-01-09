extends CanvasLayer



@export var color_rect: ColorRect
var duration: float



func _ready() -> void:
	color_rect.material.set_shader_parameter("progress", 0.0)
	

func transition_in(target_scene: String):
	# Slide in
	var tween: Tween = create_tween()
	tween.tween_method(set_progress, 0.0, 1.0, duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_half_completed.emit(target_scene))
	
	# Slide out
	tween.tween_method(set_progress, 1.0, 0, duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_completed.emit(target_scene))
	

func set_progress(value: float): 
	color_rect.material.set_shader_parameter("progress", value)
	
