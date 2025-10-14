extends Node3D

@export_group("Level Configuration")
@export_enum("Level 1", "Level 2") var current_level: int = 0  # 0 = Level 1, 1 = Level 2

# Camera following variables
@onready var camera = $CanvasLayer/Camera3D
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
var currency_per_second: int = 2  # Will be set based on level in _ready()
var level_completion_bonus: int = 200  # Bonus when level completes
var currency_awarded: bool = false  # Track if completion bonus was awarded
var starting_currency: int = 0  # Track starting coins to calculate earned coins

# Game state
var is_game_over: bool = false
var is_game_won: bool = false

# Popup scenes
var game_over_scene: PackedScene = preload("res://scenes/game_over_scene.tscn")
var you_win_scene: PackedScene = preload("res://scenes/you_win_screen.tscn")
var pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
var game_over_popup: Control = null
var you_win_popup: Control = null
var pause_menu_popup: Control = null

# Metro system
var metro_scene: PackedScene = preload("res://scenes/metro.tscn")
var metro_cooldown_timer: float = 0.0
var metro_cooldown_duration: float = 10.0  # 10 seconds cooldown
var is_metro_on_cooldown: bool = false
@onready var metro_button = get_node_or_null("CanvasLayer/metroButton")

# Performance optimization
var camera_update_timer: float = 0.0
var camera_update_interval: float

# Music
@onready var game_music: AudioStreamPlayer = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Reset shooter level to starter level at the beginning of each level
	Global.shooter_level = Global.shooter_starter_level
	
	# Print shooter level at the start
	print("🎮 SHOOTER LEVEL: ", Global.shooter_level)
	
	# Set this node to always process even when paused (so we can detect ESC to unpause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set all game object nodes to PAUSABLE mode
	_setup_pause_modes()
	
	# Setup game music
	game_music = get_node_or_null("GameMusic")
	if game_music:
		game_music.play()
		print("🎵 Game music started playing")
	
	# Get values from config safely and cache for performance
	var config = Global.get_config()
	camera_follow_speed = config.camera_follow_speed
	camera_dead_zone = config.camera_dead_zone
	camera_update_interval = config.update_frequency_reduction
	
	# Set level-specific currency per second
	if current_level == 0:  # Level 1
		currency_per_second = 2  # Default level 1 value
	elif current_level == 1:  # Level 2
		currency_per_second = config.level2_currency_per_second
	else:
		currency_per_second = 2  # Default fallback
	
	print("💰 Currency system initialized for Level ", current_level + 1, " - ", currency_per_second, " coins/second")
	
	# Cache frequently used values for better performance
	cached_camera_follow_speed = camera_follow_speed
	cached_camera_dead_zone = camera_dead_zone
	
	# Initialize pool manager as singleton if it doesn't exist
	var pool_manager = get_node_or_null("/root/PoolManager")
	if not pool_manager:
		pool_manager = preload("res://scrpits/PoolManager.gd").new()
		pool_manager.name = "PoolManager"
		get_tree().root.add_child(pool_manager)
		print("✅ PoolManager created as singleton")
	else:
		# Pool manager already exists, reinitialize it for the new scene
		pool_manager._setup_pools()
		print("↻ PoolManager reinitialized for new scene")
	
	# Clean up any invalid objects that might exist from previous scenes
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
	
	# Setup metro button
	if metro_button:
		metro_button.pressed.connect(_on_metro_button_pressed)
		_update_metro_button()
		print("🚇 Metro button connected")
	
	# Connect to Global signals for metro
	Global.currency_changed.connect(_on_currency_changed_for_metro)
	Global.metro_purchased_signal.connect(_update_metro_button)

func _setup_pause_modes():
	# Set all game object nodes to PAUSABLE so they stop when the game is paused
	# mainScene itself is ALWAYS so it can handle pause input
	var pausable_nodes = [
		"adders",           # Shooter spawner
		"boxes",            # Box spawner
		"shooterSpawnArea", # Shooter area
		"enemySpawnerArea", # Enemy spawner
		"enemy_hit_spot",   # Hit detection
		"ground"            # Just to be safe
	]
	
	for node_name in pausable_nodes:
		var node = get_node_or_null(node_name)
		if node:
			node.process_mode = Node.PROCESS_MODE_PAUSABLE
			print("✅ Set ", node_name, " to PAUSABLE mode")
	
	# Keep game music playing when paused (optional - set to PAUSABLE if you want it to stop)
	if game_music:
		game_music.process_mode = Node.PROCESS_MODE_ALWAYS
		print("✅ Set GameMusic to ALWAYS mode (continues during pause)")

# Performance optimization: Cache config values and reduce update frequency
var cached_camera_follow_speed: float
var cached_camera_dead_zone: float

func _process(delta):
	# Don't update game if it's over or won (but still allow pause)
	if is_game_over or is_game_won:
		return
	
	# Update camera every frame for smooth following
	_update_camera(delta)
	
	# Time-based currency system
	_update_currency_system(delta)
	
	# Update metro cooldown
	_update_metro_cooldown(delta)
	
	# Display level progress (simple console output for now) - already optimized with timer
	if wave_manager:
		_display_level_progress()

func _input(event):
	# Handle pause input (works even when game is paused because mainScene has PROCESS_MODE_ALWAYS)
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause_menu()
		get_viewport().set_input_as_handled()
	
	# Debug cheat: Press G to add 1000 gold (for testing)
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		Global.add_currency(1000)
		print("💰 DEBUG: Added 1000 gold! Total: ", Global.currency)

func _update_camera(delta: float):
	# Don't update camera if paused
	if get_tree().paused:
		return
	
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
	# Don't update currency if paused
	if get_tree().paused:
		return
	
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


func _on_pause_pressed():
	toggle_pause_menu()

func toggle_pause_menu():
	if pause_menu_popup:
		# Close pause menu
		close_pause_menu()
	else:
		# Open pause menu
		show_pause_menu()

func show_pause_menu():
	if pause_menu_popup or is_game_over or is_game_won:
		return  # Don't show if already showing or if game ended
	
	# Create and add the pause menu popup
	pause_menu_popup = pause_menu_scene.instantiate()
	add_child(pause_menu_popup)
	
	# Connect close signal if available
	if pause_menu_popup.has_signal("close_requested"):
		pause_menu_popup.close_requested.connect(close_pause_menu)
	
	# Pause game (but keep rendering)
	get_tree().paused = true
	pause_menu_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("⏸️ Game paused - Pause menu displayed")

func close_pause_menu():
	if pause_menu_popup:
		pause_menu_popup.queue_free()
		pause_menu_popup = null
		get_tree().paused = false
		print("▶️ Game resumed")


func _on_metro_button_pressed():
	print("🚇 Metro button pressed")
	
	# Check if metro is purchased
	if not Global.metro_purchased:
		print("⚠️ Metro power not purchased yet! Buy it in Shop 2")
		return
	
	# Check if on cooldown
	if is_metro_on_cooldown:
		print("⚠️ Metro is on cooldown! Wait ", ceil(metro_cooldown_timer), " seconds")
		return
	
	# Start cooldown IMMEDIATELY to prevent multiple activations
	is_metro_on_cooldown = true
	metro_cooldown_timer = metro_cooldown_duration
	_update_metro_button()
	
	# Spawn metro (FREE - already paid for it in the shop!)
	spawn_metro()
	
	print("🚇 Metro activated! (Free use - already purchased)")

func spawn_metro():
	"""Spawn a metro that travels from shooters to enemy spawn area"""
	if not spawn_area or not enemy_spawner_area:
		print("⚠️ Cannot spawn metro - missing spawn areas")
		return
	
	# Instantiate metro
	var metro = metro_scene.instantiate()
	add_child(metro)
	
	# Get positions
	#var start_pos = spawn_area.global_position
	#start_pos.z -= 5.0  # Spawn behind the shooters
	#start_pos.x += 7.0  
	var start_pos = Vector3(7, 1, 0)

	
	#var end_pos = enemy_spawner_area.global_position
	#end_pos.z += 8.0  # Go past the enemy spawn area
	#end_pos.x += 7.0
	var end_pos = Vector3(7, 1, -50)  
	
	# Setup metro with positions
	if metro.has_method("setup_metro"):
		metro.setup_metro(start_pos, end_pos)
	
	print("🚇 Metro spawned from ", start_pos, " to ", end_pos)

func _update_metro_cooldown(delta: float):
	"""Update metro cooldown timer"""
	if not is_metro_on_cooldown:
		return
	
	metro_cooldown_timer -= delta
	
	if metro_cooldown_timer <= 0.0:
		is_metro_on_cooldown = false
		metro_cooldown_timer = 0.0
		_update_metro_button()
		print("🚇 Metro ready!")
	else:
		# Update button text with remaining cooldown
		_update_metro_button()

func _update_metro_button():
	"""Update metro button state based on purchase status and cooldown"""
	if not metro_button:
		return
	
	# Check if metro is purchased
	if not Global.metro_purchased:
		metro_button.disabled = true
		metro_button.text = "NOT OWNED"
		metro_button.modulate = Color.GRAY
		return
	
	# Check if on cooldown
	if is_metro_on_cooldown:
		metro_button.disabled = true
		metro_button.text = "COOLDOWN: " + str(ceil(metro_cooldown_timer)) + "s"
		metro_button.modulate = Color.ORANGE
		return
	
	# Ready to use (free!)
	metro_button.disabled = false
	metro_button.text = "METRO READY"
	metro_button.modulate = Color.GREEN

func _on_currency_changed_for_metro(new_amount: int):
	"""Update metro button when currency changes"""
	_update_metro_button()
