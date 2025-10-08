extends CharacterBody3D

var speed: float
var dir: float
var spawn_pos: Vector3
var spawn_rot: Vector3
var lifetime_timer: float = 0.0
var max_lifetime: float

# Pool management
var is_pooled: bool = false

func _ready():
	# Get speed from config safely
	var config = Global.get_config()
	speed = config.projectile_speed
	max_lifetime = config.projectile_lifetime
	
	global_position = spawn_pos
	global_rotation = spawn_rot
	
func _physics_process(delta):
	velocity = Vector3(0, 0, -speed).rotated(Vector3.UP, dir)
	move_and_slide()
	
	# Handle lifetime
	lifetime_timer += delta
	if lifetime_timer >= max_lifetime:
		_cleanup_projectile()

func _on_timer_timeout():
	_cleanup_projectile()

func _on_area_3d_area_entered(area):
	_cleanup_projectile()

# Reset object state for pooling
func reset_object():
	lifetime_timer = 0.0
	velocity = Vector3.ZERO
	dir = 0.0
	spawn_pos = Vector3.ZERO
	spawn_rot = Vector3.ZERO
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO
	
	# Ensure projectile is completely stopped
	if has_method("set_velocity"):
		set_velocity(Vector3.ZERO)
	
	# Use original scale from scene if available
	if has_meta("original_scale"):
		scale = get_meta("original_scale")
	else:
		scale = Vector3.ONE

# Clean up when no longer needed
func cleanup():
	reset_object()

func _cleanup_projectile():
	if is_pooled:
		# Return to pool instead of freeing
		var pool_manager = get_node_or_null("/root/PoolManager")
		if pool_manager and pool_manager.has_method("return_projectile"):
			pool_manager.return_projectile(self)
		else:
			# Fallback if pool manager not available
			queue_free()
	else:
		queue_free()

# Called by pool manager to mark as pooled
func set_pooled(pooled: bool):
	is_pooled = pooled

# Set projectile properties (called when spawning from pool)
func setup(spawn_position: Vector3, spawn_rotation: Vector3, direction: float):
	spawn_pos = spawn_position
	spawn_rot = spawn_rotation
	dir = direction
	global_position = spawn_position
	global_rotation = spawn_rotation
	lifetime_timer = 0.0
	
	# Update speed and lifetime from current config (important for pooled objects)
	var config = Global.get_config()
	speed = config.projectile_speed
	max_lifetime = config.projectile_lifetime
