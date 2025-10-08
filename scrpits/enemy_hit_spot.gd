extends Area3D

signal enemy_reached_end

func _ready():
	# Connect to detect when an enemy enters this area
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	print("Enemy hit spot initialized at position: ", global_position)

func _on_area_entered(area: Area3D):
	# Check if the area belongs to an enemy
	var parent = area.get_parent()
	if parent:
		var parent_name_lower = parent.name.to_lower()
		if parent.is_in_group("enemy") or parent_name_lower.contains("enemy") or parent_name_lower.contains("stickman") or parent_name_lower.contains("boss"):
			print("⚠️ Enemy reached the end! Game Over!")
			enemy_reached_end.emit()

func _on_body_entered(body: Node3D):
	# Check if it's an enemy node
	var body_name_lower = body.name.to_lower()
	if body.is_in_group("enemy") or body_name_lower.contains("enemy") or body_name_lower.contains("stickman") or body_name_lower.contains("boss"):
		print("⚠️ Enemy reached the end! Game Over!")
		enemy_reached_end.emit()
