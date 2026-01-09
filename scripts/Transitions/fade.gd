extends CanvasLayer



@export var color_rect: ColorRect
var duration: float



func transition_in(target_scene: String):
	# Fade to black
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_half_completed.emit(target_scene))
	
	# Fade back to transparent
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_completed.emit(target_scene))
