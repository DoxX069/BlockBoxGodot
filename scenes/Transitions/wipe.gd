extends CanvasLayer



@export var color_rect: ColorRect
var duration: float



func _ready() -> void:
	color_rect.material.set_shader_parameter("progressIn", 0.0)
	color_rect.material.set_shader_parameter("progressOut", 0.0)
	

func transition_in(target_scene: String):
	# Slide in
	var tween: Tween = create_tween()
	tween.tween_method(set_progress_slide_in, 0.0, 0.75, duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_half_completed.emit(target_scene))
	
	# Slide out
	tween.tween_method(set_progress_slide_out, 0.0, 0.75, duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_completed.emit())
	

func set_progress_slide_in(value: float): 
	color_rect.material.set_shader_parameter("progressIn", value)
	
func set_progress_slide_out(value: float): 
	color_rect.material.set_shader_parameter("progressOut", value)
