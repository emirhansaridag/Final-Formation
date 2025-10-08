extends Control

# Settings menu (pause menu used as settings)
var pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
var settings_popup: Control = null

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


func _on_settings_button_pressed():
	show_settings_menu()

func show_settings_menu():
	if settings_popup:
		return  # Already showing
	
	# Create and add the settings popup (using pause menu scene)
	settings_popup = pause_menu_scene.instantiate()
	add_child(settings_popup)
	
	# Connect close signal
	if settings_popup.has_signal("close_requested"):
		settings_popup.close_requested.connect(close_settings_menu)
	
	# Set to always process (no need to pause in menu)
	settings_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("⚙️ Settings menu displayed")

func close_settings_menu():
	if settings_popup:
		settings_popup.queue_free()
		settings_popup = null
		print("⚙️ Settings menu closed")
