extends Node3D



@export_enum("fade", "wipe") var transition_type: String
@export_file_path("*.tscn") var next_scene: String
@export_range(0, 10, 0.1) var duration: float = 1

@export var platform_block_1: StaticBody3D
@export var platform_block_2: StaticBody3D
@export var platform_block_3: StaticBody3D
@export var platform_block_4: StaticBody3D
@export var platform_block_5: StaticBody3D
@export var platform_block_6: StaticBody3D
@export var platform_block_7: StaticBody3D
@export var platform_block_8: StaticBody3D
@export var platform_block_9: StaticBody3D



func _ready() -> void:
	
	platform_block_1.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_2.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_3.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_4.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_5.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_6.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_7.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_8.scale = Vector3(0.00001, 0.00001, 0.00001)
	platform_block_9.scale = Vector3(0.00001, 0.00001, 0.00001)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	
	tween.tween_property(platform_block_1, "scale", Vector3(1, 1, 1), 0.15)
	tween.tween_property(platform_block_2, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_3, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_4, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_5, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_6, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_7, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_8, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(platform_block_9, "scale", Vector3(1, 1, 1), 0.2)
	
func _process(_delta):
	pass
	
	

func _on_play_pressed() -> void:
	SceneTransitionController.change_scene(next_scene, transition_type, duration)
