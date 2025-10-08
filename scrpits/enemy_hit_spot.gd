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
	if parent and (parent.is_in_group("enemy") or parent.name.contains("enemy") or parent.name.contains("stickman") or parent.name.contains("boss")):
		print("⚠️ Enemy reached the end! Game Over!")
		enemy_reached_end.emit()

func _on_body_entered(body: Node3D):
	# Check if it's an enemy node
	if body.is_in_group("enemy") or body.name.contains("enemy") or body.name.contains("stickman") or body.name.contains("boss"):
		print("⚠️ Enemy reached the end! Game Over!")
		enemy_reached_end.emit()
