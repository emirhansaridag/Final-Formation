extends Node3D

@export_group("Level Configuration")
@export_enum("Level 1", "Level 2") var current_level: int = 0  # 0 = Level 1, 1 = Level 2

var gun_box_scene = preload("res://scenes/gun_box.tscn")
var spawn_interval: float
var timer = 0.0
var spawn_position: Vector3

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	
	# Use level-specific spawn interval
	if current_level == 0:  # Level 1
		spawn_interval = config.gun_box_spawn_interval
	elif current_level == 1:  # Level 2
		spawn_interval = config.level2_gun_box_spawn_interval
	else:
		spawn_interval = config.gun_box_spawn_interval  # Default fallback
	
	spawn_position = config.gun_box_spawn_position
	
	print("📦 Gun Box Spawner initialized for Level ", current_level + 1, " - Interval: ", spawn_interval, "s")
	
	# Start spawning immediately
	spawn_gun_box()

func _process(delta):
	timer += delta
	
	# Spawn new gun box every spawn_interval seconds
	if timer >= spawn_interval:
		spawn_gun_box()
		timer = 0.0

func spawn_gun_box():
	# Use pool manager if available
	var pool_manager = get_node_or_null("/root/PoolManager")
	if pool_manager and pool_manager.has_method("spawn_gun_box"):
		var new_gun_box = pool_manager.spawn_gun_box(spawn_position)
		if new_gun_box:
			new_gun_box.set_pooled(true)
	else:
		# Fallback to normal instantiation
		var new_gun_box = gun_box_scene.instantiate()
		# Set to PAUSABLE mode so it stops when game is paused
		new_gun_box.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(new_gun_box)
		new_gun_box.global_position = spawn_position
	
