extends Node3D

# Camera following variables
@onready var camera = $Camera3D
@onready var spawn_area = $shooterSpawnArea
@onready var enemy_spawner_area = $enemySpawnerArea
@onready var enemy_hit_spot = $enemy_hit_spot
var camera_follow_speed: float
var camera_dead_zone: float
var camera_offset = Vector3.ZERO  # Optional offset from spawn area position

# Level progression
var wave_manager
var level_start_time: float = 0.0

# Time-based currency system
var currency_timer: float = 0.0
var currency_per_second: int = 2  # 2 coins per second for level 1
var level_completion_bonus: int = 400  # Bonus when level completes
var currency_awarded: bool = false  # Track if completion bonus was awarded
var starting_currency: int = 0  # Track starting coins to calculate earned coins

# Game state
var is_game_over: bool = false
var is_game_won: bool = false

# Popup scenes
var game_over_scene: PackedScene = preload("res://scenes/game_over_scene.tscn")
var you_win_scene: PackedScene = preload("res://scenes/you_win_screen.tscn")
var game_over_popup: Control = null
var you_win_popup: Control = null

# Performance optimization
var camera_update_timer: float = 0.0
var camera_update_interval: float

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Get values from config safely and cache for performance
	var config = Global.get_config()
	camera_follow_speed = config.camera_follow_speed
	camera_dead_zone = config.camera_dead_zone
	camera_update_interval = config.update_frequency_reduction
	
	# Cache frequently used values for better performance
	cached_camera_follow_speed = camera_follow_speed
	cached_camera_dead_zone = camera_dead_zone
	
	# Initialize pool manager as singleton if it doesn't exist
	if not get_node_or_null("/root/PoolManager"):
		var pool_manager = preload("res://scrpits/PoolManager.gd").new()
		pool_manager.name = "PoolManager"
		get_tree().root.add_child(pool_manager)
	
	# Clean up any invalid objects that might exist from previous scenes
	var pool_manager = get_node_or_null("/root/PoolManager")
	if pool_manager and pool_manager.has_method("cleanup_invalid_objects"):
		pool_manager.cleanup_invalid_objects()
	
	# Performance debugger removed - movement issues fixed
	
	# Get wave manager from enemy spawner
	if enemy_spawner_area:
		var spawner_script = enemy_spawner_area.get_script()
		if spawner_script and enemy_spawner_area.has_method("get_wave_manager"):
			wave_manager = enemy_spawner_area.get_wave_manager()
			if wave_manager:
				wave_manager.boss_phase_started.connect(_on_boss_phase_started)
				wave_manager.level_completed.connect(_on_level_completed)
	
	# Connect enemy hit spot signal
	if enemy_hit_spot:
		enemy_hit_spot.enemy_reached_end.connect(_on_enemy_reached_end)
		print("✅ Enemy hit spot connected to mainScene")
	else:
		print("⚠️ Enemy hit spot not found in scene!")
	
	# Track starting currency to calculate earned coins
	starting_currency = Global.currency
	
	level_start_time = Time.get_unix_time_from_system()

# Performance optimization: Cache config values and reduce update frequency
var cached_camera_follow_speed: float
var cached_camera_dead_zone: float

func _process(delta):
	# Don't update game if it's over or won
	if is_game_over or is_game_won:
		return
	
	# Update camera every frame for smooth following
	_update_camera(delta)
	
	# Time-based currency system
	_update_currency_system(delta)
	
	# Display level progress (simple console output for now) - already optimized with timer
	if wave_manager:
		_display_level_progress()

func _update_camera(delta: float):
	# Smooth camera following logic using cached values for better performance
	if camera and spawn_area:
		# Calculate target camera position (only X axis)
		var target_x = spawn_area.global_position.x + camera_offset.x
		var current_camera_pos = camera.global_position
		
		# Calculate the distance between current camera X and target X
		var distance_x = abs(target_x - current_camera_pos.x)
		
		# Only move camera if outside dead zone (using cached value)
		if distance_x > cached_camera_dead_zone:
			# Smoothly interpolate only the X position using cached values
			var new_x = lerp(current_camera_pos.x, target_x, cached_camera_follow_speed * delta)
			
			# Update camera position while preserving Y and Z
			camera.global_position = Vector3(new_x, current_camera_pos.y, current_camera_pos.z)

# Level progression signal handlers
func _on_boss_phase_started(boss_type: String):
	print("🚨 BOSS ALERT: ", boss_type, " has entered the battlefield!")
	# You can add UI effects, sound effects, or screen shake here

func _on_level_completed():
	print("🎉 LEVEL COMPLETED! Great job!")
	# Award level completion bonus
	if not currency_awarded:
		Global.add_currency(level_completion_bonus)
		currency_awarded = true
		print("💰 Level completion bonus: +", level_completion_bonus, " coins!")
	
	# Save game progress
	SaveManager.save_game()
	print("💾 Game progress saved!")
	
	# Mark level as completed (you can pass level number if you track it)
	# SaveManager.mark_level_completed(1)  # Uncomment and set level number when you add level tracking
	
	# Show you win screen
	show_you_win_screen()

# Progress display function
var progress_update_timer: float = 0.0
func _display_level_progress():
	# Only update every 5 seconds to avoid spam
	progress_update_timer += get_process_delta_time()
	if progress_update_timer >= 5.0:
		progress_update_timer = 0.0
		var progress = wave_manager.get_progress() * 100
		var phase = wave_manager.get_current_phase()
		var time_remaining = wave_manager.get_time_remaining()
		
		print("📊 Level Progress: %.1f%% | Phase: %s | Time Remaining: %.0fs" % [progress, phase, time_remaining])

# Public functions for external access
func get_wave_manager():
	return wave_manager

func restart_level():
	if wave_manager:
		wave_manager.start_level()

func get_level_progress() -> float:
	if wave_manager:
		return wave_manager.get_progress()
	return 0.0

# Time-based currency system
func _update_currency_system(delta: float):
	# Only award currency if the level is active and not completed
	if wave_manager and not currency_awarded:
		currency_timer += delta
		
		# Award currency every second
		if currency_timer >= 1.0:
			Global.add_currency(currency_per_second)
			currency_timer = 0.0
			# Optional: print for debugging
			# print("💰 Time reward: +", currency_per_second, " coins (Total: ", Global.currency, ")")

# Called when an enemy reaches the hit spot
func _on_enemy_reached_end():
	if is_game_over or is_game_won:
		return  # Don't trigger multiple times
	
	print("💀 GAME OVER - Enemy reached the end!")
	is_game_over = true
	
	# Stop the level
	if wave_manager:
		wave_manager.stop_level()
	
	# Save game (currency earned is already saved via Global)
	SaveManager.save_game()
	
	# Show game over screen
	show_game_over_screen()

# Show the game over popup
func show_game_over_screen():
	if game_over_popup:
		return  # Already showing
	
	# Calculate earned coins
	var earned_coins = Global.currency - starting_currency
	
	# Create and add the game over popup
	game_over_popup = game_over_scene.instantiate()
	add_child(game_over_popup)
	
	# Set earned coins on the popup
	if game_over_popup.has_method("set_earned_coins"):
		game_over_popup.set_earned_coins(earned_coins)
	
	# Pause game (but keep rendering)
	get_tree().paused = true
	game_over_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("📺 Game Over screen displayed - Earned coins: ", earned_coins)

# Show the you win popup
func show_you_win_screen():
	if you_win_popup or is_game_over:
		return  # Don't show if already showing or if game over
	
	is_game_won = true
	
	# Calculate earned coins (including completion bonus)
	var earned_coins = Global.currency - starting_currency
	
	# Create and add the you win popup
	you_win_popup = you_win_scene.instantiate()
	add_child(you_win_popup)
	
	# Set earned coins on the popup
	if you_win_popup.has_method("set_earned_coins"):
		you_win_popup.set_earned_coins(earned_coins)
	
	# Pause game (but keep rendering)
	get_tree().paused = true
	you_win_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("📺 You Win screen displayed - Earned coins: ", earned_coins)
