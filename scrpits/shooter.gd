extends CharacterBody3D


@onready var main = get_tree().get_root().get_node("mainRoad")
@onready var projectile = load("res://scenes/projectile.tscn")
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
# Remove joystick reference since we're using direct dragging
# @onready var joystick = $"../Camera3D/joystick"

const JUMP_VELOCITY = 4.5
var input_pickable: bool

# Signal to notify when this shooter is clicked
signal shooter_clicked(shooter)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed = 600
var is_dragging = false
var drag_start_position = Vector3.ZERO
var drag_start_mouse_position = Vector2.ZERO
var last_mouse_position = Vector2.ZERO
var mouse_velocity = Vector2.ZERO
var is_in_area = false  # Track if shooter is inside an area
var spawn_area = null  # Reference to the spawn area this shooter belongs to
var move_to_center_speed = 1.5  # Speed for moving to center (reduced to prevent spazzing)

func _ready():
	input_pickable = true
	# Connect timer signal if not already connected
	if timer and not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	# Start the run2 animation and loop it
	if animation_player:
		animation_player.play("run2")
		# Set the animation to loop by accessing the animation resource
		var animation = animation_player.get_animation("run2")
		if animation:
			animation.loop_mode = Animation.LOOP_LINEAR
	
	# Setup optimized click detection area
	_setup_click_detection()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Use optimized raycasting with reduced frequency
				if not is_dragging:
					if _check_mouse_click():
						# Always emit signal to notify area that this shooter was clicked
						shooter_clicked.emit(self)
						
						# Only allow individual dragging if NOT in an area
						if not is_in_area:
							is_dragging = true
							drag_start_position = global_position
							drag_start_mouse_position = get_viewport().get_mouse_position()
							last_mouse_position = drag_start_mouse_position
			else:
				is_dragging = false
				mouse_velocity = Vector2.ZERO
	
	# Track mouse movement for velocity calculation (only when actually dragging)
	if event is InputEventMouseMotion and is_dragging and not is_in_area:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var delta_time = get_process_delta_time()
		if delta_time > 0:  # Avoid division by zero
			mouse_velocity = (current_mouse_pos - last_mouse_position) / delta_time
		last_mouse_position = current_mouse_pos
		
		# Update drag target with reduced frequency for better performance
		_update_drag_target_cached()

var fire_rate_update_timer: float = 0.0
var drag_target_position: Vector3
var has_drag_target: bool = false
var cached_fire_rate: float = 0.8  # Cache the fire rate to avoid constant lookups

func _physics_process(delta):
	# Reduce fire rate update frequency (use a longer interval for this)
	fire_rate_update_timer += delta
	if fire_rate_update_timer >= 1.0:  # Update fire rate only once per second for better performance
		cached_fire_rate = Global.get_current_firerate()
		timer.wait_time = cached_fire_rate
		fire_rate_update_timer = 0.0
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle dragging movement (only if not in area)
	if is_dragging and not is_in_area:
		# Use cached drag target instead of raycasting every frame
		if has_drag_target:
			var target_x = drag_target_position.x
			var current_x = global_position.x
			var distance = target_x - current_x
			
			# Move toward target position smoothly
			if abs(distance) > 0.01:
				velocity.x = distance * 5.0  # Direct value for responsiveness
			else:
				velocity.x = 0
		else:
			velocity.x = 0
	else:
		# If in an area, move toward the center of the spawn area with collision avoidance
		if is_in_area and spawn_area:
			var area_center = spawn_area.global_position
			var direction_to_center = Vector3(area_center.x - global_position.x, 0, area_center.z - global_position.z)
			
			# Increase tolerance and add collision avoidance
			var tolerance = 1.5  # Larger tolerance to prevent clustering at exact center
			var distance_to_center = direction_to_center.length()
			
			if distance_to_center > tolerance:
				# Add collision avoidance with other shooters
				var avoidance_force = Vector3.ZERO
				if spawn_area.has_method("get_shooters_in_area"):
					var nearby_shooters = spawn_area.shooters_in_area
					for other_shooter in nearby_shooters:
						if other_shooter != self and is_instance_valid(other_shooter):
							var distance_to_other = global_position.distance_to(other_shooter.global_position)
							var min_distance = 1.0  # Minimum distance between shooters
							
							if distance_to_other < min_distance and distance_to_other > 0.1:
								# Calculate repulsion force
								var repulsion = (global_position - other_shooter.global_position).normalized()
								var force_strength = (min_distance - distance_to_other) / min_distance
								avoidance_force += repulsion * force_strength * 2.0
				
				# Combine center attraction with collision avoidance
				direction_to_center = direction_to_center.normalized()
				var target_velocity = (direction_to_center + avoidance_force).normalized() * move_to_center_speed
				
				# Smooth the movement to reduce jittering
				velocity.x = move_toward(velocity.x, target_velocity.x, move_to_center_speed * 2.0 * delta)
				velocity.z = move_toward(velocity.z, target_velocity.z, move_to_center_speed * 2.0 * delta)
			else:
				# When close to center, gradually slow down instead of stopping abruptly
				velocity.x = move_toward(velocity.x, 0, move_to_center_speed * 3.0 * delta)
				velocity.z = move_toward(velocity.z, 0, move_to_center_speed * 3.0 * delta)
		else:
			# Stop movement when not dragging and not in area
			velocity.x = move_toward(velocity.x, 0, 800.0 * delta)
			velocity.z = 0
	
	move_and_slide()

# Optimized drag target update with caching and reduced frequency
var drag_update_timer: float = 0.0
var drag_update_interval: float = 0.033  # 30 FPS update rate

func _update_drag_target_cached():
	# Only update every 33ms (30 FPS) instead of every frame
	drag_update_timer += get_process_delta_time()
	if drag_update_timer >= drag_update_interval:
		drag_update_timer = 0.0
		_update_drag_target_optimized()

func _update_drag_target_optimized():
	if is_dragging and not is_in_area:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var current_mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(current_mouse_pos)
			var to = from + camera.project_ray_normal(current_mouse_pos) * 1000
			
			# Create a plane at the character's Y position to intersect with
			var plane = Plane(Vector3.UP, global_position.y)
			var intersection = plane.intersects_ray(from, to - from)
			
			if intersection:
				drag_target_position = intersection
				has_drag_target = true
			else:
				has_drag_target = false

# Optimized click detection with cached raycast results
var last_click_check_time: float = 0.0
var click_check_interval: float = 0.016  # Check every 16ms (60 FPS)

func _setup_click_detection():
	# No setup needed for optimized raycast approach
	pass

func _check_mouse_click() -> bool:
	# Only perform raycast if enough time has passed since last check
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_click_check_time < click_check_interval:
		return false
	
	last_click_check_time = current_time
	
	var camera = get_viewport().get_camera_3d()
	if camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = collision_mask
		query.collide_with_areas = false
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		return result and result.collider == self
	
	return false

# Function to set if shooter is inside an area
func set_in_area(in_area: bool, area_reference = null):
	is_in_area = in_area
	spawn_area = area_reference
	if in_area:
		# Stop any individual dragging when entering area
		is_dragging = false
		
func shoot():
	# Use pool manager if available, otherwise fallback to normal instantiation
	var pool_manager = get_node_or_null("/root/PoolManager")
	if pool_manager and pool_manager.has_method("spawn_projectile"):
		var instance = pool_manager.spawn_projectile(global_position, global_rotation, rotation.y)
		if instance:
			instance.set_pooled(true)
	else:
		# Fallback to normal instantiation
		var instance = projectile.instantiate()
		instance.dir = rotation.y
		instance.spawn_pos = global_position
		instance.spawn_rot = global_rotation
		get_tree().current_scene.add_child(instance)


func _on_timer_timeout():
	shoot()
