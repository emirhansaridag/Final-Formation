extends Area3D

var shooter_scene = preload("res://scenes/emirhan_shooter.tscn")
var shooters_in_area = []  # Array to track all shooters in this area

# Configuration from Global
var area_bounds: Vector2
var max_shooters: int
var ground_min_x: float
var ground_max_x: float

# Area dragging variables - optimized for smoother movement
var is_dragging = false
var drag_start_position = Vector3.ZERO
var drag_start_mouse_position = Vector2.ZERO
var last_mouse_position = Vector2.ZERO
var mouse_velocity = Vector2.ZERO
var speed: float

# Performance optimization for dragging
var drag_target_x: float = 0.0
var has_drag_target: bool = false
var drag_update_timer: float = 0.0
var drag_update_interval: float = 0.033  # Update drag target 30 times per second for smoother dragging

# Visual feedback
var mesh_instance: MeshInstance3D
var original_material: Material

func _ready():
	# Get configuration values safely
	var config = Global.get_config()
	area_bounds = config.area_bounds
	max_shooters = Global.get_current_max_shooters()  # Use upgraded value
	ground_min_x = config.ground_min_x
	ground_max_x = config.ground_max_x
	speed = config.shooter_drag_speed
	
	# Connect to upgrade signals to update max shooters when upgraded
	Global.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Setup optimized area detection
	_setup_area_detection()
	
	# Spawn initial shooter
	spawn_shooter()
	
	# Get reference to mesh for visual feedback
	mesh_instance = $MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		# Updated material access for Godot 4.4
		var material = mesh_instance.get_surface_override_material(0)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(0)
		original_material = material
	
	# Connect to shooter clicked signals
	for shooter in shooters_in_area:
		if shooter.has_signal("shooter_clicked"):
			shooter.shooter_clicked.connect(_on_shooter_clicked)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Use optimized raycast with reduced frequency
				if _check_area_click():
					is_dragging = true
					drag_start_position = global_position
					drag_start_mouse_position = get_viewport().get_mouse_position()
					last_mouse_position = drag_start_mouse_position
					# Visual feedback - change material color when dragging
					_set_dragging_visual(true)
			else:
				is_dragging = false
				mouse_velocity = Vector2.ZERO
				# Visual feedback - restore normal appearance
				_set_dragging_visual(false)
	
	# Track mouse movement for velocity calculation with frame rate independence
	if event is InputEventMouseMotion and is_dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var delta_time = get_process_delta_time()
		if delta_time > 0:  # Avoid division by zero
			mouse_velocity = (current_mouse_pos - last_mouse_position) / delta_time
		last_mouse_position = current_mouse_pos
		
		# Update drag target with reduced frequency for better performance
		_update_drag_target_cached()
	
	# Add shooter with right click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			spawn_shooter()

func _physics_process(delta):
	# Handle area dragging movement with optimized approach
	if is_dragging and has_drag_target:
		var current_x = global_position.x
		var distance = drag_target_x - current_x
		
		# Smooth interpolation instead of instant movement for less jank
		if abs(distance) > 0.01:
			# Use lerp for smooth movement
			var move_speed = 15.0  # Adjust this to control smoothness
			var new_x = lerp(current_x, drag_target_x, move_speed * delta)
			global_position.x = new_x
	
	# Update drag target less frequently
	if is_dragging:
		drag_update_timer += delta
		if drag_update_timer >= drag_update_interval:
			_update_drag_target_optimized()
			drag_update_timer = 0.0

# Optimized drag target update with caching and reduced frequency
func _update_drag_target_cached():
	# Only update every 33ms (30 FPS) instead of every frame
	if drag_update_timer >= drag_update_interval:
		drag_update_timer = 0.0
		_update_drag_target_optimized()

func _update_drag_target_optimized():
	if not is_dragging:
		return
		
	var camera = get_viewport().get_camera_3d()
	if camera:
		var current_mouse_pos = get_viewport().get_mouse_position()
		
		# Convert mouse screen position to world position
		var from = camera.project_ray_origin(current_mouse_pos)
		var to = from + camera.project_ray_normal(current_mouse_pos) * 1000
		
		# Create a plane at the area's Y position to intersect with
		var plane = Plane(Vector3.UP, global_position.y)
		var intersection = plane.intersects_ray(from, to - from)
		
		if intersection:
			var target_x = intersection.x
			
			# Clamp the target X position within ground boundaries
			var half_area_width = area_bounds.x / 2.0
			target_x = clamp(target_x, ground_min_x + half_area_width, ground_max_x - half_area_width)
			
			drag_target_x = target_x
			has_drag_target = true
		else:
			has_drag_target = false

# Optimized area click detection with cached raycast results
var last_area_click_check_time: float = 0.0
var area_click_check_interval: float = 0.016  # Check every 16ms (60 FPS)

func _setup_area_detection():
	# No setup needed for optimized raycast approach
	pass

func _check_area_click() -> bool:
	# Only perform raycast if enough time has passed since last check
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_area_click_check_time < area_click_check_interval:
		return false
	
	last_area_click_check_time = current_time
	
	var camera = get_viewport().get_camera_3d()
	if camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = 1  # Default collision layer
		query.collide_with_areas = true  # Enable area collision
		query.collide_with_bodies = true  # Enable body collision
		
		var result = space_state.intersect_ray(query)
		if result:
			# Check if we clicked on the area itself, its children, or any shooter in it
			var clicked_object = result.collider
			var clickable_area = get_node_or_null("ClickableArea")
			
			return (clicked_object == self or 
					clicked_object == clickable_area or 
					clicked_object in shooters_in_area or
					(clicked_object and clicked_object.get_parent() == self))
	
	return false

func _set_dragging_visual(is_dragging_state: bool):
	if mesh_instance and mesh_instance.mesh:
		if is_dragging_state:
			# Create a blue-tinted material for dragging state
			var dragging_material = StandardMaterial3D.new()
			dragging_material.albedo_color = Color(0.7, 0.7, 1.0, 0.8)
			dragging_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.set_surface_override_material(0, dragging_material)
		else:
			# Restore original material
			mesh_instance.set_surface_override_material(0, original_material)

func spawn_shooter():
	if shooters_in_area.size() < max_shooters:
		var instance = shooter_scene.instantiate()
		
		# Set to PAUSABLE mode so it stops when game is paused
		instance.process_mode = Node.PROCESS_MODE_PAUSABLE
		
		add_child(instance)
		
		# Find a safe spawn position that doesn't overlap with existing shooters
		var spawn_position = find_safe_spawn_position()
		instance.position = spawn_position
		
		# Add the spawned shooter to our tracking list
		shooters_in_area.append(instance)
		# Tell the shooter it's in an area and give it a reference to this area
		if instance.has_method("set_in_area"):
			instance.set_in_area(true, self)
		
		# Connect to the shooter's clicked signal
		if instance.has_signal("shooter_clicked"):
			instance.shooter_clicked.connect(_on_shooter_clicked)

# Function to find a safe spawn position that doesn't overlap with existing shooters
func find_safe_spawn_position() -> Vector3:
	var min_distance = Global.get_config().min_distance_between_shooters
	var max_attempts = 20   # Maximum attempts to find a safe position
	
	for attempt in range(max_attempts):
		# Generate random position within area bounds
		var random_x = randf_range(-area_bounds.x/2, area_bounds.x/2)
		var random_z = randf_range(-area_bounds.y/2, area_bounds.y/2)
		var test_position = Vector3(random_x, 0, random_z)
		
		# Check if this position is safe (not too close to existing shooters)
		var is_safe = true
		for shooter in shooters_in_area:
			if shooter and is_instance_valid(shooter):
				var distance = test_position.distance_to(shooter.position)
				if distance < min_distance:
					is_safe = false
					break
		
		# If position is safe, use it
		if is_safe:
			return test_position
	
	# If no safe position found after max attempts, return a random position anyway
	# This prevents infinite loops when the area gets crowded
	var fallback_x = randf_range(-area_bounds.x/2, area_bounds.x/2)
	var fallback_z = randf_range(-area_bounds.y/2, area_bounds.y/2)
	return Vector3(fallback_x, 0, fallback_z)

# Handle upgrade purchases
func _on_upgrade_purchased(upgrade_type: String, new_level: int):
	if upgrade_type == "max_shooter":
		max_shooters = Global.get_current_max_shooters()
		print("Spawn area updated max shooters to: ", max_shooters)

# Function to add a shooter that was spawned by the spawner
func add_spawned_shooter(shooter):
	if shooters_in_area.size() < max_shooters:
		# Add the spawned shooter to our tracking list
		shooters_in_area.append(shooter)
		# Tell the shooter it's in an area and give it a reference to this area
		if shooter.has_method("set_in_area"):
			shooter.set_in_area(true, self)
		
		# Connect to the shooter's clicked signal
		if shooter.has_signal("shooter_clicked"):
			shooter.shooter_clicked.connect(_on_shooter_clicked)

func _on_shooter_clicked(shooter):
	# When any shooter in the area is clicked, start dragging the area
	if not is_dragging:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var mouse_pos = get_viewport().get_mouse_position()
			is_dragging = true
			drag_start_position = global_position
			drag_start_mouse_position = mouse_pos
			last_mouse_position = mouse_pos
