extends Node3D

@export_group("Level Configuration")
@export_enum("Level 1", "Level 2") var current_level: int = 0  # 0 = Level 1, 1 = Level 2

var shooter_adder_scene = preload("res://scenes/shooter_adder.tscn")
var spawn_interval: float
var timer = 0.0
var spawn_position: Vector3

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	
	# Use level-specific spawn interval
	if current_level == 0:  # Level 1
		spawn_interval = config.shooter_spawner_interval
	elif current_level == 1:  # Level 2
		spawn_interval = config.level2_shooter_spawner_interval
	else:
		spawn_interval = config.shooter_spawner_interval  # Default fallback
	
	spawn_position = config.shooter_adder_spawn_position
	
	print("👤 Shooter Adder Spawner initialized for Level ", current_level + 1, " - Interval: ", spawn_interval, "s")
	
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
	
	# Set to PAUSABLE mode so it stops when game is paused
	new_shooter_adder.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Add it to the scene
	add_child(new_shooter_adder)
	
	# Set its position
	new_shooter_adder.global_position = spawn_position
	
