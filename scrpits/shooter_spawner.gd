extends Node3D

var shooter_adder_scene = preload("res://scenes/shooter_adder.tscn")
var spawn_interval: float
var timer = 0.0
var spawn_position: Vector3

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	spawn_interval = config.shooter_spawner_interval  # Using same interval as gun boxes
	spawn_position = config.shooter_adder_spawn_position
	
	# Start spawning immediately
	spawn_shooter_adder()

func _process(delta):
	timer += delta
	
	# Spawn new shooter_adder every spawn_interval seconds
	if timer >= spawn_interval:
		spawn_shooter_adder()
		timer = 0.0

func spawn_shooter_adder():
	# Instance the shooter_adder scene
	var new_shooter_adder = shooter_adder_scene.instantiate()
	
	# Add it to the scene
	add_child(new_shooter_adder)
	
	# Set its position
	new_shooter_adder.global_position = spawn_position
	
