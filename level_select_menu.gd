extends Control

@onready var level1 = $CanvasLayer/levelNode
@onready var level2 = $CanvasLayer/levelNode2

var levelNum: int

func _ready():
	levelNum = 0
	level1.visible = true
	level2.visible = false  
	
func _process(delta):
	if (levelNum == 0):
		level1.visible = true
		level2.visible = false
	elif (levelNum == 1):
		level1.visible = false
		level2.visible = true

func _on_right_button_button_down():
	if (levelNum != 1):
		levelNum = levelNum+1
	else:
		pass
	
func _on_left_button_button_down():
	if (levelNum != 0):
		levelNum = levelNum-1
	else:
		pass


func _on_back_button_pressed():
	SceneTransition.change_scene_with_fade("res://scenes/main_menu.tscn")
