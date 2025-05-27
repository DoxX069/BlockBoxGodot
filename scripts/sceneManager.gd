extends Control

func _ready():
	pass

func _process(_delta):
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_new_build_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_load_build_pressed():
	get_tree().change_scene_to_file("res://scenes/savedBuilds.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
