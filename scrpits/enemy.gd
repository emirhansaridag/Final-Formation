extends Node3D

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

func _ready():
	# Get values from config safely and cache for performance
	cached_config = Global.get_config()
	max_health = cached_config.enemy_base_health
	health = max_health
	speed = cached_config.enemy_move_speed
	update_interval = cached_config.update_frequency_reduction
	lod_distance_threshold = cached_config.lod_distance_threshold
	
	# Set enemy scale from config - CHANGE IN GameConfig.gd TO ADJUST SIZE
	scale = cached_config.enemy_scale
	
	# Store this scale as the "original" for pooling
	set_meta("original_scale", scale)
	
	# Start animation for stickman
	start_animation()
	
	# Initial LOD calculation
	_update_lod()
	
# Performance optimization: Cache expensive lookups and reduce LOD updates
var cached_config: GameConfig
var lod_update_timer: float = 0.0
var lod_update_interval: float = 2.0  # Update LOD only every 2 seconds

func _process(delta):
	# Move every frame for smooth movement
	global_position.z += speed * delta
	
	# Update LOD and other expensive operations much less frequently
	update_timer += delta
	var actual_update_interval = update_interval * (lod_level + 1)  # Slower updates for higher LOD levels
	
	if update_timer >= actual_update_interval:
		update_timer = 0.0
		
		# Update LOD much less frequently - only every 2 seconds instead of random chance
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
		
		# Adjust visual quality based on LOD (if you have mesh LOD variants)
		_apply_visual_lod()

# Cache damage value and update less frequently
var cached_damage: float = 10.0
var damage_update_timer: float = 0.0

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
	# This is where you would switch between different mesh LOD variants
	# For now, we'll just adjust the process priority
	match lod_level:
		0:  # High detail
			set_process_priority(0)
		1:  # Medium detail  
			set_process_priority(-1)
		2:  # Low detail
			set_process_priority(-2)

# Reset object state for pooling
func reset_object():
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
	health = max_health
	update_timer = 0.0
	lod_level = 0
	global_rotation = Vector3.ZERO
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		var original_scale = get_meta("original_scale")
		scale = original_scale
		print("Enemy reset_stats: Using stored scale: ", original_scale)
	else:
		scale = Vector3.ONE
		print("Enemy reset_stats: No stored scale, using Vector3.ONE")
	
	_update_lod()

# Clean up when no longer needed
func cleanup():
	reset_object()

# Called by pool manager to mark as pooled
func set_pooled(pooled: bool):
	is_pooled = pooled

# Start appropriate animation based on enemy type
func start_animation():
	var animation_player = find_animation_player()
	if animation_player:
		animation_player.play("ArmatureAction")  # Stickman animation
		# In Godot 4, we get the animation and set its loop mode
		var animation_library = animation_player.get_animation_library("")
		if animation_library and animation_library.has_animation("ArmatureAction"):
			var animation = animation_library.get_animation("ArmatureAction")
			animation.loop_mode = Animation.LOOP_LINEAR
	else:
		print("Warning: No AnimationPlayer found for stickman")

# Helper function to find AnimationPlayer in the scene tree
func find_animation_player() -> AnimationPlayer:
	# Look for AnimationPlayer as direct child
	for child in get_children():
		if child is AnimationPlayer:
			return child
	
	# Look deeper in the tree if needed
	return find_child("AnimationPlayer", true, false)
