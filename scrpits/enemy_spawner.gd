extends Area3D

@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var spawn_interval: float
var spawn_area_size: Vector3 = Vector3(6, 0, 9)
var spawn_offset: Vector3

var timer: Timer
var wave_manager

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	spawn_interval = config.enemy_spawn_interval
	spawn_offset = config.enemy_spawn_offset
	
	# Create wave manager using runtime script loading
	var EnemyWaveManagerScript = load("res://scrpits/EnemyWaveManager.gd")
	if EnemyWaveManagerScript:
		wave_manager = EnemyWaveManagerScript.new()
		add_child(wave_manager)
		wave_manager.initialize(spawn_offset, get_parent())
		
		# Connect wave manager signals
		wave_manager.boss_phase_started.connect(_on_boss_phase_started)
		wave_manager.enemy_spawned.connect(_on_enemy_spawned)
		wave_manager.level_completed.connect(_on_level_completed)
		
		# Start the level
		wave_manager.start_level()
	else:
		push_error("Failed to load EnemyWaveManager script!")

# Signal handlers for wave manager events
func _on_boss_phase_started(boss_type: String):
	print("Boss phase started: ", boss_type)
	# You can add UI notifications or special effects here

func _on_enemy_spawned(enemy_type: String):
	# Track spawned enemies if needed
	pass

func _on_level_completed():
	print("Level completed!")
	# You can add level completion logic here (UI, rewards, etc.)

# Legacy functions for compatibility
func set_spawn_rate(new_interval: float):
	# This function is kept for compatibility but wave manager handles timing now
	spawn_interval = new_interval

func start_spawning():
	if wave_manager:
		wave_manager.start_level()

func stop_spawning():
	if wave_manager:
		wave_manager.stop_level()

# Get wave manager for external access
func get_wave_manager():
	return wave_manager
