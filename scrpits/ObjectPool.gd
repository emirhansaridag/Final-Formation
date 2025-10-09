extends Node
class_name ObjectPool

# Pool of available objects
var available_objects: Array = []
var active_objects: Array = []
var scene_resource: PackedScene
var initial_pool_size: int
var max_pool_size: int
var parent_node: Node

signal object_spawned(obj)
signal object_returned(obj)
signal pool_exhausted

func _init(resource: PackedScene, initial_size: int = 20, max_size: int = 100):
	scene_resource = resource
	initial_pool_size = initial_size
	max_pool_size = max_size

func initialize(parent: Node):
	parent_node = parent
	_create_initial_pool()

# Update parent node when scene changes (for persistent pools)
func update_parent_node(new_parent: Node):
	parent_node = new_parent
	print("  🔄 ObjectPool parent node updated to: ", new_parent.name)

func _create_initial_pool():
	for i in initial_pool_size:
		var obj = _create_new_object()
		if obj:  # Only add if object was created successfully
			_deactivate_object(obj)
			available_objects.append(obj)

func _create_new_object():
	var obj = scene_resource.instantiate()
	
	# Set to PAUSABLE mode so it stops when game is paused
	obj.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Check if parent_node is still valid before adding child
	if not is_instance_valid(parent_node):
		push_error("❌ ObjectPool: parent_node is not valid! Cannot create object.")
		obj.queue_free()
		return null
	
	parent_node.add_child(obj)
	
	# Store original transform properties for proper reset
	if not obj.has_meta("original_scale"):
		obj.set_meta("original_scale", obj.scale)
	if not obj.has_meta("original_rotation"):
		obj.set_meta("original_rotation", obj.rotation)
	
	# Store original collision settings for proper reset (including children)
	_store_collision_settings_recursive(obj)
	
	return obj

func _activate_object(obj):
	# Check if object is still valid before trying to use it
	if not is_instance_valid(obj):
		return false
	
	obj.set_process(true)
	obj.set_physics_process(true)
	obj.visible = true
	
	# Re-enable collision for activated objects (restore original collision settings)
	# This MUST happen before reset_object to ensure collision is properly restored
	_enable_collision_recursive(obj)
	
	# Verify collision was properly restored (critical for enemy detection)
	_verify_collision_restored(obj)
	
	# Reset any custom properties if the object has a reset method
	if obj.has_method("reset_object"):
		obj.reset_object()
	return true

func _deactivate_object(obj):
	# Check if object is still valid before trying to use it
	if not is_instance_valid(obj):
		return false
	
	obj.set_process(false)
	obj.set_physics_process(false) 
	obj.visible = false
	
	# Reset all transform properties to original state from scene
	obj.global_position = Vector3.ZERO
	obj.global_rotation = Vector3.ZERO
	
	# Use stored original scale from scene, fallback to Vector3.ONE if not available
	if obj.has_meta("original_scale"):
		obj.scale = obj.get_meta("original_scale")
	else:
		obj.scale = Vector3.ONE
	
	# Disable collision for deactivated objects (handle both main object and Area3D children)
	_disable_collision_recursive(obj)
	
	# Stop any timers or ongoing processes
	if obj.has_method("cleanup"):
		obj.cleanup()
	return true

func get_object():
	var obj
	
	if available_objects.size() > 0:
		# Use object from pool, but check if it's still valid
		while available_objects.size() > 0:
			obj = available_objects.pop_back()
			if is_instance_valid(obj):
				if _activate_object(obj):
					break
			obj = null  # Object was invalid, try next one
		
		# If we ran out of valid objects, create a new one
		if obj == null:
			if active_objects.size() < max_pool_size:
				obj = _create_new_object()
				_activate_object(obj)
			else:
				pool_exhausted.emit()
				return null
	else:
		# Pool is empty
		if active_objects.size() < max_pool_size:
			# Create new object if under max limit
			obj = _create_new_object()
			_activate_object(obj)
		else:
			# Pool is exhausted
			pool_exhausted.emit()
			return null
	
	if obj:
		active_objects.append(obj)
		object_spawned.emit(obj)
	return obj

func return_object(obj):
	# Check if object is still valid before processing
	if not is_instance_valid(obj):
		# Remove invalid object from active list if it's there
		if obj in active_objects:
			active_objects.erase(obj)
		return
	
	if obj in active_objects:
		active_objects.erase(obj)
		if _deactivate_object(obj):
			available_objects.append(obj)
			object_returned.emit(obj)

func return_all_objects():
	for obj in active_objects.duplicate():
		return_object(obj)

func get_active_count() -> int:
	return active_objects.size()

func get_available_count() -> int:
	return available_objects.size()

func get_total_count() -> int:
	return active_objects.size() + available_objects.size()

# Helper functions for collision management
func _store_collision_settings_recursive(node: Node):
	# Store collision settings for this node
	if node.has_method("get_collision_layer"):
		node.set_meta("original_collision_layer", node.get_collision_layer())
	if node.has_method("get_collision_mask"):
		node.set_meta("original_collision_mask", node.get_collision_mask())
	
	# Recursively store collision settings for children
	for child in node.get_children():
		_store_collision_settings_recursive(child)

func _disable_collision_recursive(node: Node):
	# Disable collision for this node
	if node.has_method("set_collision_layer"):
		node.set_collision_layer(0)
	if node.has_method("set_collision_mask"):
		node.set_collision_mask(0)
	
	# Recursively disable collision for children
	for child in node.get_children():
		_disable_collision_recursive(child)

func _enable_collision_recursive(node: Node):
	# Re-enable collision for this node with robust fallback
	if node.has_method("set_collision_layer"):
		if node.has_meta("original_collision_layer"):
			node.set_collision_layer(node.get_meta("original_collision_layer"))
		else:
			# CRITICAL FIX: If metadata is missing, restore from scene type
			# This ensures collision is ALWAYS restored even if metadata fails
			if node is Area3D:
				# Check if this is an enemy Area3D (child of enemy node)
				var parent = node.get_parent()
				if parent and parent is Node3D:
					var parent_name = parent.name.to_lower()
					if parent_name.contains("enemy") or parent_name.contains("stickman") or parent_name.contains("boss"):
						node.set_collision_layer(16)  # Enemy collision layer
						print("⚠️ Restored missing collision_layer for enemy Area3D: ", parent.name)
	
	if node.has_method("set_collision_mask"):
		if node.has_meta("original_collision_mask"):
			node.set_collision_mask(node.get_meta("original_collision_mask"))
		else:
			# CRITICAL FIX: Restore collision mask even if metadata is missing
			if node is Area3D:
				var parent = node.get_parent()
				if parent and parent is Node3D:
					var parent_name = parent.name.to_lower()
					if parent_name.contains("enemy") or parent_name.contains("stickman") or parent_name.contains("boss"):
						node.set_collision_mask(4)  # Enemy collision mask
						print("⚠️ Restored missing collision_mask for enemy Area3D: ", parent.name)
	
	# Recursively re-enable collision for children
	for child in node.get_children():
		_enable_collision_recursive(child)

# Verify collision was properly restored (debugging and safety check)
func _verify_collision_restored(node: Node):
	# Check main node
	if node.has_method("get_collision_layer"):
		var layer = node.get_collision_layer()
		if layer == 0:
			push_warning("⚠️ ObjectPool: Collision layer is 0 for node: ", node.name)
	
	# Check child Area3D nodes (where enemy collision actually happens)
	for child in node.get_children():
		if child is Area3D:
			var layer = child.get_collision_layer()
			var mask = child.get_collision_mask()
			if layer == 0 or mask == 0:
				push_error("❌ CRITICAL: Enemy Area3D collision not restored! Layer:", layer, " Mask:", mask, " Parent:", node.name)
				# Force restore if this happens
				var parent_name = node.name.to_lower()
				if parent_name.contains("enemy") or parent_name.contains("stickman") or parent_name.contains("boss"):
					child.set_collision_layer(16)
					child.set_collision_mask(4)
					print("🔧 EMERGENCY FIX: Forced collision restoration for ", node.name)
		# Recursively check deeper children
		_verify_collision_restored(child)

# Clean up invalid objects from pools
func cleanup_invalid_objects():
	# Clean up invalid objects from available pool
	var valid_available = []
	for obj in available_objects:
		if is_instance_valid(obj):
			valid_available.append(obj)
	available_objects = valid_available
	
	# Clean up invalid objects from active pool
	var valid_active = []
	for obj in active_objects:
		if is_instance_valid(obj):
			valid_active.append(obj)
	active_objects = valid_active

# Call this when scene is changing to prevent freed object errors
func prepare_for_scene_change():
	cleanup_invalid_objects()
	# Deactivate all objects but keep them in pool for reuse
	for obj in active_objects.duplicate():
		if is_instance_valid(obj):
			_deactivate_object(obj)
			available_objects.append(obj)
		active_objects.erase(obj)
