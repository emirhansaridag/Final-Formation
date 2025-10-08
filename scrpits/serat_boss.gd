extends Node3D

var max_health: float
var health: float
var speed: float

# Pool management
var is_pooled: bool = false

# Boss-specific properties
var is_boss: bool = true
var boss_damage_multiplier: float = 2.0
var boss_health_multiplier: float = 3.0

# Performance optimization
var update_timer: float = 0.0
var update_interval: float
var lod_level: int = 0
var lod_distance_threshold: float

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	max_health = config.enemy_base_health * boss_health_multiplier  # 3x health for Serat Boss
	health = max_health
	speed = config.enemy_move_speed * 0.8  # Slightly slower than regular enemies
	update_interval = config.update_frequency_reduction
	lod_distance_threshold = config.lod_distance_threshold
	
	# Set boss scale from config
	scale = config.serat_boss_scale  # Use dedicated Serat Boss scale
	
	# Store this scale as the "original" for pooling
	set_meta("original_scale", scale)
	
	# Debug: Print boss info
	print("🔥 Serat Boss spawned - Health: ", max_health, " Speed: ", speed, " Scale: ", scale)
	
	# Start Serat Boss animation
	start_animation()
	
	# Initial LOD calculation
	_update_lod()
	
func _process(delta):
	# Move every frame for smooth movement
	global_position.z += speed * delta
	
	# Update LOD and other expensive operations less frequently
	update_timer += delta
	var actual_update_interval = update_interval * (lod_level + 1)
	
	if update_timer >= actual_update_interval:
		update_timer = 0.0
		
		# Update LOD less frequently
		if randf() < 0.05:
			_update_lod()

func _update_lod():
	var camera = get_viewport().get_camera_3d()
	if camera:
		var distance_to_camera = global_position.distance_to(camera.global_position)
		
		if distance_to_camera > lod_distance_threshold * 2:
			lod_level = 2
		elif distance_to_camera > lod_distance_threshold:
			lod_level = 1
		else:
			lod_level = 0
		
		_apply_visual_lod()

func _on_area_3d_area_entered(area):
	var damage = Global.get_current_damage()
	take_damage(damage)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		_on_death()

func _on_death():
	# Track kill (no currency reward)
	Global.add_enemy_kill()
	
	print("🎉 Serat Boss defeated!")
	_cleanup_enemy()

func _cleanup_enemy():
	if is_pooled:
		var pool_manager = get_node_or_null("/root/PoolManager")
		if pool_manager and pool_manager.has_method("return_enemy"):
			pool_manager.return_enemy(self)
		else:
			queue_free()
	else:
		queue_free()

func _apply_visual_lod():
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
	
	if has_meta("original_scale"):
		scale = get_meta("original_scale")
	else:
		scale = Vector3.ONE
	
	set_process_priority(0)

func reset_stats():
	health = max_health
	update_timer = 0.0
	lod_level = 0
	global_rotation = Vector3.ZERO
	
	if has_meta("original_scale"):
		var original_scale = get_meta("original_scale")
		scale = original_scale
	else:
		scale = Vector3.ONE
	
	_update_lod()

func cleanup():
	reset_object()

func set_pooled(pooled: bool):
	is_pooled = pooled

# Start Serat Boss animation
func start_animation():
	var animation_player = find_animation_player()
	if animation_player:
		animation_player.play("run")  # Serat Boss animation
		# In Godot 4, we get the animation and set its loop mode
		var animation_library = animation_player.get_animation_library("")
		if animation_library and animation_library.has_animation("run"):
			var animation = animation_library.get_animation("run")
			animation.loop_mode = Animation.LOOP_LINEAR
		print("Serat Boss animation 'run' started")
	else:
		print("Warning: No AnimationPlayer found for Serat Boss")

# Helper function to find AnimationPlayer in the scene tree
func find_animation_player() -> AnimationPlayer:
	# Look for AnimationPlayer as direct child
	for child in get_children():
		if child is AnimationPlayer:
			return child
	
	# Look deeper in the tree if needed
	return find_child("AnimationPlayer", true, false)
