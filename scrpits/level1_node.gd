extends Control


func _on_level_button_button_down():
	# Use the new scene transition system with fade effect
	SceneTransition.change_scene_with_fade("res://scenes/mainScene.tscn")


func _on_level_button_2_pressed():
		SceneTransition.change_scene_with_fade("res://scenes/level_2.tscn")
