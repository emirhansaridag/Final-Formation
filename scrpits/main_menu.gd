extends Control

func _ready():
	# Display save info on startup (for debugging)
	if SaveManager.save_exists():
		var save_info = SaveManager.get_save_info()
		print("💾 Save loaded - Currency: ", save_info.currency, " | Shooter Level: ", save_info.shooter_level)
	else:
		print("🆕 No save file found - Starting fresh game")

func _on_play_button_button_down():
	# Use the new scene transition system with fade effect
	SceneTransition.change_scene_with_fade("res://scenes/level_select_menu.tscn")


func _on_shop_button_button_down():
	SceneTransition.change_scene_with_fade("res://scenes/shop_menu.tscn")

# Debug function - can be called from a debug menu or console
# To add a reset button in the scene, connect it to this function
func _on_reset_save_button_pressed():
	SaveManager.delete_save()
	get_tree().reload_current_scene()

# Debug function - print save data
func _on_debug_save_info_pressed():
	SaveManager.print_save_data()
