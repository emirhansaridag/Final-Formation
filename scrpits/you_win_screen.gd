extends Control

@onready var coins_label = $CanvasLayer/TextureRect/coins

func _ready():
	# Make sure process mode is set to ALWAYS so it works while paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_earned_coins(amount: int):
	if coins_label:
		coins_label.text = str(amount)
		print("You Win - Displaying earned coins: ", amount)
	else:
		print("⚠️ Warning: coins label not found in you win scene")

func _on_home_button_pressed():
	# Unpause the game before transitioning
	get_tree().paused = false
	SceneTransition.change_scene_with_fade("res://scenes/main_menu.tscn")
