extends Control

# UI References
@onready var damage_upgrade_bar = $CanvasLayer/upgrades/damage/dmgUpgradeBar
@onready var damage_upgrade_button = $CanvasLayer/upgrades/damage/dmgUpButton
@onready var damage_cost_label = $CanvasLayer/upgrades/damage/dmgCost

@onready var attack_speed_upgrade_bar = $CanvasLayer/upgrades/attackSpeed/attackSpeedUpgradeBar
@onready var attack_speed_upgrade_button = $CanvasLayer/upgrades/attackSpeed/attackSpeedUpButton
@onready var attack_speed_cost_label = $CanvasLayer/upgrades/attackSpeed/attackSpeedCost

@onready var level_upgrade_bar = $CanvasLayer/upgrades/level/levelUpgradeBar
@onready var level_upgrade_button = $CanvasLayer/upgrades/level/levelUpButton
@onready var level_cost_label = $CanvasLayer/upgrades/level/levelCost

@onready var max_shooter_upgrade_bar = $CanvasLayer/upgrades/maxShooter/maxShooterUpgradeBar
@onready var max_shooter_upgrade_button = $CanvasLayer/upgrades/maxShooter/maxShooterUpgradeButton
@onready var max_shooter_cost_label = $CanvasLayer/upgrades/maxShooter/maxShooterUpgradeCost

# Navigation and currency UI
@onready var back_button = $CanvasLayer/backButton
@onready var currency_label = $CanvasLayer/currencyDisplay/currencyLabel

func _ready():
	# Connect upgrade buttons
	if damage_upgrade_button:
		damage_upgrade_button.pressed.connect(_on_damage_upgrade_pressed)
	if attack_speed_upgrade_button:
		attack_speed_upgrade_button.pressed.connect(_on_attack_speed_upgrade_pressed)
	if level_upgrade_button:
		level_upgrade_button.pressed.connect(_on_level_upgrade_pressed)
	if max_shooter_upgrade_button:
		max_shooter_upgrade_button.pressed.connect(_on_max_shooter_upgrade_pressed)
	
	# Connect back button
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to Global signals
	Global.currency_changed.connect(_on_currency_changed)
	Global.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Initial UI update
	_update_all_upgrades()
	_update_currency_display()

func _on_damage_upgrade_pressed():
	if Global.purchase_upgrade_type("damage"):
		print("Damage upgraded! New level: ", Global.get_upgrade_level("damage"))
		_update_upgrade_ui("damage")

func _on_attack_speed_upgrade_pressed():
	if Global.purchase_upgrade_type("attack_speed"):
		print("Attack speed upgraded! New level: ", Global.get_upgrade_level("attack_speed"))
		_update_upgrade_ui("attack_speed")

func _on_level_upgrade_pressed():
	if Global.purchase_upgrade_type("max_level"):
		print("Max level upgraded! New max level: ", Global.get_current_max_shooter_level())
		_update_upgrade_ui("max_level")

func _on_max_shooter_upgrade_pressed():
	if Global.purchase_upgrade_type("max_shooter"):
		print("Max shooters upgraded! New max: ", Global.get_current_max_shooters())
		_update_upgrade_ui("max_shooter")

func _on_back_button_pressed():
	# Return to main menu
	SceneTransition.change_scene_with_fade("res://scenes/main_menu.tscn")

func _on_currency_changed(new_amount: int):
	# Update button states based on affordability
	_update_all_upgrades()
	_update_currency_display()

func _on_upgrade_purchased(upgrade_type: String, new_level: int):
	_update_upgrade_ui(upgrade_type)

func _update_currency_display():
	if currency_label:
		currency_label.text = str(Global.currency)

func _update_all_upgrades():
	_update_upgrade_ui("damage")
	_update_upgrade_ui("attack_speed")
	_update_upgrade_ui("max_level")
	_update_upgrade_ui("max_shooter")

func _update_upgrade_ui(upgrade_type: String):
	var current_level = Global.get_upgrade_level(upgrade_type)
	var max_level = Global.get_max_upgrade_level(upgrade_type)
	var cost = Global.get_upgrade_cost(upgrade_type)
	var can_afford = Global.can_afford_upgrade(cost)
	var can_upgrade = Global.can_upgrade(upgrade_type)
	
	match upgrade_type:
		"damage":
			if damage_upgrade_bar:
				damage_upgrade_bar.value = current_level
				damage_upgrade_bar.max_value = max_level
			if damage_cost_label:
				if current_level >= max_level:
					damage_cost_label.text = "MAX"
				else:
					damage_cost_label.text = str(cost)
			if damage_upgrade_button:
				damage_upgrade_button.disabled = not can_upgrade
				damage_upgrade_button.modulate = Color.WHITE if can_upgrade else Color.GRAY
		
		"attack_speed":
			if attack_speed_upgrade_bar:
				attack_speed_upgrade_bar.value = current_level
				attack_speed_upgrade_bar.max_value = max_level
			if attack_speed_cost_label:
				if current_level >= max_level:
					attack_speed_cost_label.text = "MAX"
				else:
					attack_speed_cost_label.text = str(cost)
			if attack_speed_upgrade_button:
				attack_speed_upgrade_button.disabled = not can_upgrade
				attack_speed_upgrade_button.modulate = Color.WHITE if can_upgrade else Color.GRAY
		
		"max_level":
			if level_upgrade_bar:
				level_upgrade_bar.value = current_level
				level_upgrade_bar.max_value = max_level
			if level_cost_label:
				if current_level >= max_level:
					level_cost_label.text = "MAX"
				else:
					level_cost_label.text = str(cost)
			if level_upgrade_button:
				level_upgrade_button.disabled = not can_upgrade
				level_upgrade_button.modulate = Color.WHITE if can_upgrade else Color.GRAY
		
		"max_shooter":
			if max_shooter_upgrade_bar:
				max_shooter_upgrade_bar.value = current_level
				max_shooter_upgrade_bar.max_value = max_level
			if max_shooter_cost_label:
				if current_level >= max_level:
					max_shooter_cost_label.text = "MAX"
				else:
					max_shooter_cost_label.text = str(cost)
			if max_shooter_upgrade_button:
				max_shooter_upgrade_button.disabled = not can_upgrade
				max_shooter_upgrade_button.modulate = Color.WHITE if can_upgrade else Color.GRAY

# Function to show current stats (for debugging)
func show_current_stats():
	print("=== CURRENT STATS ===")
	print("Currency: ", Global.currency)
	print("Damage: ", Global.get_current_damage(), " (Level: ", Global.get_upgrade_level("damage"), "/", Global.get_max_upgrade_level("damage"), ")")
	print("Fire Rate: ", Global.get_current_firerate(), " (Level: ", Global.get_upgrade_level("attack_speed"), "/", Global.get_max_upgrade_level("attack_speed"), ")")
	print("Max Shooter Level: ", Global.get_current_max_shooter_level(), " (Upgrade Level: ", Global.get_upgrade_level("max_level"), "/", Global.get_max_upgrade_level("max_level"), ")")
	print("Max Shooters: ", Global.get_current_max_shooters(), " (Level: ", Global.get_upgrade_level("max_shooter"), "/", Global.get_max_upgrade_level("max_shooter"), ")")
	print("==================")

func _on_shop_2_button_pressed():
		SceneTransition.change_scene_with_fade("res://scenes/shop_2.tscn")
