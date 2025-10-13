extends Control

signal close_requested

@onready var credits_texts = $CanvasLayer/bg_panel/creditsTexts

func _ready():
	# Connect button signals
	var close_btn = $CanvasLayer/bg_panel/close/close_button
	var unmute_btn = $CanvasLayer/bg_panel/muteUnmuteButton/unmuteButton
	var mute_btn = $CanvasLayer/bg_panel/muteUnmuteButton/muteButton
	var credits_btn = $CanvasLayer/bg_panel/credits/creditsButton
	
	if close_btn:
		close_btn.pressed.connect(_on_close_button_pressed)
	if unmute_btn:
		unmute_btn.pressed.connect(_on_unmute_button_pressed)
	if mute_btn:
		mute_btn.pressed.connect(_on_mute_button_pressed)
	if credits_btn:
		credits_btn.pressed.connect(_on_credits_button_pressed)
	
	# Hide credits by default
	if credits_texts:
		credits_texts.visible = false
	
	# Update mute button visibility based on current audio state
	_update_mute_buttons()

func _on_close_button_pressed():
	# Emit signal to close the pause menu
	close_requested.emit()
	print("⏸️ Pause menu close button pressed")

func _on_unmute_button_pressed():
	# Unmute all audio
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	_update_mute_buttons()
	print("🔊 Audio unmuted")

func _on_mute_button_pressed():
	# Mute all audio
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	_update_mute_buttons()
	print("🔇 Audio muted")

func _on_credits_button_pressed():
	# Toggle credits visibility
	if credits_texts:
		credits_texts.visible = !credits_texts.visible
		print("📜 Credits toggled: ", credits_texts.visible)

func _update_mute_buttons():
	# Update button visibility based on mute state
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	var unmute_btn = $CanvasLayer/bg_panel/muteUnmuteButton/unmuteButton
	var mute_btn = $CanvasLayer/bg_panel/muteUnmuteButton/muteButton
	
	if unmute_btn:
		unmute_btn.visible = is_muted
	if mute_btn:
		mute_btn.visible = !is_muted


func _on_button_pressed():
	# Unpause the game first
	get_tree().paused = false
	# Then change scene
	SceneTransition.change_scene_with_fade("res://scenes/main_menu.tscn")
	print("🏠 Home button pressed - returning to main menu")
