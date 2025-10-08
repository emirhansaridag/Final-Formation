extends Control


func _on_level_button_button_down():
	# Use the new scene transition system with fade effect
	SceneTransition.change_scene_with_fade("res://scenes/mainScene.tscn")
