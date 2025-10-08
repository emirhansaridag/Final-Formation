extends CanvasLayer

# Scene transition manager with fade effects
# Add this as an autoload in Project Settings

@onready var color_rect: ColorRect
@onready var animation_player: AnimationPlayer

var is_transitioning: bool = false

func _ready():
	# Create the fade overlay
	_create_fade_overlay()
	
	# Create animation player for smoother transitions
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	_create_fade_animations()

func _create_fade_overlay():
	# Create a black overlay for fade transitions
	color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make it cover the entire screen
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Start invisible
	color_rect.modulate.a = 0.0
	
	add_child(color_rect)

func _create_fade_animations():
	# Create animation library
	var animation_library = AnimationLibrary.new()
	
	# Fade out animation
	var fade_out = Animation.new()
	fade_out.length = 0.5
	
	var track_idx = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_idx, "ColorRect:modulate:a")
	fade_out.track_insert_key(track_idx, 0.0, 0.0)
	fade_out.track_insert_key(track_idx, 0.5, 1.0)
	
	animation_library.add_animation("fade_out", fade_out)
	
	# Fade in animation
	var fade_in = Animation.new()
	fade_in.length = 0.5
	
	track_idx = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_idx, "ColorRect:modulate:a")
	fade_in.track_insert_key(track_idx, 0.0, 1.0)
	fade_in.track_insert_key(track_idx, 0.5, 0.0)
	
	animation_library.add_animation("fade_in", fade_in)
	
	# Add library to animation player
	animation_player.add_animation_library("", animation_library)

# Main transition function with fade effect
func change_scene_with_fade(scene_path: String, fade_duration: float = 0.5):
	if is_transitioning:
		print("⚠️ Scene transition already in progress")
		return
		
	is_transitioning = true
	
	# Make sure the overlay is on top
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("🎬 Starting scene transition to: ", scene_path)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished
	
	# Cleanup pools before scene change
	await _cleanup_before_transition()
	
	# Change scene
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("❌ Failed to change scene to: " + scene_path)
		is_transitioning = false
		return
	
	# Wait a frame for the new scene to initialize
	await get_tree().process_frame
	
	# Fade from black
	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished
	
	# Re-enable mouse interaction
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	
	print("✅ Scene transition completed")

# Instant scene change (no fade) - for quick transitions
func change_scene_instant(scene_path: String):
	if is_transitioning:
		print("⚠️ Scene transition already in progress")
		return
		
	is_transitioning = true
	
	print("⚡ Instant scene change to: ", scene_path)
	
	# Cleanup pools
	await _cleanup_before_transition()
	
	# Change scene immediately
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("❌ Failed to change scene to: " + scene_path)
	
	is_transitioning = false

# Cleanup function that handles pool manager and other cleanup
func _cleanup_before_transition():
	print("🧹 Cleaning up before scene transition...")
	
	# Cleanup pool manager if it exists
	var pool_manager = get_node_or_null("/root/PoolManager")
	if pool_manager and pool_manager.has_method("prepare_for_scene_change"):
		pool_manager.prepare_for_scene_change()
		print("  ✅ Pool manager cleaned up")
	
	# Add any additional cleanup here in the future
	# For example: save game state, clear temporary data, etc.
	
	# Wait a frame to ensure cleanup is processed
	await get_tree().process_frame

# Fade out with custom callback (useful for loading screens)
func fade_out(duration: float = 0.5):
	if is_transitioning:
		return
		
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

# Fade in from black
func fade_in(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Get transition status
func get_is_transitioning() -> bool:
	return is_transitioning

# Force stop transition (emergency use only)
func force_stop_transition():
	print("🛑 Force stopping scene transition")
	is_transitioning = false
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
