extends Node2D

func _ready():
	pass

func _process(_delta):
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
