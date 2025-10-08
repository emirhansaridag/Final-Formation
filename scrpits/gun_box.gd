extends Area3D

var speed: float
var max_health: float
var health: float

# Pool management
var is_pooled: bool = false
var is_destroyed: bool = false

# Performance optimization
var update_timer: float = 0.0
var update_interval: float

func _ready():
	# Get values from config safely
	var config = Global.get_config()
	speed = config.gun_box_speed
	max_health = config.gun_box_health
	health = max_health
	update_interval = config.update_frequency_reduction
	
func _process(delta):
	# Move every frame for smooth movement
	global_position.z += speed * delta
	
	# Other non-critical updates can be throttled
	update_timer += delta
	if update_timer >= update_interval:
		# Place any expensive non-movement operations here if needed
		update_timer = 0.0

func _on_area_entered(area):
	# Prevent multiple hits on already destroyed gun box
	if is_destroyed:
		print("🚫 Ignoring hit on already destroyed gun box")
		return
	
	# Debug: log what's hitting the gun box
	print("💥 Gun box hit by: ", area.get_parent().name if area.get_parent() else "unknown")
		
	var damage = Global.get_current_damage()
	take_damage(damage)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		_on_destruction()

func _on_destruction():
	# Prevent multiple destructions
	if is_destroyed:
		return
		
	is_destroyed = true
	print("Gun box destroyed!")
	if Global.get_current_max_shooter_level() != Global.shooter_level:
		Global.upgrade_shooter_level()
		print("Level after: ", Global.shooter_level)
	
	# No currency reward for gun box
	
	_cleanup_gun_box()

func _cleanup_gun_box():
	if is_pooled:
		# Return to pool instead of freeing
		var pool_manager = get_node_or_null("/root/PoolManager")
		if pool_manager and pool_manager.has_method("return_gun_box"):
			pool_manager.return_gun_box(self)
		else:
			# Fallback if pool manager not available
			queue_free()
	else:
		queue_free()

func _on_timer_timeout():
	_cleanup_gun_box()

# Reset object state for pooling
func reset_object():
	health = max_health
	update_timer = 0.0
	is_destroyed = false  # Reset destruction flag
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		scale = get_meta("original_scale")
	else:
		scale = Vector3.ONE

# Reset stats (called by pool manager)
func reset_stats():
	health = max_health
	update_timer = 0.0
	is_destroyed = false  # Reset destruction flag
	global_rotation = Vector3.ZERO
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		scale = get_meta("original_scale")
	else:
		scale = Vector3.ONE

# Clean up when no longer needed
func cleanup():
	reset_object()

# Called by pool manager to mark as pooled
func set_pooled(pooled: bool):
	is_pooled = pooled
