extends Area3D

var speed = 4  # Movement speed in units per second

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect both area_entered and body_entered signals to detect collisions
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move in the positive X direction
	global_position.z += speed * delta

# Called when an area enters the collision area (for Area3D to Area3D detection)
func _on_area_entered(area):
	# Check if the colliding area is the shooter spawn area
	if area.name == "shooterSpawnArea":
		# Spawn new shooter in the area
		spawn_shooter_in_area(area)
		# Delete this shooter_adder
		queue_free()

# Called when a body enters the collision area (for Area3D to Body3D detection)
func _on_body_entered(body):
	print("Spawner detected body: ", body.name, " Type: ", body.get_class())
	# Check if the colliding body is the clickable area (StaticBody3D)
	if body.name == "ClickableArea":
		# Get the spawn area (parent of the ClickableArea)
		var spawn_area = body.get_parent()  # Get the parent Area3D
		if spawn_area and spawn_area.name == "shooterSpawnArea":
			# Spawn new shooter in the area
			spawn_shooter_in_area(spawn_area)
			# Delete this shooter_adder
			queue_free()


# Function to spawn one shooter in the area
func spawn_shooter_in_area(spawn_area):
	# Check if the spawn area has space BEFORE creating shooter
	if spawn_area.has_method("add_spawned_shooter"):
		# Get current shooter count directly from the spawn area
		var current_count = spawn_area.shooters_in_area.size()
		var max_count = spawn_area.max_shooters
		
		# Only spawn if there's space
		if current_count >= max_count:
			print("Spawn area is full (", current_count, "/", max_count, "), cannot spawn new shooter")
			return
	
	# Get the shooter scene resource
	var shooter_scene = preload("res://scenes/emirhan_shooter.tscn")
	
	# Instance the new shooter
	var new_shooter = shooter_scene.instantiate()
	
	# Add it to the spawn area
	spawn_area.add_child(new_shooter)
	
	# Position the new shooter using safe spawn positioning
	if spawn_area.has_method("find_safe_spawn_position"):
		new_shooter.position = spawn_area.find_safe_spawn_position()
	else:
		# Fallback to random positioning if method not available
		var area_bounds = Vector2(5, 5)  # Width and depth of the spawn area
		var random_x = randf_range(-area_bounds.x/2, area_bounds.x/2)
		var random_z = randf_range(-area_bounds.y/2, area_bounds.y/2)
		new_shooter.position = Vector3(random_x, 0, random_z)
	
	# Tell the shooter it's in an area and give it a reference to the spawn area
	if new_shooter.has_method("set_in_area"):
		new_shooter.set_in_area(true, spawn_area)
	
	# Register the shooter with the area
	if spawn_area.has_method("add_spawned_shooter"):
		spawn_area.add_spawned_shooter(new_shooter)

func _on_timer_timeout():
	queue_free()
