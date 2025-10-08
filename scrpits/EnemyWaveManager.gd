extends Node
class_name EnemyWaveManager

# Enemy scenes - using load() instead of preload() to avoid compilation issues
var stickman_scene: PackedScene
var serat_boss_scene: PackedScene  
var aras_boss_scene: PackedScene
var burak_boss_scene: PackedScene

# Game state
var game_timer: float = 0.0
var is_level_active: bool = false
var is_level_completed: bool = false

# Spawn timers for each enemy type
var stickman_timer: float = 0.0
var serat_boss_timer: float = 0.0
var aras_boss_timer: float = 0.0
var burak_boss_timer: float = 0.0

# Configuration
var config: GameConfig
var spawn_position: Vector3
var spawn_area_size: Vector3 = Vector3(6, 0, 9)

# Parent reference for spawning
var parent_node: Node3D

# Signals
signal level_completed
signal boss_phase_started(boss_type: String)
signal enemy_spawned(enemy_type: String)

func _ready():
	config = Global.get_config()
	
	# Load enemy scenes at runtime
	stickman_scene = load("res://scenes/stickman.tscn")
	serat_boss_scene = load("res://scenes/serat_boss.tscn")
	aras_boss_scene = load("res://scenes/aras_boss.tscn")
	burak_boss_scene = load("res://scenes/burak_boss.tscn")
	
	# Verify scenes loaded correctly with detailed info
	print("🔍 Scene loading results:")
	print("  Stickman: ", stickman_scene)
	print("  Serat Boss: ", serat_boss_scene)  
	print("  Aras Boss: ", aras_boss_scene)
	print("  Burak Boss: ", burak_boss_scene)
	
	if not stickman_scene:
		push_error("❌ Failed to load stickman.tscn")
	if not serat_boss_scene:
		push_error("❌ Failed to load serat_boss.tscn")
	if not aras_boss_scene:
		push_error("❌ Failed to load aras_boss.tscn")
	if not burak_boss_scene:
		push_error("❌ Failed to load burak_boss.tscn")
	
func initialize(spawn_pos: Vector3, parent: Node3D):
	spawn_position = spawn_pos
	parent_node = parent
	
func start_level():
	game_timer = 0.0
	is_level_active = true
	is_level_completed = false
	
	# Reset all timers
	stickman_timer = 0.0
	serat_boss_timer = 0.0
	aras_boss_timer = 0.0
	burak_boss_timer = 0.0
	
	print("Level started! Duration: ", config.level_duration, " seconds")

func stop_level():
	is_level_active = false
	
func _process(delta):
	if not is_level_active or is_level_completed:
		return
		
	game_timer += delta
	
	# Check if level is completed
	if game_timer >= config.level_duration:
		complete_level()
		return
	
	# Update spawn timers and spawn enemies
	update_enemy_spawning(delta)

func update_enemy_spawning(delta: float):
	# Always spawn stickmen
	stickman_timer += delta
	if stickman_timer >= config.stickman_spawn_rate:
		spawn_enemy("stickman")
		stickman_timer = 0.0
	
	# Get boss start times (use debug values if debug mode is enabled)
	var serat_start_time = config.debug_serat_boss_start_time if config.debug_mode else config.serat_boss_start_time
	var aras_start_time = config.debug_aras_boss_start_time if config.debug_mode else config.aras_boss_start_time
	var burak_start_time = config.debug_burak_boss_start_time if config.debug_mode else config.burak_boss_start_time
	
	# Spawn Serat bosses
	if game_timer >= serat_start_time:
		serat_boss_timer += delta
		if serat_boss_timer >= config.serat_boss_spawn_rate:
			print("⏰ Time to spawn Serat Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("serat_boss")
			serat_boss_timer = 0.0
			# Emit signal for first Serat boss spawn
			if game_timer < serat_start_time + config.serat_boss_spawn_rate:
				boss_phase_started.emit("Serat Boss")
	
	# Spawn Aras bosses
	if game_timer >= aras_start_time:
		aras_boss_timer += delta
		if aras_boss_timer >= config.aras_boss_spawn_rate:
			print("⏰ Time to spawn Aras Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("aras_boss")
			aras_boss_timer = 0.0
			# Emit signal for first Aras boss spawn
			if game_timer < aras_start_time + config.aras_boss_spawn_rate:
				boss_phase_started.emit("Aras Boss")
	
	# Spawn Burak bosses
	if game_timer >= burak_start_time:
		burak_boss_timer += delta
		if burak_boss_timer >= config.burak_boss_spawn_rate:
			print("⏰ Time to spawn Burak Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("burak_boss")
			burak_boss_timer = 0.0
			# Emit signal for first Burak boss spawn
			if game_timer < burak_start_time + config.burak_boss_spawn_rate:
				boss_phase_started.emit("Burak Boss")

func spawn_enemy(enemy_type: String):
	var enemy_scene: PackedScene
	var enemy_instance: Node3D
	
	# Select the appropriate enemy scene
	match enemy_type:
		"stickman":
			enemy_scene = stickman_scene
		"serat_boss":
			enemy_scene = serat_boss_scene
		"aras_boss":
			enemy_scene = aras_boss_scene
		"burak_boss":
			enemy_scene = burak_boss_scene
		_:
			push_error("Unknown enemy type: " + enemy_type)
			return
	
	# For now, always use normal instantiation since PoolManager doesn't have spawn_enemy_type
	# TODO: Add boss support to PoolManager later
	if enemy_scene:
		enemy_instance = enemy_scene.instantiate()
		var spawn_pos = calculate_spawn_position()
		enemy_instance.global_position = spawn_pos
		parent_node.add_child(enemy_instance)
		
		# Only print for bosses, not regular enemies
		if enemy_type != "stickman":
			print("🚨 BOSS SPAWNED: ", enemy_type, " at position: ", spawn_pos)
	else:
		push_error("❌ Enemy scene is null for type: " + enemy_type)
		print("🔍 Available scenes - Stickman: ", stickman_scene, " | Serat: ", serat_boss_scene, " | Aras: ", aras_boss_scene, " | Burak: ", burak_boss_scene)
		return
	
	# Emit signal
	enemy_spawned.emit(enemy_type)

func calculate_spawn_position() -> Vector3:
	# Generate random position within the spawn area
	var random_x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var random_y = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	var random_z = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	
	return Vector3(random_x, random_y, random_z) + spawn_position

func complete_level():
	if is_level_completed:
		return
		
	is_level_completed = true
	is_level_active = false
	level_completed.emit()
	print("Level completed! Total time: ", game_timer)

func get_progress() -> float:
	if not is_level_active:
		return 0.0
	return min(game_timer / config.level_duration, 1.0)

func get_time_remaining() -> float:
	if not is_level_active:
		return 0.0
	return max(config.level_duration - game_timer, 0.0)

func get_current_phase() -> String:
	var serat_start_time = config.debug_serat_boss_start_time if config.debug_mode else config.serat_boss_start_time
	var aras_start_time = config.debug_aras_boss_start_time if config.debug_mode else config.aras_boss_start_time
	var burak_start_time = config.debug_burak_boss_start_time if config.debug_mode else config.burak_boss_start_time
	
	if game_timer < aras_start_time:
		return "Stickman Phase"
	elif game_timer < serat_start_time:
		return "Aras Boss Phase"
	elif game_timer < burak_start_time:
		return "Serat Boss Phase"
	else:
		return "Burak Boss Phase"

# Debug function to test boss spawning immediately (call from console or in _ready())
func debug_spawn_boss(boss_type: String):
	if config.debug_mode:
		print("🧪 DEBUG: Spawning ", boss_type, " boss immediately!")
		spawn_enemy(boss_type)
	else:
		print("❌ Debug mode is disabled. Enable debug_mode in GameConfig first.")
