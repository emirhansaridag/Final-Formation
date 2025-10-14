extends Node3D

# Metro configuration
@export var metro_speed: float = 30.0  # Pretty fast movement
var target_position: Vector3
var has_target: bool = false

# Track enemies hit to avoid double-hitting
var enemies_hit: Array = []

func _ready():
	# Add Area3D for collision detection if not already in scene
	var area = get_node_or_null("Area3D")
	if not area:
		# Create Area3D if it doesn't exist
		print("⚠️ Creating Area3D for metro collision detection...")
		area = Area3D.new()
		area.name = "Area3D"
		add_child(area)
		
		# Create collision shape
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(5, 3, 8)  # Wide enough to catch enemies
		collision_shape.shape = box_shape
		area.add_child(collision_shape)
		
		# Set collision layers - should detect enemies
		area.collision_layer = 0  # Metro doesn't block anything
		area.collision_mask = 16  # Detect layer 16 (enemies) - matches enemy collision layer
		area.monitoring = true
		area.monitorable = false
		
		print("✅ Metro Area3D created automatically")
	
	# Connect signals
	if not area.body_entered.is_connected(_on_body_entered):
		area.body_entered.connect(_on_body_entered)
	if not area.area_entered.is_connected(_on_area_entered):
		area.area_entered.connect(_on_area_entered)
	
	print("🚇 Metro collision detection active")

func setup_metro(start_pos: Vector3, end_pos: Vector3):
	"""Initialize the metro with start and end positions"""
	global_position = start_pos
	target_position = end_pos
	has_target = true
	
	# Rotate metro to face the target direction
	var direction = (target_position - global_position).normalized()
	if direction.length() > 0:
		look_at(global_position + direction, Vector3.UP)
	
	print("🚇 Metro spawned at ", start_pos, " heading to ", end_pos)

func _process(delta):
	if not has_target:
		return
	
	# Move towards target
	var direction = (target_position - global_position).normalized()
	var movement = direction * metro_speed * delta
	global_position += movement
	
	# Check if reached target (or passed it)
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < 1.0:  # Close enough to target
		print("🚇 Metro reached destination - despawning")
		queue_free()

func _on_body_entered(body: Node3D):
	"""Handle collision with enemy bodies (Node3D)"""
	_handle_enemy_collision(body)

func _on_area_entered(area: Area3D):
	"""Handle collision with enemy areas (Area3D)"""
	_handle_enemy_collision(area.get_parent())

func _handle_enemy_collision(node: Node):
	"""Kill enemy on contact"""
	if not node:
		return
	
	# Debug: Print what we're colliding with
	print("🚇 Metro collided with: ", node.name, " | Type: ", node.get_class(), " | In enemy group: ", node.is_in_group("enemy"))
	
	# Avoid hitting the same enemy twice
	if node in enemies_hit:
		return
	
	# Check if it's an enemy (they're in the "enemy" group)
	if node.is_in_group("enemy"):
		print("🚇💥 Metro HIT ENEMY: ", node.name)
		enemies_hit.append(node)
		
		# Kill the enemy instantly with massive damage
		# This respects the pooling system and proper cleanup
		if node.has_method("take_damage"):
			node.take_damage(999999)  # Massive damage triggers death properly
			print("✅ Enemy killed via take_damage()")
		else:
			# Fallback for any enemy without take_damage method
			print("⚠️ Enemy has no take_damage() - using queue_free()")
			node.queue_free()

func _exit_tree():
	# Cleanup
	enemies_hit.clear()
	print("🚇 Metro despawned")
