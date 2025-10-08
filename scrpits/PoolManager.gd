extends Node

# Object pools for different entity types
var projectile_pool: ObjectPool
var enemy_pool: ObjectPool
var gun_box_pool: ObjectPool

var config: GameConfig
var pools_ready: bool = false

func _ready():
	# Get configuration safely
	config = Global.get_config()
	
	# Delay pool initialization until scene is fully ready
	call_deferred("_setup_pools")

func _setup_pools():
	# Ensure we have a valid current scene before creating pools
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("⚠️ No current scene available, retrying pool setup...")
		call_deferred("_setup_pools")
		return
		
	print("🏊 Setting up object pools with scene: ", current_scene.name)
	
	# Create projectile pool with smaller initial sizes to reduce startup lag
	var projectile_scene = preload("res://scenes/projectile.tscn")
	projectile_pool = ObjectPool.new(projectile_scene, 5, config.max_projectiles)  # Start with just 5
	projectile_pool.initialize(current_scene)
	add_child(projectile_pool)
	
	# Create enemy pool
	var enemy_scene = preload("res://scenes/enemy.tscn")
	enemy_pool = ObjectPool.new(enemy_scene, 3, config.max_enemies)  # Start with just 3
	enemy_pool.initialize(current_scene)
	add_child(enemy_pool)
	
	# Create gun box pool
	var gun_box_scene = preload("res://scenes/gun_box.tscn")
	gun_box_pool = ObjectPool.new(gun_box_scene, 2, 20)  # Start with just 2
	gun_box_pool.initialize(current_scene)
	add_child(gun_box_pool)
	
	pools_ready = true
	print("✅ Object pools initialized successfully")

# Projectile pool methods
func spawn_projectile(position: Vector3, rotation: Vector3, direction: float) -> Node:
	if not pools_ready or not projectile_pool:
		print("⚠️ Projectile pool not ready yet")
		return null
		
	var projectile = projectile_pool.get_object()
	if projectile:
		# Use the setup method if available, otherwise set properties directly
		if projectile.has_method("setup"):
			projectile.setup(position, rotation, direction)
		else:
			projectile.global_position = position
			projectile.global_rotation = rotation
			projectile.dir = direction
			# Make sure speed is updated from config for fallback case
			projectile.speed = config.projectile_speed
			projectile.max_lifetime = config.projectile_lifetime
	
	return projectile

func return_projectile(projectile: Node):
	projectile_pool.return_object(projectile)

# Enemy pool methods
func spawn_enemy(position: Vector3) -> Node:
	if not pools_ready or not enemy_pool:
		print("⚠️ Enemy pool not ready yet")
		return null
		
	var enemy = enemy_pool.get_object()
	if enemy:
		enemy.global_position = position
		# Reset enemy health and stats
		if enemy.has_method("reset_stats"):
			enemy.reset_stats()
		# Don't use tree_exited signals - they can cause issues with pooling
	
	return enemy

func return_enemy(enemy: Node):
	enemy_pool.return_object(enemy)

# Gun box pool methods  
func spawn_gun_box(position: Vector3) -> Node:
	if not pools_ready or not gun_box_pool:
		print("⚠️ Gun box pool not ready yet")
		return null
		
	var gun_box = gun_box_pool.get_object()
	if gun_box:
		gun_box.global_position = position
		# Reset gun box health
		if gun_box.has_method("reset_stats"):
			gun_box.reset_stats()
		# Don't use tree_exited signals - they can cause issues with pooling
	
	return gun_box

func return_gun_box(gun_box: Node):
	gun_box_pool.return_object(gun_box)

# Cleanup handlers - removed to prevent signal connection issues

# Utility methods
func get_pool_stats() -> Dictionary:
	return {
		"projectiles": {
			"active": projectile_pool.get_active_count(),
			"available": projectile_pool.get_available_count(),
			"total": projectile_pool.get_total_count()
		},
		"enemies": {
			"active": enemy_pool.get_active_count(),
			"available": enemy_pool.get_available_count(), 
			"total": enemy_pool.get_total_count()
		},
		"gun_boxes": {
			"active": gun_box_pool.get_active_count(),
			"available": gun_box_pool.get_available_count(),
			"total": gun_box_pool.get_total_count()
		}
	}

func cleanup_all():
	projectile_pool.return_all_objects()
	enemy_pool.return_all_objects()
	gun_box_pool.return_all_objects()

# Clean up invalid objects and prepare for scene transition
func prepare_for_scene_change():
	if projectile_pool:
		projectile_pool.prepare_for_scene_change()
	if enemy_pool:
		enemy_pool.prepare_for_scene_change()
	if gun_box_pool:
		gun_box_pool.prepare_for_scene_change()

# Clean up invalid objects from all pools
func cleanup_invalid_objects():
	if projectile_pool:
		projectile_pool.cleanup_invalid_objects()
	if enemy_pool:
		enemy_pool.cleanup_invalid_objects()
	if gun_box_pool:
		gun_box_pool.cleanup_invalid_objects()
