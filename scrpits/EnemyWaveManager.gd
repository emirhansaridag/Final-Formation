extends Node
class_name EnemyWaveManager

# Enemy scenes - configured per level in the scene editor
@export_group("Enemy Scenes")
@export var regular_enemy_scene: PackedScene
@export var boss1_scene: PackedScene
@export var boss2_scene: PackedScene
@export var boss3_scene: PackedScene

# Level Configuration
@export_group("Level Configuration")
@export_enum("Level 1", "Level 2") var current_level: int = 0  # 0 = Level 1, 1 = Level 2

# Game state
var game_timer: float = 0.0
var is_level_active: bool = false
var is_level_completed: bool = false

# Spawn timers for each enemy type (dynamically named based on level)
var regular_enemy_timer: float = 0.0
var boss1_timer: float = 0.0
var boss2_timer: float = 0.0
var boss3_timer: float = 0.0

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
	
	# Verify enemy scenes are configured
	print("🔍 Enemy scene configuration:")
	print("  Regular Enemy: ", regular_enemy_scene)
	print("  Boss 1: ", boss1_scene)  
	print("  Boss 2: ", boss2_scene)
	print("  Boss 3: ", boss3_scene)
	
	if not regular_enemy_scene:
		push_error("❌ Regular enemy scene not configured!")
	# Bosses are optional - not all levels need all bosses
	
func initialize(spawn_pos: Vector3, parent: Node3D):
	spawn_position = spawn_pos
	parent_node = parent
	
func start_level():
	game_timer = 0.0
	is_level_active = true
	is_level_completed = false
	
	# Reset all timers
	regular_enemy_timer = 0.0
	boss1_timer = 0.0
	boss2_timer = 0.0
	boss3_timer = 0.0
	
	var duration = get_level_duration()
	print("Level ", current_level + 1, " started! Duration: ", duration, " seconds")

func stop_level():
	is_level_active = false
	
func _process(delta):
	if not is_level_active or is_level_completed:
		return
		
	game_timer += delta
	
	# Check if level is completed
	var duration = get_level_duration()
	if game_timer >= duration:
		complete_level()
		return
	
	# Update spawn timers and spawn enemies
	update_enemy_spawning(delta)

func update_enemy_spawning(delta: float):
	if current_level == 0:  # Level 1
		update_level1_spawning(delta)
	elif current_level == 1:  # Level 2
		update_level2_spawning(delta)

func update_level1_spawning(delta: float):
	# Always spawn stickmen (regular enemies)
	regular_enemy_timer += delta
	if regular_enemy_timer >= config.stickman_spawn_rate:
		spawn_enemy("regular")
		regular_enemy_timer = 0.0
	
	# Get boss start times (use debug values if debug mode is enabled)
	var serat_start_time = config.debug_serat_boss_start_time if config.debug_mode else config.serat_boss_start_time
	var aras_start_time = config.debug_aras_boss_start_time if config.debug_mode else config.aras_boss_start_time
	var burak_start_time = config.debug_burak_boss_start_time if config.debug_mode else config.burak_boss_start_time
	
	# Spawn Serat bosses (Boss 1)
	if game_timer >= serat_start_time:
		boss1_timer += delta
		if boss1_timer >= config.serat_boss_spawn_rate:
			print("⏰ Time to spawn Serat Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("boss1")
			boss1_timer = 0.0
			# Emit signal for first Serat boss spawn
			if game_timer < serat_start_time + config.serat_boss_spawn_rate:
				boss_phase_started.emit("Serat Boss")
	
	# Spawn Aras bosses (Boss 2)
	if game_timer >= aras_start_time:
		boss2_timer += delta
		if boss2_timer >= config.aras_boss_spawn_rate:
			print("⏰ Time to spawn Aras Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("boss2")
			boss2_timer = 0.0
			# Emit signal for first Aras boss spawn
			if game_timer < aras_start_time + config.aras_boss_spawn_rate:
				boss_phase_started.emit("Aras Boss")
	
	# Spawn Burak bosses (Boss 3)
	if game_timer >= burak_start_time:
		boss3_timer += delta
		if boss3_timer >= config.burak_boss_spawn_rate:
			print("⏰ Time to spawn Burak Boss! Game time: ", game_timer, "s (Debug mode: ", config.debug_mode, ")")
			spawn_enemy("boss3")
			boss3_timer = 0.0
			# Emit signal for first Burak boss spawn
			if game_timer < burak_start_time + config.burak_boss_spawn_rate:
				boss_phase_started.emit("Burak Boss")

func update_level2_spawning(delta: float):
	# Always spawn aliens (regular enemies)
	regular_enemy_timer += delta
	if regular_enemy_timer >= config.alien_spawn_rate:
		spawn_enemy("regular")
		regular_enemy_timer = 0.0
	
	# Spawn Alien Animal bosses (Boss 1)
	if game_timer >= config.alien_animal_start_time:
		boss1_timer += delta
		if boss1_timer >= config.alien_animal_spawn_rate:
			print("⏰ Time to spawn Alien Animal Boss! Game time: ", game_timer, "s")
			spawn_enemy("boss1")
			boss1_timer = 0.0
			# Emit signal for first Alien Animal boss spawn
			if game_timer < config.alien_animal_start_time + config.alien_animal_spawn_rate:
				boss_phase_started.emit("Alien Animal Boss")
	
	# Spawn Alien bosses (Boss 2)
	if game_timer >= config.alien_boss_start_time:
		boss2_timer += delta
		if boss2_timer >= config.alien_boss_spawn_rate:
			print("⏰ Time to spawn Alien Boss! Game time: ", game_timer, "s")
			spawn_enemy("boss2")
			boss2_timer = 0.0
			# Emit signal for first Alien boss spawn
			if game_timer < config.alien_boss_start_time + config.alien_boss_spawn_rate:
				boss_phase_started.emit("Alien Boss")
	
	# Spawn Sus bosses (Boss 3)
	if game_timer >= config.sus_boss_start_time:
		boss3_timer += delta
		if boss3_timer >= config.sus_boss_spawn_rate:
			print("⏰ Time to spawn Sus Boss! Game time: ", game_timer, "s")
			spawn_enemy("boss3")
			boss3_timer = 0.0
			# Emit signal for first Sus boss spawn
			if game_timer < config.sus_boss_start_time + config.sus_boss_spawn_rate:
				boss_phase_started.emit("Sus Boss")

func spawn_enemy(enemy_type: String):
	var enemy_scene: PackedScene
	var enemy_instance: Node3D
	
	# Select the appropriate enemy scene from configured scenes
	match enemy_type:
		"regular":
			enemy_scene = regular_enemy_scene
		"boss1":
			enemy_scene = boss1_scene
		"boss2":
			enemy_scene = boss2_scene
		"boss3":
			enemy_scene = boss3_scene
		_:
			push_error("Unknown enemy type: " + enemy_type)
			return
	
	# Skip spawning if scene is not configured (optional bosses)
	if not enemy_scene:
		return
	
	# For now, always use normal instantiation since PoolManager doesn't have spawn_enemy_type
	# TODO: Add boss support to PoolManager later
	if enemy_scene:
		enemy_instance = enemy_scene.instantiate()
		var spawn_pos = calculate_spawn_position()
		enemy_instance.global_position = spawn_pos
		
		# Set enemy to PAUSABLE mode so it stops when game is paused
		enemy_instance.process_mode = Node.PROCESS_MODE_PAUSABLE
		
		# Add enemy to "enemy" group for collision detection
		enemy_instance.add_to_group("enemy")
		
		parent_node.add_child(enemy_instance)
		
		# Only print for bosses, not regular enemies
		if enemy_type != "regular":
			print("🚨 BOSS SPAWNED: ", enemy_type, " at position: ", spawn_pos)
	else:
		push_error("❌ Enemy scene is null for type: " + enemy_type)
		print("🔍 Configured scenes - Regular: ", regular_enemy_scene, " | Boss1: ", boss1_scene, " | Boss2: ", boss2_scene, " | Boss3: ", boss3_scene)
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
	var duration = get_level_duration()
	return min(game_timer / duration, 1.0)

func get_time_remaining() -> float:
	if not is_level_active:
		return 0.0
	var duration = get_level_duration()
	return max(duration - game_timer, 0.0)

# Helper function to get level duration based on current level
func get_level_duration() -> float:
	if current_level == 0:  # Level 1
		return config.level_duration
	elif current_level == 1:  # Level 2
		return config.level2_duration
	return config.level_duration  # Default fallback

func get_current_phase() -> String:
	if current_level == 0:  # Level 1
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
	elif current_level == 1:  # Level 2
		if game_timer < config.alien_animal_start_time:
			return "Alien Phase"
		elif game_timer < config.alien_boss_start_time:
			return "Alien Animal Boss Phase"
		elif game_timer < config.sus_boss_start_time:
			return "Alien Boss Phase"
		else:
			return "Sus Boss Phase"
	
	return "Unknown Phase"

# Debug function to test boss spawning immediately (call from console or in _ready())
func debug_spawn_boss(boss_type: String):
	if config.debug_mode:
		print("🧪 DEBUG: Spawning ", boss_type, " boss immediately!")
		spawn_enemy(boss_type)
	else:
		print("❌ Debug mode is disabled. Enable debug_mode in GameConfig first.")
