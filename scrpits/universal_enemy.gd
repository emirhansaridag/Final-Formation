extends Node3D

## Universal Enemy Script
## Configure these values in the Inspector for each enemy type

# Enemy configuration - adjust these in the Inspector for each enemy instance
@export_group("Enemy Stats")
@export var health_multiplier: float = 1.0  ## Multiplier for base enemy health (e.g., 1.0 for regular, 4.0 for bosses)
@export var speed_multiplier: float = 1.0  ## Multiplier for base enemy speed (e.g., 1.0 for normal, 0.5 for slow)
@export var enemy_scale: Vector3 = Vector3.ONE  ## Scale of the enemy model

@export_group("Enemy Type")
@export var is_boss: bool = false  ## Is this a boss enemy?
@export var enemy_name: String = "Enemy"  ## Name for debug messages

@export_group("Animation")
@export var animation_name: String = "ArmatureAction"  ## Name of the animation to play
@export var animation_fallbacks: Array[String] = []  ## Fallback animation names to try if primary fails

# Internal variables
var max_health: float
var health: float
var speed: float

# Pool management
var is_pooled: bool = false

# Performance optimization
var update_timer: float = 0.0
var update_interval: float
var lod_level: int = 0  # 0 = high detail, 1 = medium, 2 = low
var lod_distance_threshold: float

# Cache for performance
var cached_config: GameConfig
var cached_damage: float = 10.0
var damage_update_timer: float = 0.0
var lod_update_timer: float = 0.0
var lod_update_interval: float = 2.0  # Update LOD only every 2 seconds

func _ready():
	# Add to enemy group for collision detection
	add_to_group("enemy")
	
	# Get values from config safely and cache for performance
	cached_config = Global.get_config()
	
	# Apply enemy scale from exported variable
	scale = enemy_scale
	set_meta("original_scale", enemy_scale)
	
	# Calculate stats using exported multipliers
	max_health = cached_config.enemy_base_health * health_multiplier
	health = max_health
	speed = cached_config.enemy_move_speed * speed_multiplier
	update_interval = cached_config.update_frequency_reduction
	lod_distance_threshold = cached_config.lod_distance_threshold
	
	# Debug: Print enemy info
	if is_boss:
		print("🔥 %s spawned - Health: %d, Speed: %.2f, Scale: %s" % [enemy_name, max_health, speed, scale])
	else:
		print("👾 %s spawned - Health: %d, Speed: %.2f, Scale: %s" % [enemy_name, max_health, speed, scale])
	
	# Start animation
	start_animation()
	
	# Initial LOD calculation
	_update_lod()

func _process(delta):
	# Move every frame for smooth movement
	global_position.z += speed * delta
	
	# Update LOD and other expensive operations much less frequently
	update_timer += delta
	var actual_update_interval = update_interval * (lod_level + 1)  # Slower updates for higher LOD levels
	
	if update_timer >= actual_update_interval:
		update_timer = 0.0
		
		# Update LOD much less frequently - only every 2 seconds
		lod_update_timer += actual_update_interval
		if lod_update_timer >= lod_update_interval:
			lod_update_timer = 0.0
			_update_lod()

func _update_lod():
	var camera = get_viewport().get_camera_3d()
	if camera:
		var distance_to_camera = global_position.distance_to(camera.global_position)
		
		if distance_to_camera > lod_distance_threshold * 2:
			lod_level = 2  # Low detail - very slow updates
		elif distance_to_camera > lod_distance_threshold:
			lod_level = 1  # Medium detail - slower updates
		else:
			lod_level = 0  # High detail - normal updates
		
		# Adjust visual quality based on LOD
		_apply_visual_lod()

func _on_area_3d_area_entered(area):
	# Use cached damage value for better performance
	take_damage(cached_damage)
	
	# Update cached damage occasionally (every 5 seconds)
	damage_update_timer += get_process_delta_time()
	if damage_update_timer >= 5.0:
		cached_damage = Global.get_current_damage()
		damage_update_timer = 0.0

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		_on_death()

func _on_death():
	# Track kill (no currency reward)
	Global.add_enemy_kill()
	
	# Death message
	if is_boss:
		print("🎉 %s defeated!" % enemy_name)
	
	_cleanup_enemy()

func _cleanup_enemy():
	if is_pooled:
		# Return to pool instead of freeing
		var pool_manager = get_node_or_null("/root/PoolManager")
		if pool_manager and pool_manager.has_method("return_enemy"):
			pool_manager.return_enemy(self)
		else:
			# Fallback if pool manager not available  
			queue_free()
	else:
		queue_free()

func _apply_visual_lod():
	# Apply visual changes based on LOD level
	match lod_level:
		0:  # High detail
			set_process_priority(0)
		1:  # Medium detail  
			set_process_priority(-1)
		2:  # Low detail
			set_process_priority(-2)

# Reset object state for pooling
func reset_object():
	# Ensure enemy is in the group (in case it was removed)
	if not is_in_group("enemy"):
		add_to_group("enemy")
	
	health = max_health
	update_timer = 0.0
	lod_level = 0
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		scale = get_meta("original_scale")
	else:
		scale = Vector3.ONE
	
	set_process_priority(0)

# Reset stats (called by pool manager)
func reset_stats():
	# Ensure enemy is in the group (in case it was removed)
	if not is_in_group("enemy"):
		add_to_group("enemy")
	
	health = max_health
	update_timer = 0.0
	lod_level = 0
	global_rotation = Vector3.ZERO
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		var original_scale = get_meta("original_scale")
		scale = original_scale
	else:
		scale = Vector3.ONE
	
	_update_lod()

# Clean up when no longer needed
func cleanup():
	reset_object()

# Called by pool manager to mark as pooled
func set_pooled(pooled: bool):
	is_pooled = pooled

# Start appropriate animation based on exported animation_name
func start_animation():
	var animation_player = find_animation_player()
	if not animation_player:
		print("⚠️ No AnimationPlayer found for %s" % enemy_name)
		return
	
	# Try the primary animation name first
	if _try_play_animation(animation_player, animation_name):
		print("🎬 Playing animation '%s' for %s" % [animation_name, enemy_name])
		return
	
	# Try fallback animations
	for fallback_name in animation_fallbacks:
		if _try_play_animation(animation_player, fallback_name):
			print("🎬 Playing fallback animation '%s' for %s" % [fallback_name, enemy_name])
			return
	
	# If nothing worked, list available animations for debugging
	var animation_library = animation_player.get_animation_library("")
	if animation_library:
		print("⚠️ No suitable animation found for %s. Available animations: %s" % [enemy_name, animation_library.get_animation_list()])

# Helper to try playing an animation
func _try_play_animation(animation_player: AnimationPlayer, anim_name: String) -> bool:
	var animation_library = animation_player.get_animation_library("")
	if animation_library and animation_library.has_animation(anim_name):
		animation_player.play(anim_name)
		var animation = animation_library.get_animation(anim_name)
		animation.loop_mode = Animation.LOOP_LINEAR
		return true
	return false

# Helper function to find AnimationPlayer in the scene tree
func find_animation_player() -> AnimationPlayer:
	# Look for AnimationPlayer as direct child
	for child in get_children():
		if child is AnimationPlayer:
			return child
	
	# Look deeper in the tree if needed
	return find_child("AnimationPlayer", true, false)
